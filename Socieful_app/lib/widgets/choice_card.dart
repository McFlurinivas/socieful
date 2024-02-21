import 'package:flutter/material.dart';
import 'package:socieful/utils/constants.dart';
import '../models/choice.dart';

class ChoiceCard extends StatelessWidget {
  final Choice choice;
  final VoidCallback onPressed;

  const ChoiceCard({
    Key? key,
    required this.choice,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Card(
        color: AppColors.btnColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 5.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(choice.icon, size: 50.0),
              const SizedBox(height: 10.0),
              Text(
                choice.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
