import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:growmate/Screen/Appoggio.dart';
import 'package:growmate/Screen/Login.dart';
import 'package:growmate/Screen/home.dart';
import 'package:growmate/auth.dart';
import 'firebase_options.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
   MyApp({super.key});


   @override
   State<MyApp> createState() => _MyAppState();

}

class _MyAppState extends State<MyApp>{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Growmate',
      theme: ThemeData(),
      home: StreamBuilder(
        stream: Auth().authStateChanges,
        builder: (context, snapshot){
          if(snapshot.hasData){
            return Home();
          }
          else{
            return LoginScreen();
          }
        },
        ),
        );
  }
}