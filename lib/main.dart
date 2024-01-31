import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'package:socieful/utils/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOCIEFUL',
      theme: ThemeData(
        appBarTheme: AppThemes.appBarTheme,
        primarySwatch: AppColors.globalColor,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
