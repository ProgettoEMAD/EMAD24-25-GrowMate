import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:growmate_web/common/colors.dart';

class RegistraDipendente extends StatelessWidget {
  RegistraDipendente({super.key});

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController cognomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _registraDipendente(BuildContext context) async {
    try {
      // Recupero dei valori dai TextField
      final nome = nomeController.text.trim();
      final cognome = cognomeController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      // Controllo se i campi sono vuoti
      if (nome.isEmpty ||
          cognome.isEmpty ||
          email.isEmpty ||
          password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tutti i campi sono obbligatori.")),
        );
        return;
      }

      // Recupero dell'utente autenticato
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Utente non autenticato.")),
        );
        return;
      }

      // Recupero dell'ID del vivaio associato all'utente autenticato
      final userQuery = await FirebaseFirestore.instance
          .collection('Utenti')
          .where('UID', isEqualTo: user.uid)
          .get();

      if (userQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Nessun vivaio associato trovato per l'utente.")),
        );
        return;
      }

      final vivaioId = userQuery.docs.first['vivaio'];

      // Creazione del dipendente su Firebase Authentication
      final UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final dipendente = userCredential.user;
      if (dipendente == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Errore nella creazione dell'utente dipendente.")),
        );
        return;
      }

      // Salvataggio dei dati del dipendente su Firestore
      await FirebaseFirestore.instance.collection('Utenti').doc(user.uid).set({
        'nome': nome,
        'cognome': cognome,
        'mail': email,
        'UID': dipendente.uid,
        'vivaio': vivaioId, // Associazione con il vivaio
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Dipendente registrato con successo.")),
      );

      // Torna alla schermata precedente
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore durante la registrazione: $e")),
      );
    }
  }

  InputDecoration _getInputDecoration(String label) {
    return InputDecoration(
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
      labelText: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBrownLight,
      appBar: AppBar(
        backgroundColor: kGreenDark,
        foregroundColor: Colors.white,
        title: const Text('Registra Dipendente'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: _getInputDecoration('Nome'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: cognomeController,
              decoration: _getInputDecoration('Cognome'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _getInputDecoration('Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: _getInputDecoration('Password'),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: MaterialButton(
                color: kGreenDark,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onPressed: () {
                  _registraDipendente(context);
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
