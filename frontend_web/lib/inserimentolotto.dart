import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:growmate_web/common/colors.dart';
import 'package:growmate_web/common/date_ext.dart';
import 'package:growmate_web/model/lotto.dart';
import 'package:growmate_web/vivaio.dart';
import 'package:loader_overlay/loader_overlay.dart';

class InserimentoLotto extends StatefulWidget {
  InserimentoLotto({super.key});

  @override
  State<InserimentoLotto> createState() => _InserimentoLottoState();
}

class _InserimentoLottoState extends State<InserimentoLotto> {
  final TextEditingController colturaController = TextEditingController();
  final TextEditingController pianteController = TextEditingController();

  final TextEditingController vassoiController = TextEditingController();

  DateTime? dataSemina;
  DateTime? dataConsegna;

  Future<void> _salvaLotto(BuildContext context) async {
    try {
      context.loaderOverlay.show();

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        showBanner('Utente non trovato');
        context.loaderOverlay.hide();
        return;
      }

      final coltura = colturaController.text;
      final piante = int.tryParse(pianteController.text) ?? 0;
      final vassoi = int.tryParse(vassoiController.text) ?? 0;

      if (coltura.isEmpty || dataSemina == null || dataConsegna == null) {
        showBanner('Compilare tutti i campi');
        context.loaderOverlay.hide();
        return;
      }

      final userQuery = await FirebaseFirestore.instance
          .collection('Utenti')
          .where('UID', isEqualTo: user.uid)
          .get();

      if (userQuery.docs.isEmpty) {
        showBanner('Utente non trovato');
        context.loaderOverlay.hide();
        return;
      }

      final vivaioId = userQuery.docs.first['vivaio'];

      final vivaioQuery = await FirebaseFirestore.instance
          .collection('vivaio')
          .where('vivaio_id', isEqualTo: vivaioId)
          .get();

      if (vivaioQuery.docs.isEmpty) {
        showBanner('Vivaio non trovato');
        context.loaderOverlay.hide();
        return;
      }

      final vivaioDoc = vivaioQuery.docs.first;
      final vivaioRef =
          FirebaseFirestore.instance.collection('vivaio').doc(vivaioDoc.id);

      final counterRef = FirebaseFirestore.instance
          .collection('Counters')
          .doc('lotto_counter');
      final counterSnapshot = await counterRef.get();

      int nextId = 1;
      if (counterSnapshot.exists) {
        nextId = counterSnapshot['current'] + 1;
      }

      await counterRef.set({'current': nextId});

      await FirebaseFirestore.instance
          .collection('Lotto')
          .doc(nextId.toString())
          .set(Lotto(
            idLotto: nextId,
            coltura: coltura,
            dataSemina: dataSemina!,
            dataConsegna: dataConsegna!,
            piante: piante,
            vassoi: vassoi,
          ).toJson());

      print("Lotto salvato con successo con ID: ${nextId.toString()}");
      showBanner('Lotto salvato con successo');

      await vivaioRef.update({
        'lotti': FieldValue.arrayUnion([nextId]),
      });

      if (context.mounted) {
        context.loaderOverlay.hide();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VivaioScreen()),
        );
      }
    } catch (e) {}
  }

  void showBanner(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBrownLight,
      appBar: AppBar(
        title: const Text('Inserimento Lotto'),
        backgroundColor: kGreenDark,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: colturaController,
              decoration: InputDecoration(
                labelStyle: TextStyle(color: kGreenDark),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kGreenDark),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: kGreenDark,
                    width: 2,
                  ),
                ),
                labelText: 'Coltura',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pianteController,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                FilteringTextInputFormatter.allow(RegExp(r'^[1-9][0-9]{0,5}$')),
              ],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelStyle: TextStyle(color: kGreenDark),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kGreenDark),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: kGreenDark,
                    width: 2,
                  ),
                ),
                labelText: 'Numero di piante',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: vassoiController,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                FilteringTextInputFormatter.allow(RegExp(r'^[1-9][0-9]{0,5}$')),
              ],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelStyle: TextStyle(color: kGreenDark),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kGreenDark),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: kGreenDark,
                    width: 2,
                  ),
                ),
                labelText: 'Numero di vassoi',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    color: kBrownLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: kGreenDark),
                    ),
                    child: InkWell(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2018),
                          lastDate: DateTime.now(),
                        );

                        if (pickedDate != null) {
                          setState(() {
                            dataSemina = pickedDate;
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            "Data semina: ${dataSemina != null ? dataSemina?.formatDate() : 'Click per selezionare'}"),
                      ),
                    ),
                  ),
                  Card(
                    color: kBrownLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: kGreenDark),
                    ),
                    child: InkWell(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2050),
                        );

                        if (pickedDate != null) {
                          setState(() {
                            dataConsegna = pickedDate;
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            "Data consegna: ${dataConsegna != null ? dataConsegna?.formatDate() : 'Click per selezionare'}"),
                      ),
                    ),
                  ),
                ],
              ),
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
