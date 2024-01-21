import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:socieful/chat_page.dart';
import 'package:socieful/helpline_page.dart';
import 'package:socieful/progress_page.dart';
import 'package:socieful/tips_page.dart';

class Choice {
  const Choice({required this.title, required this.icon});
  final String title;
  final IconData icon;
}

const List<Choice> choices = <Choice>[
  Choice(title: 'Tips', icon: Icons.lightbulb),
  Choice(title: 'Chat with Us', icon: Icons.chat),
  Choice(title: 'Track your progress', icon: Icons.track_changes),
  Choice(title: 'Helpline', icon: Icons.phone)
];

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({Key? key, required this.choice, required this.onPressed})
      : super(key: key);
  final Choice choice;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Card(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25))),
        elevation: 5.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(choice.icon, size: 50.0),
              const SizedBox(height: 10.0),
              Text(
                choice.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key, required this.choices}) : super(key: key);
  final List<Choice> choices;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/logo.jpg'),
        backgroundColor: const Color.fromRGBO(255, 175, 175, 1),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(5), bottomLeft: Radius.circular(5)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Menu Icon',
          onPressed: () {},
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.width,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: choices.length,
            itemBuilder: (context, index) {
              return SizedBox(
                height: 200,
                width: 200,
                child: ChoiceCard(
                  choice: choices[index],
                  onPressed: () {
                    switch (index) {
                      case 0:
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TipsPage()));
                        break;
                      case 1:
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ChatPage()));
                        break;
                      case 2:
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProgressPage()));
                        break;
                      case 3:
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HelplinePage()));
                        break;  
                      default:
                    }
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
