import 'package:flutter/material.dart';
import 'package:socieful/utils/validators.dart';

class UserInfoForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;

  const UserInfoForm({
    Key? key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
  }) : super(key: key);

  @override
  State<UserInfoForm> createState() => _UserInfoFormState();
}

class _UserInfoFormState extends State<UserInfoForm> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            controller: widget.nameController,
            decoration: const InputDecoration(hintText: "Name"),
            validator: (value) => value!.isEmpty ? 'Name cannot be empty' : null,
          ),
          TextFormField(
            controller: widget.emailController,
            decoration: const InputDecoration(hintText: "Email"),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => Validators.validateEmail(value),
          ),
        ],
      ),
    );
  }
}
