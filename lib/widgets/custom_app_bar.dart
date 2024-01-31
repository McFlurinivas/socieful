// custom_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:socieful/utils/constants.dart'; // Ensure this import points to your constants file where AppColors is defined

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CustomAppBar({
    Key? key,
    this.title = '',
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title.isNotEmpty ? Text(title) : Image.asset('assets/images/logo.jpg'),
      backgroundColor: AppColors.globalColor, // Use your global color here
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(5), bottomLeft: Radius.circular(5)),
      ),
      leading: IconButton(
        icon: const Icon(Icons.menu),
        tooltip: 'Menu Icon',
        onPressed: () {
          
        },
      ),
      actions: actions,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); 
}
