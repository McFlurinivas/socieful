import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chat_page/chat_message_provider.dart';
import 'providers/chat_page/user_provider.dart';
import 'providers/chat_page/server_communication_provider.dart';
import 'splash_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ChatMessagesProvider()),
        ChangeNotifierProvider(create: (_) => ServerCommunicationProvider()),
      ],
      child: MaterialApp(
        title: 'SOCIEFUL',
        theme: ThemeData(
          appBarTheme: AppThemes.appBarTheme,
          primarySwatch: Colors.pink,
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
