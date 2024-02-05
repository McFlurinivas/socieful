import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatMessageTile extends StatelessWidget {
  final String message;
  final bool fromChatbot;
  final DateTime timestamp;

  const ChatMessageTile({
    Key? key,
    required this.message,
    required this.fromChatbot,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: fromChatbot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: fromChatbot ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              if (fromChatbot) ...[
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/chat_bot_dp.jpg'),
                ),
                const SizedBox(width: 8), // Add space between avatar and message bubble
              ],
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.6),
                decoration: BoxDecoration(
                  color: fromChatbot ? Colors.grey[300] : Colors.blue[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(message),
              ),
              if (!fromChatbot) ...[
                const SizedBox(width: 8), // Add space between message bubble and avatar
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/user_dp.png'),
                ),
              ],
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 4.0,
              left: fromChatbot ? 48 : 0, // Align timestamp for chatbot message
              right: !fromChatbot ? 48 : 0, // Align timestamp for user message
            ),
            child: Text(
              DateFormat('hh:mm a').format(timestamp),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
