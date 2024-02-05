import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:socieful/widgets/custom_dialog_box.dart';
import 'package:socieful/widgets/user_info_form.dart';
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
  bool _isWaitingForResponse = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUserId();
    });
  }

  void _initializeUserId() async {
    final userId = await SharedPreferencesService.getUserId();
    if (userId != null) {
      setState(() {
        _userId = userId;
      });
    } else {
      _promptForUserInfo();
    }
  }

  void _promptForUserInfo() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomDialog(
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
        );
      },
    );

    if (result == null || !result) {
      if (context.mounted) {
        SnackBarHelper.showSnackbar(
            'User information is required to use the chat.', context);
        Navigator.of(context).pop();
      }
    }
  }

  void _submitUserInfo(String name, String email) async {
    if (name.isNotEmpty && email.isNotEmpty) {
      String? userId = await _firebaseService.createUser(name, email);
      if (userId != null) {
        await SharedPreferencesService.saveUserId(userId);
        if (context.mounted) {
          Provider.of<UserProvider>(context, listen: false)
              .setUser(UserModel(id: userId, name: name, email: email));
        }
        setState(() {
          _userId = userId;
        });
        // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ChatPage()));
      } else {
        if (context.mounted) {
          SnackBarHelper.showSnackbar(
              'Cannot create user. Try Again!!', context);
        }
      }
    }
  }

  void _sendMessage() async {
    if (_isWaitingForResponse) return;
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty && _userId != null) {
      setState(() {
        _isWaitingForResponse = true; // Start waiting for a response
      });
      try {
        await _firebaseService.sendMessage(_userId!, messageText,
            fromChatbot: false);
        _messageController.clear();
        final response = await http.post(
          Uri.parse('http://192.168.27.132:5000/'), // Your Flask server URL
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'message': messageText,
          }),
        );
        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          // Store chatbot's reply in Firestore
          await _firebaseService.sendMessage(_userId!, responseBody['reply'],
              fromChatbot: true);
        } else {
          if (context.mounted) {
            SnackBarHelper.showSnackbar(
                'Couldn\'t connect to the server', context);
          }
        }
      } on SocketException catch (_) {
        await _firebaseService.deleteUser(_userId!);
        await SharedPreferencesService.clearUserData();
        if (context.mounted) {
          SnackBarHelper.showSnackbar(
              'Couldn\'t contact the server. Try again later!!', context);
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          SnackBarHelper.showSnackbar('Error encountered: $e', context);
          Navigator.of(context).pop();
        }
      } finally {
        setState(() {
          _isWaitingForResponse = false;
        });
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
                Navigator.of(context).pop();
                _messageController.clear();
                setState(() {
                  _userId = null;
                });
                emailController.clear();
                nameController.clear();
                _promptForUserInfo();
              },
            ),
          ],
        );
      },
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    _userId = userProvider.user?.id;
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
                : StreamBuilder<List<DocumentSnapshot>>(
                    stream:
                        _firebaseService.messagesStream(_userId!, limit: 20),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child:
                                Text('Chat with us and say no to depression'));
                      }

                      final messages = snapshot.data!;
                      List<dynamic> itemsWithDates = [];
                      DateTime? lastDate;

                      for (var messageSnapshot in messages.reversed) {
                        var messageData =
                            messageSnapshot.data() as Map<String, dynamic>;
                        Timestamp? timestamp = messageData['timestamp'];
                        if (timestamp != null) {
                          DateTime messageDate = timestamp.toDate();

                          if (lastDate == null || !isSameDay(lastDate, messageDate)) {
                            String formattedDate = DateFormat('MMMM d, yyyy').format(messageDate);
                            itemsWithDates.add(formattedDate); 
                            lastDate = messageDate;
                          }
                          itemsWithDates.add(messageSnapshot); 
                        }
                      }
                      return ListView.builder(
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
                            var timestamp = (messageData['timestamp'] as Timestamp).toDate();
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
                        _sendMessage();
                      }
                    }, // Facilitates line breaks for long messages
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send,
                      color: _isWaitingForResponse
                          ? Colors.grey
                          : AppColors.btnColor),
                  onPressed: _isWaitingForResponse ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
