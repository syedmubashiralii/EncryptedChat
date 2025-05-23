import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tea_talks/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Encrypted Chat',
      debugShowCheckedModeBanner: false,
      home: Splash(),
    );
  }
}
