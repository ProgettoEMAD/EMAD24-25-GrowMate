import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:growmate_web/register.dart';
import 'firebase_options.dart';
import 'package:growmate_web/login.dart';
import 'package:growmate_web/vivaio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const Web());
}

class Web extends StatelessWidget {
  const Web({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        App.routeName: (context) => const App(),
        Login.routeName: (context) => const Login(),
        VivaioScreen.routeName: (context) => const VivaioScreen(),
        Register.routeName: (context) => const Register(),
      },
      initialRoute: FirebaseAuth.instance.currentUser != null
          ? VivaioScreen.routeName
          : App.routeName,
    );
  }
}

class App extends StatelessWidget {
  static const String routeName = "app";

  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEFADF), // Imposta il colore di sfondo
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.height * 0.1,
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: SvgPicture.asset('assets/icon1.svg'),
                ),
                const VerticalDivider(
                  color: Colors.grey,
                  thickness: 1,
                ),
                Text(
                  "Tech in full bloom",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  "Hai già un account?",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(Login.routeName);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5F6C37), // Colore dei bottoni
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Accedi',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Accedi per gestire il tuo vivaio",
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Padding(padding: EdgeInsets.only(top: 16)),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(Login.routeName);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5F6C37), // Colore dei bottoni
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Accedi',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}