import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';
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

  Future<void> _fetchVivaioData() async {
    try {
      final User? user = _auth.currentUser;

      if (user == null) {
        print("Nessun utente autenticato.");
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Recupera l'ID del vivaio associato all'utente
      final userDoc = await _firestore
          .collection('Utenti')
          .where('UID', isEqualTo: user.uid)
          .get();

      if (userDoc.docs.isEmpty) {
        print(
            "Nessun documento trovato nella collezione 'Utenti' per l'UID fornito.");
        setState(() {
          isLoading = false;
        });
        return;
      }

      vivaioId = userDoc.docs.first['vivaio'];
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
      setState(() {
        nomeVivaio = vivaioData['nome'] ?? "";
        indirizzoVivaio = vivaioData['indirizzo'] ?? "";
        dataScadenzaVivaio =
            DateTime.fromMillisecondsSinceEpoch(vivaioData['scadenza'] ?? 0);
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
                    Text('Data di Scadenza: ${DateFormat('dd mm yyyy').format(dataScadenzaVivaio)}'),
                    // Elenco Dipendenti
                    Text('Dipendenti:'),
                    // ... (codice per visualizzare l'elenco dei dipendenti)

                    // Bottone per aggiungere dipendente
                    ElevatedButton(
                      onPressed: () {
                        // Implementa la logica per aggiungere un nuovo dipendente
                      },
                      child: Text('Aggiungi Dipendente'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}