import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:socieful/widgets/custom_dialog_box.dart';
import 'package:socieful/widgets/user_info_form.dart';
import '../providers/chat_page/chat_message_provider.dart';
import '../providers/chat_page/server_communication_provider.dart';
import '../services/shared_preferences_service.dart';
import '../models/user.dart';
import '../providers/chat_page/user_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_app_bar.dart';
import '../services/firebase_service.dart';
import '../widgets/chat_message_tile.dart';
import 'package:intl/intl.dart';
import '../widgets/date_separator.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  String? _userId;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isWaitingForResponse = false;

  @override
  void initState() {
    super.initState();
    _initializeUserId();
  }

  void _initializeUserId() async {
    final userId = await SharedPreferencesService.getUserId();
    if (userId != null) {
      setState(() => _userId = userId);
      _initMessagesStream();
    } else {
      _promptForUserInfo();
    }
  }

  void _initMessagesStream() {
    if (_userId == null) return;
    final provider = Provider.of<ChatMessagesProvider>(context, listen: false);
    _firebaseService.messagesStream(_userId!).listen((messageList) {
      provider.addMessages(messageList);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });
  }

  void _promptForUserInfo() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CustomDialog(
        title: const Text('Enter your information'),
        content: UserInfoForm(
          formKey: _formKey,
          nameController: nameController,
          emailController: emailController,
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Submit'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
                _submitUserInfo(nameController.text, emailController.text);
              }
            },
          ),
        ],
      ),
    );

    if (result != true && mounted) {
      showSnackBar('User information is required to use the chat.', context);
      Navigator.of(context).pop();
    }
  }

  void _submitUserInfo(String name, String email) async {
    try {
      await Provider.of<ServerCommunicationProvider>(context, listen: false)
          .checkServerHealth()
          .timeout(const Duration(seconds: 10));

      String? userId = await _firebaseService.createUser(name, email);
      if (userId == null) {
        if (mounted) {
          showSnackBar('Cannot create user. Please try again.', context);
        }
        return;
      }

      await SharedPreferencesService.saveUserId(userId);
      if (mounted) {
        Provider.of<UserProvider>(context, listen: false)
            .setUser(UserModel(id: userId, name: name, email: email));
        setState(() => _userId = userId);
        _initMessagesStream();

        _handleMessage("My name is $name");
      }
    } on TimeoutException {
      if (mounted) {
        showSnackBar(
            'Server is not responding. Please try again later.', context);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showSnackBar('An error occurred: $e. Please try again.', context);
      }
    }
  }

  Future<void> _handleMessage(String messageText,
      {bool initialMessage = false}) async {
    if (_isWaitingForResponse || messageText.isEmpty) return;
    setState(() => _isWaitingForResponse = true);

    if (!initialMessage) {
      _messageController.clear();
      await _firebaseService.sendMessage(_userId!, messageText,
          fromChatbot: false);
    }

    try {
      if (!context.mounted) return;
      final String? reply =
          await Provider.of<ServerCommunicationProvider>(context, listen: false)
              .postMessage(messageText);
      if (reply != null) {
        await _firebaseService.sendMessage(_userId!, reply, fromChatbot: true);
      } else {
        if (context.mounted) {
          showSnackBar('Invalid response from the server', context);
        }
      }
    } catch (e) {
      if (!mounted) return;
      showSnackBar('Error encountered: $e', context);
    } finally {
      if (mounted) {
        setState(() {
          _isWaitingForResponse = false;
        });
        if (!initialMessage) {
          _scrollToBottom();
        }
      }
    }
  }

  void _terminateChat() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: const Text('Chat Ended'),
          content: const Text(
              'Would you like to proceed to the psychiatrist or start a new chat?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Consult a Psychiatrist?'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('New Chat'),
              onPressed: () {
                _resetChat();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetChat() {
    _messageController.clear();
    Provider.of<UserProvider>(context, listen: false).clearUser();
    Provider.of<ChatMessagesProvider>(context, listen: false).clearMessages();

    SharedPreferencesService.clearUserData();

    setState(() {
      _userId = null;
      emailController.clear();
      nameController.clear();
      _isWaitingForResponse = false;
    });
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(maxScroll,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    _userId = userProvider.user?.id ?? _userId;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        actions: <IconButton>[
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _terminateChat,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _userId == null
                ? const Center(child: CircularProgressIndicator())
                : Consumer<ChatMessagesProvider>(
                    builder: (_, provider, __) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.error != null) {
                        return Text('Error: ${provider.error}');
                      }

                      if (provider.messages.isEmpty) {
                        return const Center(
                            child:
                                Text('Chat with us and say no to depression'));
                      }

                      final messages = provider.messages;
                      List<dynamic> itemsWithDates = [];
                      DateTime? lastDate;

                      for (var messageSnapshot in messages.reversed) {
                        var messageData =
                            messageSnapshot.data() as Map<String, dynamic>;
                        Timestamp? timestamp = messageData['timestamp'];
                        if (timestamp != null) {
                          DateTime messageDate = timestamp.toDate();

                          if (lastDate == null ||
                              !isSameDay(lastDate, messageDate)) {
                            String formattedDate =
                                DateFormat('MMMM d, yyyy').format(messageDate);
                            itemsWithDates.add(formattedDate);
                            lastDate = messageDate;
                          }
                          itemsWithDates.add(messageSnapshot);
                        }
                      }
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: itemsWithDates.length,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 10),
                        itemBuilder: (context, index) {
                          final item = itemsWithDates[index];

                          if (item is String) {
                            return DateSeparator(date: item);
                          } else if (item is DocumentSnapshot) {
                            var messageData =
                                item.data() as Map<String, dynamic>;
                            var messageText = messageData['text'];
                            var fromChatbot =
                                messageData['fromChatbot'] ?? false;
                            var timestamp =
                                (messageData['timestamp'] as Timestamp)
                                    .toDate();
                            return ChatMessageTile(
                              message: messageText,
                              fromChatbot: fromChatbot,
                              timestamp: timestamp,
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    onSubmitted: (value) {
                      if (!_isWaitingForResponse) {
                        _handleMessage(_messageController.text.trim());
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send,
                      color: _isWaitingForResponse
                          ? Colors.grey
                          : AppColors.btnColor),
                  onPressed: _isWaitingForResponse
                      ? null
                      : () => _handleMessage(_messageController.text.trim()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}