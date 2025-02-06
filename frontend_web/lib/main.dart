import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:growmate_web/common/colors.dart';
import 'package:growmate_web/register.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:rive/rive.dart';
import 'firebase_options.dart';
import 'package:growmate_web/login.dart';
import 'package:growmate_web/vivaio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting();
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
      theme: ThemeData.light(useMaterial3: true).copyWith(
        primaryColor: kGreenDark,
      ),
      routes: {
        App.routeName: (context) => LoaderOverlay(child: const App()),
        Login.routeName: (context) => const Login(),
        VivaioScreen.routeName: (context) =>
            LoaderOverlay(child: const VivaioScreen()),
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
      backgroundColor: kBrownLight,
      body: Stack(
        children: [
          RiveAnimation.asset(
            'assets/anim.riv',
            fit: BoxFit.cover,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: SizedBox(
                    height: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Accedi per gestire il tuo vivaio",
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: kGreenDark,
                                    ),
                              ),
                              const Padding(padding: EdgeInsets.only(top: 16)),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed(Login.routeName);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kBrownAccent,
                                  foregroundColor: Colors.white,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Accedi',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
