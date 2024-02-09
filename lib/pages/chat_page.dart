import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:socieful/widgets/custom_dialog_box.dart';
import 'package:socieful/widgets/user_info_form.dart';
import '../providers/chat_message_provider.dart';
import '../services/shared_preferences_service.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_app_bar.dart';
import '../services/firebase_service.dart';
import '../widgets/chat_message_tile.dart';
import 'package:http/http.dart' as http;
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
    print("Initializing user ID: $userId");
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
    if (name.isEmpty || email.isEmpty) return;
    showSnackBar("Checking server and creating user...", context);
    var serverCheckPassed = await checkServerOrCondition();
    if (!serverCheckPassed && mounted) {
      showSnackBar('Cannot proceed due to server', context);
      return;
    }
    String? userId = await _firebaseService.createUser(name, email);
    if (userId == null) {
      if (mounted) {
        showSnackBar('Cannot create user. Try Again!!', context);
      }
      return;
    }
    await SharedPreferencesService.saveUserId(userId);
    if (mounted) {
      Provider.of<UserProvider>(context, listen: false)
          .setUser(UserModel(id: userId, name: name, email: email));
    }
    setState(() => _userId = userId);
    _initMessagesStream();

    // After user is successfully created and initialized, send a welcome message.
    _handleMessage(
        "My name is $name"); // Call the function with the user's name
  }

  Future<bool> checkServerOrCondition() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.27.132:5000/health'));
      if (response.statusCode == 200) {
        // Server is running
        return true;
      }
      return false;
    } catch (e) {
      // Handle the error, perhaps by logging it or setting a state variable
      return false;
    }
  }

  Future<void> _handleMessage(String messageText,
      {bool initialMessage = false}) async {
    if (_isWaitingForResponse || messageText.isEmpty) return;
    setState(() => _isWaitingForResponse = true);

    // If it's the initial message, we don't need to clear the text field or send the user's message to Firebase
    if (!initialMessage) {
      _messageController.clear();
      await _firebaseService.sendMessage(_userId!, messageText,
          fromChatbot: false);
    }

    try {
      final response = await http
          .post(
            Uri.parse('http://192.168.27.132:5000/chat'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'message': messageText,
            }),
          )
          .timeout(const Duration(seconds: 7));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        if (responseBody.containsKey('reply')) {
          await _firebaseService.sendMessage(_userId!, responseBody['reply'],
              fromChatbot: true);
        } else {
          if (mounted) {
            showSnackBar('Invalid response from the server', context);
          }
        }
      } else {
        if (!mounted) return;
        showSnackBar('Error from server: ${response.statusCode}', context);
      }
    } on TimeoutException {
      if (!mounted) return;
      showSnackBar('Couldn\'t connect to the server: Timeout', context);
    } catch (e) {
      if (!mounted) return;
      showSnackBar('Error encountered: $e', context);
    } finally {
      if (mounted) {
        setState(() {
          _isWaitingForResponse = false;
        });
        // Only scroll to bottom if it's not the initial message
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
                // Add your logic here
                Navigator.of(context).pop();
              },
            ),
            TextButton(
            child: const Text('New Chat'),
            onPressed: () {
              // Clearing user data and navigating back to home or restarting chat
              _resetChat();
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(context).pop(); // Go back to home page or previous page
              // If you have a specific home page to navigate to, use Navigator.pushReplacement or Navigator.popUntil
            },
          ),
          ],
        );
      },
    );
  }

  void _resetChat() {
  // Clear local user info and messages
  _messageController.clear();
  Provider.of<UserProvider>(context, listen: false).clearUser();
  Provider.of<ChatMessagesProvider>(context, listen: false).clearMessages();

  SharedPreferencesService.clearUserData(); 

  // Reset local state variables if needed
  setState(() {
    _userId = null;
    emailController.clear();
    nameController.clear();
    _isWaitingForResponse = false;
    // Any other state reset you need
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
                            // It's a date separator
                            return DateSeparator(date: item);
                          } else if (item is DocumentSnapshot) {
                            // It's a message
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
                    maxLines: null, // Allow the input to expand vertically
                    keyboardType: TextInputType.multiline,
                    onSubmitted: (value) {
                      if (!_isWaitingForResponse) {
                        _handleMessage(_messageController.text.trim());
                      }
                    }, // Facilitates line breaks for long messages
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
