import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:growmate_web/registradip';

import 'package:intl/intl.dart';

class Inserimentodip extends StatefulWidget {
  static const String routeName = "vivaio";

  const Inserimentodip({super.key});

  @override
  _VivaioScreenState createState() => _VivaioScreenState();
}

class _VivaioScreenState extends State<Inserimentodip> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String vivaioId = "";
  String nomeVivaio = "";
  String indirizzoVivaio = "";
  DateTime dataScadenzaVivaio = DateTime.now();
  bool isLoading = true;
  List<Map<String, String>> dipendenti = []; // Lista per i dati dei dipendenti

  Future<void> _fetchVivaioData() async {
    try {
      print("Inizio recupero dati del vivaio...");

      final User? user = _auth.currentUser;

      if (user == null) {
        print("Nessun utente autenticato.");
        setState(() {
          isLoading = false;
        });
        return;
      }

      print("Utente autenticato con UID: ${user.uid}");

      // Recupera l'ID del vivaio associato all'utente
      final userDoc = await _firestore
          .collection('Utenti')
          .where('UID', isEqualTo: user.uid)
          .get();

      if (userDoc.docs.isEmpty) {
        print("Nessun documento trovato nella collezione 'Utenti' per l'UID fornito.");
        setState(() {
          isLoading = false;
        });
        return;
      }

      vivaioId = userDoc.docs.first['vivaio'] ?? "";
      print("Vivaio trovato: $vivaioId");

      // Recupera i dettagli del vivaio
      final vivaioDoc = await _firestore
          .collection('vivaio')
          .where('vivaio_id', isEqualTo: vivaioId)
          .get();

      if (vivaioDoc.docs.isEmpty) {
        print("Nessun vivaio trovato con l'ID specificato.");
        setState(() {
          isLoading = false;
        });
        return;
      }

      final vivaioData = vivaioDoc.docs.first.data();
      nomeVivaio = vivaioData['nome'] ?? "";
      indirizzoVivaio = vivaioData['indirizzo'] ?? "";
      dataScadenzaVivaio = DateTime.fromMillisecondsSinceEpoch(
          vivaioData['scadenza'] ?? 0);

      print("Dati del vivaio recuperati: Nome - $nomeVivaio, Indirizzo - $indirizzoVivaio, Scadenza - ${DateFormat('dd/MM/yyyy').format(dataScadenzaVivaio)}");

      // Recupera la lista dei dipendenti
      final dipendentiDocs = await _firestore
          .collection('Utenti')
          .where('vivaio', isEqualTo: vivaioId)
          .get();

      print("Dipendenti trovati: ${dipendentiDocs.docs.length}");

      dipendenti = dipendentiDocs.docs.map((doc) {
        final data = doc.data();
        print("Dipendente: ${data}");
        return {
          'cognome': (data['cognome'] ?? 'Cognome mancante').toString(),
          'nome': (data['nome'] ?? 'Nome mancante').toString(),
          'mail': (data['mail'] ?? 'Email mancante').toString(),
        };
      }).toList();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Errore durante il recupero dei dati del vivaio: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchVivaioData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        leading: SvgPicture.asset('assets/logo.svg'),
        centerTitle: false,
        title: const Text(
          "Benvenuto nel tuo vivaio",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informazioni sul Vivaio
                    Image.asset('assets/vivaio.svg'),
                    Text('Nome del Vivaio: $nomeVivaio'),
                    Text('Indirizzo: $indirizzoVivaio'),
                    Text(
                        'Data di Scadenza: ${DateFormat('dd/MM/yyyy').format(dataScadenzaVivaio)}'),
                    const SizedBox(height: 16),
                    // Elenco Dipendenti
                    Text(
                      'Dipendenti:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dipendenti.length,
                      itemBuilder: (context, index) {
                        final dipendente = dipendenti[index];
                        return ListTile(
                          title: Text(
                            '${dipendente['cognome']} ${dipendente['nome']}',
                          ),
                          subtitle: Text('Email: ${dipendente['mail']}'),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Bottone per aggiungere dipendente
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RegistraDipendente(),
                          ),
                        );
                      },
                      child: const Text('Aggiungi Dipendente'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
