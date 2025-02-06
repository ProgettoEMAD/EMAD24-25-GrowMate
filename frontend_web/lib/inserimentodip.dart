import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:growmate_web/common/colors.dart';
import 'package:growmate_web/main.dart';
import 'package:growmate_web/registradip.dart';

import 'package:intl/intl.dart';

final DateFormat formatter = DateFormat('d MMMM yyyy', 'it_IT');

class Inserimentodip extends StatefulWidget {
  static const String routeName = "vivaio";

  const Inserimentodip({super.key});

  @override
  _VivaioScreenState createState() => _VivaioScreenState();
}

class _VivaioScreenState extends State<Inserimentodip> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? vivaioData; // Memorizza i dati del vivaio

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
        print(
            "Nessun documento trovato nella collezione 'Utenti' per l'UID fornito.");
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

  signOut() {
    _auth
        .signOut()
        .then((_) => Navigator.of(context).pushReplacementNamed(App.routeName));
  }

  @override
  void initState() {
    super.initState();
    _fetchVivaioData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBrownLight,
      appBar: AppBar(
        title: Text(
          //vivaioData != null ? '${vivaioData!['nome']}' : 'Caricamento...',
          "GrowMate",
        ),
        centerTitle: true,
        backgroundColor: kGreenDark,
        foregroundColor: Colors.white,
        actions: [
          if (!isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                onPressed: signOut,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: kBrownLight,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: kGreen),
                    Padding(padding: EdgeInsets.only(left: 8)),
                    Text(
                      'Esci',
                      style: TextStyle(
                        fontSize: 14,
                        color: kGreen, // Colore del testo
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: kGreenDark,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (vivaioData != null)
                    Container(
                      width: double.infinity,
                      color: kBrownAccent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: SizedBox(
                              height: 200,
                              child: SvgPicture.asset(
                                'assets/illustration3.svg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vivaioData!['nome'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  vivaioData!['indirizzo'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  vivaioData!['mail'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  "Scadenza contratto: ${formatter.format(DateTime.fromMillisecondsSinceEpoch(vivaioData!['scadenza'] as int))}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text("Lista dipendenti",
                        style: TextStyle(
                            color: kGreenDark,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dipendenti.length,
                    itemBuilder: (context, index) {
                      final dipendente = dipendenti[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: kBrown,
                          foregroundColor: Colors.white,
                          child: Text("${index + 1}"),
                        ),
                        title: Text(
                          '${dipendente['cognome']} ${dipendente['nome']}',
                        ),
                        subtitle: Text('Email: ${dipendente['mail']}'),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Bottone per aggiungere dipendente
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: MaterialButton(
                      color: kBrown,
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RegistraDipendente(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: const Text('Aggiungi nuovo dipendente'),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
