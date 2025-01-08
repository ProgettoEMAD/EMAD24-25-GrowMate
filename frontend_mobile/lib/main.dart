import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:growmate/screen/login_page.dart';
import 'package:growmate/screen/home_page.dart';
import 'package:growmate/auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(GrowMate());
}

class GrowMate extends StatelessWidget {
  const GrowMate({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Growmate',
      theme: ThemeData(),
      home: StreamBuilder(
        stream: Auth().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const Home();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
