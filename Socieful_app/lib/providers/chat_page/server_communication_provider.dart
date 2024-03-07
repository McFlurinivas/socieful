import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ServerCommunicationProvider with ChangeNotifier {//This is the code sending the prompt to chatgpt api
  final String _serverURL = 'your_server_url_here';

  Future<bool> checkServerHealth() async {//Checking if the server is running
    try {
      final response = await http.get(Uri.parse('$_serverURL/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String?> postMessage(String message) async {//posting the message to chatgpt api
    try {
      final response = await http.post(
        Uri.parse('$_serverURL/chat'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'message': message,
        }),
      ).timeout(const Duration(seconds: 7));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody.containsKey('reply')) {
          return responseBody['reply'];
        }
      }
    } on TimeoutException {
      throw Exception('Timeout');
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
    return null;
  }
}
