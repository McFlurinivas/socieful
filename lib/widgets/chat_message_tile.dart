import 'package:flutter/material.dart';

class ChatMessageTile extends StatelessWidget {
  final String message;
  const ChatMessageTile({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.blue, // Change as needed
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(message, style: const TextStyle(color: Colors.white)), // Customize as needed
    );
  }
}
