import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socieful/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
        const Duration(seconds: 2),
        () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const HomePage(
                      choices: choices,
                    ))));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color.fromRGBO(255, 173, 173, 1),
        child: Image.asset('assets/images/logo.jpg'));
  }
}
