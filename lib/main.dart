import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socieful/providers/chat_message_provider.dart';
import 'package:socieful/providers/user_provider.dart';
import 'pages/chat_page.dart';
import 'pages/home_page.dart';
import 'splash_screen.dart';
import 'package:socieful/utils/constants.dart';

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
      ],
      child: MaterialApp(
        /*routes: {
          '/home': (context) => const HomePage(),
          '/chat': (context) => const ChatPage(),
        },*/
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
