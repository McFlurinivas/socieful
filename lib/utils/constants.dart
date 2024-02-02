import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  static const globalColor = Color.fromRGBO(255, 175, 175, 1);
  static const white = Colors.white;
  static const btnColor = Colors.pinkAccent;
}

class AppThemes {
  static const appBarTheme = AppBarTheme(
    backgroundColor: AppColors.globalColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        bottomRight: Radius.circular(5),
        bottomLeft: Radius.circular(5),
      ),
    ),
    systemOverlayStyle: SystemUiOverlayStyle.light,
  );
}

class SnackBarHelper {
  static void showSnackbar(String txt, BuildContext context) {
    final snackBar = SnackBar(
      content: Text(txt),
      duration: const Duration(seconds: 3), 
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

