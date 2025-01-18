import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:growmate/auth.dart';
import 'package:growmate/common/colors.dart';
import 'package:growmate/screen/home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  bool _obscurePwd = true;

  Future<void> signIn() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    // Validazione locale prima di tentare l'accesso
    if (_email.text.isEmpty) {
      setState(() {
        _emailError = 'Inserisci un\'email';
      });
      return;
    }
    if (_password.text.isEmpty) {
      setState(() {
        _passwordError = 'Inserisci una password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prova l'accesso con Firebase
      await Auth().signInWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
      );

      // Naviga alla schermata di Home in caso di successo
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Home(),
          ),
        );
      }
    } on FirebaseAuthException catch (error) {
      // Gestione degli errori specifici di Firebase
      setState(() {
        if (error.code == 'user-not-found') {
          _emailError = 'Utente non trovato';
        } else if (error.code == 'wrong-password') {
          _passwordError = 'Password errata';
        } else {
          _passwordError = 'Errore: ${error.message}';
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBrownLight,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height +
              (MediaQuery.of(context).padding.vertical * 2),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: SvgPicture.asset(
                  'assets/illustration1.svg',
                  semanticsLabel: 'Illustrazione di una porta',
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Growmate Login',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: kGreenDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      // Campo email
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.email,
                            color: kBrown,
                          ),
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorText:
                              _emailError, // Mostra l'errore accanto al campo
                        ),
                        onChanged: (_) => setState(() => _emailError = null),
                      ),
                      const SizedBox(height: 20),
                      // Campo password
                      TextField(
                        controller: _password,
                        obscureText: _obscurePwd,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: kBrown,
                          ),
                          suffix: InkWell(
                            child: Icon(
                              _obscurePwd
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: kBrown,
                            ),
                            onTap: () => setState(
                              () {
                                _obscurePwd = !_obscurePwd;
                              },
                            ),
                          ),
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          errorText: _passwordError,
                        ),
                        onChanged: (_) => setState(() => _passwordError = null),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : signIn,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: kBrown,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Accedi',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
