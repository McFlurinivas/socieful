// chat_messages_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessagesProvider with ChangeNotifier {
  List<DocumentSnapshot> _messages = [];
  bool _isLoading = true;
  Object? _error;

  List<DocumentSnapshot> get messages => _messages;
  bool get isLoading => _isLoading;
  Object? get error => _error;

  void addMessages(List<DocumentSnapshot> newMessages) {
    _messages = newMessages;
    _isLoading = false;
    notifyListeners();
  }

  void addMessage(DocumentSnapshot newMessage) {
    _messages.insert(0, newMessage);
    notifyListeners();
  }

  void setError(Object error) {
    _error = error;
    notifyListeners();
  }
}
