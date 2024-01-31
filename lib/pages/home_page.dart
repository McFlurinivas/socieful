import 'package:flutter/material.dart';
import 'package:socieful/widgets/custom_app_bar.dart';
import '../models/choice.dart';
import '../widgets/choice_card.dart';
import '../utils/constants.dart';
import 'chat_page.dart';
import 'helpline_page.dart';
import 'progress_page.dart';
import 'tips_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  void _navigateToSelectedPage(BuildContext context, int index) {
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
  }

  @override
  Widget build(BuildContext context) {
    const List<Choice> choices = [
      Choice(title: 'Tips', icon: Icons.lightbulb),
      Choice(title: 'Chat with Us', icon: Icons.chat),
      Choice(title: 'Track your progress', icon: Icons.track_changes),
      Choice(title: 'Helpline', icon: Icons.phone),
    ];

    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: AppColors.white,
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.width,
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: choices.length,
            itemBuilder: (context, index) {
              return ChoiceCard(
                choice: choices[index],
                onPressed: () => _navigateToSelectedPage(context, index),
              );
            },
          ),
        ),
      ),
    );
  }
}
