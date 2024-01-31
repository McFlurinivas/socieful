import 'package:flutter/material.dart';
import 'package:socieful/models/choice.dart';
import 'package:socieful/models/helpline.dart';
import 'package:socieful/utils/constants.dart';
import 'package:socieful/widgets/choice_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:socieful/widgets/custom_app_bar.dart';

class HelplinePage extends StatelessWidget {
  const HelplinePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define a list of helpline options
    final List<HelplineOption> helplineOptions = [
      HelplineOption(title: 'Women In Distress', number: '1091'),
      HelplineOption(title: 'Domestic Abuse', number: '181'),
      HelplineOption(title: 'Police', number: '100'),
      HelplineOption(title: 'Student/Child Helpline', number: '1098'),
      HelplineOption(title: 'Ambulance', number: '102'),
    ];

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(),
      body: ListView.builder(
        itemCount: helplineOptions.length,
        itemBuilder: (context, index) {
          final option = helplineOptions[index];
          return ChoiceCard(
            choice: Choice(title: option.title, icon: Icons.call), // Assuming Choice is appropriately defined
            onPressed: () => launch('tel:${option.number}'),
          );
        },
      ),
    );
  }
}
