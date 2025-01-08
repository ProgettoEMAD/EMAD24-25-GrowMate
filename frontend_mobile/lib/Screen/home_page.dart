import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:growmate/common/colors.dart';
import 'package:growmate/common/const.dart';
import 'package:growmate/screen/pagina_pianta.dart';
import 'package:growmate/auth.dart';
import 'package:growmate/screen/login_page.dart';

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
  bool isLoading = true;

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

      // Ottieni l'array degli ID dei lotti
      final List<dynamic> lottiIds = vivaioDoc.docs.first['lotti'];
      print("Lista di ID dei lotti trovata: $lottiIds");

      // Recupera i dettagli dei lotti
      final lottiSnapshot = await _firestore
          .collection('Lotto')
          .where('id_lotto', whereIn: lottiIds)
          .get();

      print(
          "Query Lotti restituita: ${lottiSnapshot.docs.map((doc) => doc.data())}");

      // Aggiorna lo stato con i dettagli dei lotti
      setState(() {
        lotti = lottiSnapshot.docs.map((doc) => doc.data()).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Errore durante il recupero dei dati: $e");
    }
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
                          SizedBox(
                            height: 200,
                            child: SvgPicture.asset(
                              'assets/illustration3.svg',
                              semanticsLabel: 'Illustrazione di una porta',
                              fit: BoxFit.cover,
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
                  if (lotti.isEmpty)
                    Card(
                      margin: const EdgeInsets.all(16),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: kGreen,
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: SvgPicture.asset(
                                  'assets/illustration2.svg',
                                  semanticsLabel: 'Illustrazione di una porta',
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                "Purtroppo al momento non c'è nessun lotto disponibile!",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (lotti.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(
                          top: 16, left: 16, right: 16, bottom: 8),
                      child: Text(
                        "Lista lotti",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kGreenDark,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    for (var lotto in lotti)
                      ScanCard(
                        plantName: lotto['coltura'] ?? 'N/A',
                        lotNumber: lotto['id_lotto'] ?? 'N/A',
                        sowingDate: DateTime.fromMillisecondsSinceEpoch(
                          (lotto['data_semina'] as int),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  LottoDetailPage(lotto: lotto),
                            ),
                          );
                        },
                      ),
                  ]
                ],
              ),
      ),
    );
  }
}

class ScanCard extends StatelessWidget {
  final String plantName;
  final String lotNumber;
  final DateTime sowingDate;
  final VoidCallback? onTap; // Callback per il clic

  const ScanCard({
    super.key,
    required this.plantName,
    required this.lotNumber,
    required this.sowingDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: kGreen,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: kBrownLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.asset(
                  'assets/icon1.svg',
                  semanticsLabel: 'Illustrazione di una porta',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plantName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Lotto $lotNumber",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      "Data semina: ${formatter.format(sowingDate)}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
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
