import "package:flutter/material.dart";
import 'package:ig_clone/screens/forget_password_screen.dart';
import 'package:ig_clone/utils/general_file.dart';

import '../resource/auth.dart';
import '../screens/signup_screen.dart';
import '../utils/showDialog.dart';
import '../widgets/textinput.dart';

import '../reponsive/mobileScreenLayout.dart';
import '../reponsive/responsive_screen.dart';
import '../reponsive/webScreenLayout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void userLogIn() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethod().loginUser(
        email: _emailController.text, password: _passwordController.text);

    if (res == "Successful") {
      //log in user
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) {
        return const ResponsiveScreen(
          mobileScreenLayout: MobileScreen(),
          webScreenLayout: WebScreen(),
        );
      }));
    } else {
      showSnackBar(context, res);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _ScreenDimension = MediaQuery.of(context).size;
    const sizeBox = SizedBox(
      height: 10,
    );
    return Scaffold(
      body: SafeArea(
          child: Container(
              padding: (_ScreenDimension.width > webScreenSize)
                  ? EdgeInsets.symmetric(
                      horizontal: _ScreenDimension.width / 3.5)
                  : const EdgeInsets.symmetric(
                      horizontal: 32,
                    ),
              width: double.infinity,
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(),
                      flex: 2,
                    ),
                    const Text(
                      appTitle,
                      style: TextStyle(color: Colors.white, fontSize: 30),
                    ),
                    sizeBox,
                    TextInputs(
                      txtInputType: TextInputType.emailAddress,
                      hintText: "Enter your Email",
                      txtEditingController: _emailController,
                      type: InputType.email,
                    ),
                    sizeBox,
                    TextInputs(
                      txtInputType: TextInputType.text,
                      hintText: "Enter your Password",
                      txtEditingController: _passwordController,
                      isPassword: true,
                      type: InputType.password,
                    ),
                    sizeBox,
                    InkWell(
                      onTap: userLogIn,
                      child: Container(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                color: Colors.white,
                              ))
                            : const Text("Login"),
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: const ShapeDecoration(
                            color: Colors.pinkAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)))),
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return const ForgetPassword();
                          }));
                        },
                        child: const Text(
                          "forgot your password?",
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontStyle: FontStyle.italic),
                        )),
                    sizeBox,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: const Text("Don't have an account?"),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        InkWell(
                          onTap: () {
                            //navigate to the signup page if pressed
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return const SignUpScreen();
                            }));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: const Text(
                              "Sign up",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pinkAccent),
                            ),
                          ),
                        )
                      ],
                    ),
                    const Center(
                        child: Text("Develop with ❤️  by INIMFON WILLIE"))
                  ],
                ),
              ))),
    );
  }
}
