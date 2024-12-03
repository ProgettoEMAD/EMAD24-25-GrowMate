import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:growmate/Screen/pagina_pianta.dart';
import 'package:growmate/auth.dart';
import 'package:growmate/Screen/Login.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? vivaioData; // Memorizza i dati del vivaio
  List<Map<String, dynamic>> lotti = []; // Lista dei lotti
  bool isLoading = true; // Stato per mostrare o nascondere il caricamento

  @override
  void initState() {
    super.initState();
    _fetchUserLotti();
  }
  Future<void> signOut() async {
    
      await Auth().signOut();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()), 
      ); 
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

      // Memorizza i dati del vivaio
      setState(() {
        vivaioData = vivaioDoc.docs.first.data();
      });
      print("Dati del vivaio: $vivaioData");

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
            .map((doc) => doc.data())
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print("Errore durante il recupero dei dati: $e");
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text(vivaioData != null ? '${vivaioData!['nome']}' : 'Caricamento...'),
  backgroundColor: Colors.green,
  actions: [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: signOut, // Funzione per il logout
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.white, // Colore del pulsante
        ),
        child: const Text(
          'Esci',
          style: TextStyle(
            fontSize: 16,
            color: Colors.green, // Colore del testo
          ),
        ),
      ),
    ),
  ],
),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : lotti.isEmpty
                ? const Center(
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LottoDetailPage(lotto: lotto),
                            ),
                          );
                        },
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
  final VoidCallback? onTap; // Callback per il clic

  const ScanCard({super.key, 
    required this.plantName,
    required this.lotNumber,
    required this.sowingDate,
    this.onTap, // Callback opzionale
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
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
                child: const Icon(
                  Icons.eco,
                  color: Colors.green,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plantName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text("Lotto $lotNumber"),
                    const SizedBox(height: 8),
                    Text(
                      "Data semina: $sowingDate",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}