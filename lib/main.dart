import 'package:flutter/material.dart';

import 'splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'SOCIEFUL',
      color: Color.fromRGBO(255, 173, 173, 1),
      home: SplashScreen(), 
      debugShowCheckedModeBanner: false,
    );
  }
}