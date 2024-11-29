import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:growmate_web/vivaio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

Future<void> login(BuildContext context) async {
  try {
    final UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );

    // Salva l'UID dell'utente in SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', userCredential.user!.uid);

    // Naviga alla pagina Vivaio
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => VivaioScreen()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Icon(
                      Icons.arrow_back_ios,
                      size: 28,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.height * 0.1,
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: SvgPicture.asset('assets/logo.svg'),
                ),
                const VerticalDivider(
                  color: Colors.grey,
                  thickness: 1,
                ),
                Text(
                  "Accesso",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text(
                    "Accesso",
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Email',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => login(context),
                    child: Text(
                      'Login',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}