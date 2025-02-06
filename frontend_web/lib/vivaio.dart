import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';
import 'package:growmate_web/common/colors.dart';
import 'package:growmate_web/inserimentodip.dart';
import 'package:growmate_web/inserimentolotto.dart';
import 'package:growmate_web/model/lotto.dart';
import 'package:growmate_web/main.dart';

class VivaioScreen extends StatefulWidget {
  static const String routeName = "vivaio";

  const VivaioScreen({super.key});

  @override
  _VivaioScreenState createState() => _VivaioScreenState();
}

class _VivaioScreenState extends State<VivaioScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = true;
  List<Lotto> lotti = [];

  Future<void> _fetchUserLotti() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final userDoc = await _firestore
          .collection('Utenti')
          .where('UID', isEqualTo: user.uid)
          .get();

      if (userDoc.docs.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final vivaioId = userDoc.docs.first['vivaio'];

      final vivaioDoc = await _firestore
          .collection('vivaio')
          .where('vivaio_id', isEqualTo: vivaioId)
          .get();

      if (vivaioDoc.docs.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final List<dynamic> lottiIds = vivaioDoc.docs.first['lotti'];

      final lottiSnapshot = await _firestore
          .collection('Lotto')
          .where('id_lotto', whereIn: lottiIds)
          .get();
      try {
        lottiSnapshot.docs.map((doc) => doc.data());
        lotti = lottiSnapshot.docs
            .map((doc) => doc.data())
            .map((l) => Lotto.fromJson(l))
            .toList();
      } catch (e) {
        print(e);
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserLotti();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEFADF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kGreenDark,
        leading: SvgPicture.asset('assets/icon1.svg'),
        centerTitle: false,
        title: const Text(
          "Benvenuto nel tuo vivaio",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Inserimentodip(),
                ),
              );
            },
            icon: const Icon(Icons.person, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              _auth.signOut().then((_) =>
                  Navigator.of(context).pushReplacementNamed(App.routeName));
            },
            icon: const Icon(Icons.logout, color: Colors.white),
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
                  padding: EdgeInsets.only(top: 16.0, left: 16, right: 16),
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
                      : ListView.separated(
                          itemCount: lotti.length,
                          padding: EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final lotto = lotti[index];
                            return ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                ),
                              ),
                              leading: const Icon(Icons.grass,
                                  color: Color(0xFF5F6C37)),
                              title: Text(
                                lotto.coltura,
                                style: const TextStyle(fontSize: 16),
                              ),
                              subtitle: Text(
                                "${lotto.piante} piante in ${lotto.vassoi} vassoi",
                                style: const TextStyle(fontSize: 14),
                              ),
                              onTap: () {},
                            );
                          },
                          separatorBuilder: (context, index) => SizedBox(
                            height: 16,
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kBrownAccent,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (_) => InserimentoLotto(),
                ),
              )
              .then((_) => _fetchUserLotti());
        },
        icon: const Icon(Icons.add),
        label: const Text("Aggiungi lotto"),
      ),
    );
  }
}
