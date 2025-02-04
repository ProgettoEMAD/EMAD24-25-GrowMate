import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:growmate_web/model/lotto.dart';
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
        return;
      }

      final coltura = colturaController.text;
      final dataSeminaString = dataSeminaController.text;
      final dataConsegnaString = dataConsegnaController.text;
      final piante = int.tryParse(pianteController.text) ?? 0;
      final vassoi = int.tryParse(vassoiController.text) ?? 0;

      if (coltura.isEmpty || dataSeminaString.isEmpty || dataConsegnaString.isEmpty) {
        return;
      }

      final dataSemina = DateTime.tryParse(dataSeminaString);
      final dataConsegna = DateTime.tryParse(dataConsegnaString);

      if (dataSemina == null || dataConsegna == null) {
        return;
      }

      final userQuery = await FirebaseFirestore.instance
          .collection('Utenti')
          .where('UID', isEqualTo: user.uid)
          .get();

      if (userQuery.docs.isEmpty) {
        return;
      }

      final vivaioId = userQuery.docs.first['vivaio'];

      final vivaioQuery = await FirebaseFirestore.instance
          .collection('vivaio')
          .where('vivaio_id', isEqualTo: vivaioId)
          .get();

      if (vivaioQuery.docs.isEmpty) {
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

      await FirebaseFirestore.instance.collection('Lotto').doc(nextId.toString()).set(
        Lotto(
          idLotto: nextId,
          coltura: coltura,
          dataSemina: dataSemina,
          dataConsegna: dataConsegna,
          piante: piante,
          vassoi: vassoi,
        ).toJson(),
      );

      await vivaioRef.update({
        'lotti': FieldValue.arrayUnion([nextId]),
      });

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VivaioScreen()),
        );
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEFADF),
      appBar: AppBar(
        title: const Text('Inserimento Lotto', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF5F6C37),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: colturaController,
              decoration: InputDecoration(labelText: 'Coltura'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dataSeminaController,
              readOnly: true,
              decoration: InputDecoration(labelText: 'Data Semina (YYYY-MM-DD)'),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  dataSeminaController.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dataConsegnaController,
              readOnly: true,
              decoration: InputDecoration(labelText: 'Data Consegna (YYYY-MM-DD)'),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  dataConsegnaController.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pianteController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Numero di Piante'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: vassoiController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Numero di Vassoi'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5F6C37),
                foregroundColor: Colors.white,
              ),
              onPressed: () => _salvaLotto(context),
              child: const Text('Salva Lotto'),
            ),
          ],
        ),
      ),
    );
  }
}
