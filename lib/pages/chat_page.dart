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
    if (_messageController.text.trim().isNotEmpty && _userId != null) {
      await _firebaseService.sendMessage(
          _userId!, _messageController.text.trim());
      _messageController.clear();
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
                        return const Center(child: Text('Chat with us and say no to depression'));
                      }

                      final messages = snapshot.data!;
                      return ListView.builder(
                        itemCount: messages.length,
                        reverse: true,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 10),
                        itemBuilder: (context, index) {
                          var messageData =
                              messages[index].data() as Map<String, dynamic>;
                          var messageText = messageData[
                              'text']; // Adjust based on your data structure
                          return ChatMessageTile(message: messageText);
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
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.btnColor),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
