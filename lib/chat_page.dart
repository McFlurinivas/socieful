import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Image.asset('assets/images/logo.jpg'),
          backgroundColor: const Color.fromRGBO(255, 175, 175, 1),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(5),
                bottomLeft: Radius.circular(5)),
          ),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Menu Icon',
            onPressed: () {},
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: Stack(
          children: [
            const Center(child: Text('How can I help you ?')),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: TextField(
                    keyboardType: TextInputType.text,
                    textAlign: TextAlign.start,
                    cursorColor: Colors.black,
                    autofocus: false,
                    style: const TextStyle(fontSize: 16.4, color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "Share....",
                      suffixIcon: const Icon(Icons.upload, color: Colors.black),
                      hintStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40.0),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40.0),
                        borderSide: const BorderSide(
                          color: Colors.black,
                        ),
                      ),
                      fillColor: Colors.white,
                    )),
              ),
            ),
          ],
        ));
  }
}
