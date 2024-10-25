import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'resetpassword.dart';
import 'menu.dart';
import 'game.dart';
import 'register.dart';
import 'login.dart';
import 'rules.dart';
import 'statistics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Guessing Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
    );
  }
}
