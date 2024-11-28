import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? userVivaioId; // ID del vivaio dell'utente
  List<Map<String, dynamic>> lotti = []; // Lista dei lotti
  bool isLoading = true; // Stato per mostrare o nascondere il caricamento

  @override
  void initState() {
    super.initState();
    _fetchUserLotti();
  }

  // Recupera i lotti del vivaio associato all'utente autenticato
  Future<void> _fetchUserLotti() async {
    try {
      final User? user = _auth.currentUser; // Ottieni l'utente autenticato
      if (user == null) {
        print("Nessun utente autenticato.");
        setState(() {
          isLoading = false;
        });
        return;
      }

      print("UID utente autenticato: ${user.uid}");

      // Cerca l'utente nella collezione "Utenti"
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

      // Ottieni l'ID del vivaio associato all'utente
      final vivaioId = userDoc.docs.first['vivaio'];
      print("Vivaio trovato: $vivaioId");

      // Recupera il documento del vivaio
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

      // Ottieni l'array degli ID dei lotti
      final List<dynamic> lottiIds = vivaioDoc.docs.first['lotti'];
      print("Lista di ID dei lotti trovata: $lottiIds");

      // Recupera i dettagli dei lotti
      final lottiSnapshot = await _firestore
          .collection('Lotto')
          .where('id_lotto', whereIn: lottiIds)
          .get();

      print("Query Lotti restituita: ${lottiSnapshot.docs.map((doc) => doc.data())}");

      // Aggiorna lo stato con i dettagli dei lotti
      setState(() {
        lotti = lottiSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print("Errore durante il recupero dei dati: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vivavio Bello srl'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : lotti.isEmpty
                ? Center(
                    child: Text(
                      "Lotti non disponibili",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    itemCount: lotti.length,
                    itemBuilder: (context, index) {
                      final lotto = lotti[index];
                      return ScanCard(
                        plantName: lotto['coltura'] ?? 'N/A',
                        lotNumber: lotto['id_lotto'] ?? 'N/A',
                        sowingDate: lotto['data_semina'] ?? 'N/A',
                      );
                    },
                  ),
      ),
    );
  }
}

class ScanCard extends StatelessWidget {
  final String plantName;
  final String lotNumber;
  final String sowingDate;

  const ScanCard({
    required this.plantName,
    required this.lotNumber,
    required this.sowingDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.eco,
                color: Colors.green,
                size: 30,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plantName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("Lotto $lotNumber"),
                  SizedBox(height: 8),
                  Text(
                    "Data semina: $sowingDate",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}