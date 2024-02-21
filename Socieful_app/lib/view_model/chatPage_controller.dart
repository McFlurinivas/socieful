
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socieful/services/firebase_service.dart';
import 'package:socieful/services/shared_preferences_service.dart';
import 'package:socieful/models/user.dart';
import 'package:socieful/providers/chat_page/chat_message_provider.dart';
import 'package:socieful/providers/chat_page/server_communication_provider.dart';
import 'package:socieful/providers/chat_page/user_provider.dart';

class ChatPageViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  String? userId;
  bool isWaitingForResponse = false;
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();

  ChatPageViewModel() {
    initializeUserId();
  }

  void initializeUserId() async {
    userId = await SharedPreferencesService.getUserId();
    notifyListeners();
  }

  void initMessagesStream(BuildContext context) {
    if (userId == null) return;
    final provider = Provider.of<ChatMessagesProvider>(context, listen: false);
    _firebaseService.messagesStream(userId!).listen((messageList) {
      provider.addMessages(messageList);
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
    });
  }

  Future<void> submitUserInfo(BuildContext context, String name, String email) async {
    try {
      await Provider.of<ServerCommunicationProvider>(context, listen: false)
          .checkServerHealth()
          .timeout(const Duration(seconds: 10));

      String? userId = await _firebaseService.createUser(name, email);
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot create user. Please try again.')),
        );
        return;
      }

      await SharedPreferencesService.saveUserId(userId);
      Provider.of<UserProvider>(context, listen: false)
          .setUser(UserModel(id: userId, name: name, email: email));
      this.userId = userId;
      initMessagesStream(context);
      handleMessage(context, "My name is $name", initialMessage: true);

    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server is not responding. Please try again later.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e. Please try again.')),
      );
    }
    notifyListeners();
  }

  Future<void> handleMessage(BuildContext context, String messageText, {bool initialMessage = false}) async {
    if (isWaitingForResponse || messageText.isEmpty) return;
    isWaitingForResponse = true;
    notifyListeners();

    if (!initialMessage) {
      messageController.clear();
      await _firebaseService.sendMessage(userId!, messageText, fromChatbot: false);
    }

    try {
      final String? reply = await Provider.of<ServerCommunicationProvider>(context, listen: false).postMessage(messageText);
      if (reply != null) {
        await _firebaseService.sendMessage(userId!, reply, fromChatbot: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid response from the server')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error encountered: $e')),
      );
    } finally {
      isWaitingForResponse = false;
      if (!initialMessage) {
        scrollToBottom();
      }
      notifyListeners();
    }
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      final maxScroll = scrollController.position.maxScrollExtent;
      scrollController.animateTo(maxScroll, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void resetChat(BuildContext context) {
    messageController.clear();
    Provider.of<UserProvider>(context, listen: false).clearUser();
    Provider.of<ChatMessagesProvider>(context, listen: false).clearMessages();

    SharedPreferencesService.clearUserData();

    userId = null;
    isWaitingForResponse = false;
    notifyListeners();
  }
}
