import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:growmate_web/vivaio.dart';

class InserimentoLotto extends StatelessWidget {
  InserimentoLotto({super.key});

  final TextEditingController colturaController = TextEditingController();
  final TextEditingController dataSeminaController = TextEditingController();
  final TextEditingController dataConsegnaController = TextEditingController();
  final TextEditingController pianteController = TextEditingController();
  final TextEditingController vassoiController = TextEditingController();

Future<void> _salvaLotto(BuildContext context) async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("Utente non autenticato.");
      return;
    }

    final coltura = colturaController.text;
    final dataSemina = dataSeminaController.text;
    final dataConsegna = dataConsegnaController.text;
    final piante = int.tryParse(pianteController.text) ?? 0;
    final vassoi = int.tryParse(vassoiController.text) ?? 0;

    if (coltura.isEmpty || dataSemina.isEmpty || dataConsegna.isEmpty) {
      print("Campi obbligatori mancanti.");
      return;
    }

    final userQuery = await FirebaseFirestore.instance
        .collection('Utenti')
        .where('UID', isEqualTo: user.uid)
        .get();

    if (userQuery.docs.isEmpty) {
      print("Nessun vivaio associato trovato per l'utente.");
      return;
    }

    final vivaioId = userQuery.docs.first['vivaio'];

    final vivaioQuery = await FirebaseFirestore.instance
        .collection('vivaio')
        .where('vivaio_id', isEqualTo: vivaioId)
        .get();

    if (vivaioQuery.docs.isEmpty) {
      print("Nessun documento trovato nella collezione 'vivaio' con questo ID.");
      return;
    }

    final vivaioDoc = vivaioQuery.docs.first;
    final vivaioRef = FirebaseFirestore.instance.collection('vivaio').doc(vivaioDoc.id);

    final counterRef = FirebaseFirestore.instance.collection('Counters').doc('lotto_counter');
    final counterSnapshot = await counterRef.get();

    int nextId = 1;
    if (counterSnapshot.exists) {
      nextId = counterSnapshot['current'] + 1;
    }

    await counterRef.set({'current': nextId});

    final nuovoLotto = {
      'id_lotto': nextId.toString(),
      'coltura': coltura,
      'data_semina': dataSemina,
      'data_consegna': dataConsegna,
      'piante': piante,
      'vassoi': vassoi,
      'scansioni': [],
      'fallanza': 0,
      'consegnato': false,
    };

    await FirebaseFirestore.instance
        .collection('Lotto')
        .doc(nextId.toString())
        .set(nuovoLotto);

    print("Lotto salvato con successo con ID: ${nextId.toString()}");

    await vivaioRef.update({
      'lotti': FieldValue.arrayUnion([nextId.toString()]),
    });

    print("L'array 'lotti' del vivaio è stato aggiornato con successo.");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => VivaioScreen()),
    );
  } catch (e) {
    print("Errore durante il salvataggio del lotto o aggiornamento del vivaio: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inserimento Lotto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: colturaController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Coltura',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dataSeminaController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Data Semina (YYYY-MM-DD)',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dataConsegnaController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Data Consegna (YYYY-MM-DD)',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pianteController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Numero di Piante',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: vassoiController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Numero di Vassoi',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed : () => _salvaLotto(context),
              child: const Text('Salva Lotto'),
            ),
          ],
        ),
      ),
    );
  }
}