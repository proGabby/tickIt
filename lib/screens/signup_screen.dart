import 'dart:typed_data';

import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';

import '../resource/auth.dart';
import '../screens/login_screen.dart';
import '../utils/general_file.dart';
import '../utils/showDialog.dart';

import '../reponsive/mobileScreenLayout.dart';
import '../reponsive/responsive_screen.dart';
import '../reponsive/webScreenLayout.dart';
import '../utils/image_picker.dart';
import '../widgets/textinput.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  Uint8List? _providedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() {
      _isLoading = true;
    });
    _formKey.currentState?.validate();
    // if (!validateForm! || _providedImage == null) {
    //   return;
    // }
    final res = await AuthMethod().signUpUser(
      email: _emailController.text,
      password: _passwordController.text,
      username: _userNameController.text,
      bio: _bioController.text,
      file: _providedImage!,
    );
    setState(() {
      _isLoading = false;
    });
    if (res != "successful") {
      showSnackBar(context, res);
    } else {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) {
        return const ResponsiveScreen(
          mobileScreenLayout: MobileScreen(),
          webScreenLayout: WebScreen(),
        );
      }));
    }
  }

  void selectImage() async {
    Uint8List _image = await pickImage(ImageSource.gallery);
    setState(() {
      _providedImage = _image;
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
            ? EdgeInsets.symmetric(horizontal: _ScreenDimension.width / 3.5)
            : const EdgeInsets.symmetric(
                horizontal: 32,
              ),
        width: double.infinity,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Container(),
                flex: 2,
              ),
              //name of app
              const Text(
                appTitle,
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
              sizeBox,
              //show circular avatar of user
              Stack(
                children: [
                  _providedImage == null
                      ? const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blueGrey,
                        )
                      : CircleAvatar(
                          radius: 50,
                          backgroundImage: MemoryImage(_providedImage!),
                        ),
                  PositionedDirectional(
                      start: 25,
                      bottom: 35,
                      child: IconButton(
                        onPressed: selectImage,
                        icon: const Icon(Icons.add_a_photo),
                      )),
                ],
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
                hintText: "Enter your Username",
                txtEditingController: _userNameController,
                type: InputType.username,
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
              TextInputs(
                txtInputType: TextInputType.text,
                hintText: "Enter your bio",
                txtEditingController: _bioController,
                type: InputType.bio,
              ),
              sizeBox,
              InkWell(
                onTap: submit,
                child: Container(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator.adaptive(
                            backgroundColor: Colors.white,
                          ),
                        )
                      : const Text("Sign Up"),
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                      color: Colors.pinkAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)))),
                ),
              ),
              sizeBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: const Text("Have an account already?"),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  InkWell(
                    onTap: () {
                      //navigate to the login page if pressed
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const LoginScreen();
                      }));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: const Text(
                        "Log in",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.pinkAccent),
                      ),
                    ),
                  )
                ],
              ),
              const Center(child: Text("Develop with ❤️  by INIMFON WILLIE"))
            ],
          ),
        ),
      )),
    );
  }
}
