import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa FirebaseAuth
import 'package:growmate_web/firebase_options.dart';
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
    return const MaterialApp(
      home: AuthWrapper(), // Modificato per includere il controllo autenticazione
    );
  }
}

// Questa classe gestisce la logica di reindirizzamento in base all'autenticazione
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Ottiene l'utente attualmente autenticato
    final User? user = FirebaseAuth.instance.currentUser;

    // Se l'utente è autenticato, reindirizza a VivaioScreen, altrimenti alla schermata iniziale
    if (user != null) {
      return const VivaioScreen(); // Schermata principale per l'utente autenticato
    } else {
      return const App(); // Schermata iniziale per l'utente non autenticato
    }
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
            child: Row(
              children: [
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
                  padding: EdgeInsets.only(left: 4.0),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Login(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Login(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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
        ],
      ),
    );
  }
}
