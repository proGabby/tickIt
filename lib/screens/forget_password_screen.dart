import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ig_clone/resource/auth.dart';

import '../utils/general_file.dart';
import '../utils/showDialog.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  late TextEditingController _emailController;
  String emailAddress = "";
  late TextEditingController _newPasswordController;
  late TextEditingController _resetCodeController;

  @override
  void initState() {
    _emailController = TextEditingController();
    _newPasswordController = TextEditingController();
    _resetCodeController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void onSubmitEmail(String email) async {
    _emailController.text = "";
    try {
      await AuthMethod().resetPassword(email);
      showSnackBar(context, "reset code sent to your email");
    } catch (e) {
      if (e == FirebaseAuthException(code: "auth/invalid-email")) {
        showSnackBar(context, "Invalid email - Please provide a valid email");
      } else {
        showSnackBar(context, "Error Occur - please try again");
      }
    }
  }

  void onResetPassword(String resetPin, String newUserPin) {
    _emailController.text = "";
    _resetCodeController.text = "";
    _newPasswordController.text = "";
    try {
      AuthMethod().passwordReset(resetPin, newUserPin);
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final _ScreenDimension = MediaQuery.of(context).size;

    return Scaffold(
        body: SafeArea(
            child: Container(
      padding: (_ScreenDimension.width > webScreenSize)
          ? EdgeInsets.symmetric(horizontal: _ScreenDimension.width / 3.5)
          : const EdgeInsets.symmetric(
              horizontal: 32,
            ),
      width: double.infinity,
      child: Center(
        child: Column(
          children: [
            Flexible(
              child: Container(),
              flex: 2,
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText: "Enter your email",
                hintStyle: const TextStyle(color: Colors.pinkAccent),
                suffix: IconButton(
                    onPressed: () {
                      return onSubmitEmail(_emailController.text);
                    },
                    icon: const Icon(Icons.send)),
              ),
              controller: _emailController,
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Back to Login")),
            const SizedBox(
              height: 60,
            )
          ],
        ),
      ),
    )));
  }
}
