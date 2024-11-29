import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:growmate_web/inserimentolotto.dart';

class VivaioScreen extends StatefulWidget {
  const VivaioScreen({super.key});

  @override
  _VivaioScreenState createState() => _VivaioScreenState();
}

class _VivaioScreenState extends State<VivaioScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true; // Indica se i dati sono in caricamento
  List<Map<String, dynamic>> lotti = []; // Lista dei lotti recuperati

  // Funzione per recuperare i lotti
  Future<void> _fetchUserLotti() async {
    try {
      final User? user = _auth.currentUser;

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
  void initState() {
    super.initState();
    _fetchUserLotti(); // Recupera i lotti quando la schermata è caricata
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade300,
        title: Row(
          children: [
            SizedBox(
                  width: MediaQuery.of(context).size.height * 0.1,
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: SvgPicture.asset('assets/logo.svg'),
                ),
            const SizedBox(width: 10),
            const Text(
              "Benvenuto nel tuo vivaio",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Azione per il profilo utente
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Ecco i tuoi lotti:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: lotti.isEmpty
                      ? const Center(
                          child: Text(
                            "Non ci sono lotti associati.",
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: lotti.length,
                          itemBuilder: (context, index) {
                            final lotto = lotti[index];
                            return ListTile(
                              leading: const Icon(Icons.grass),
                              title: Text(
                                lotto['id_lotto'] ?? 'Lotto senza nome',
                                style: const TextStyle(fontSize: 16),
                              ),
                              subtitle: Text(
                                lotto['coltura'] ?? 'Nessuna descrizione disponibile',
                                style: const TextStyle(fontSize: 14),
                              ),
                              onTap: () {
                                
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => InserimentoLotto(),
                                    ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}