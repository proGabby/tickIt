import "package:flutter/material.dart";

enum InputType {
  email,
  password,
  bio,
  username,
}

class TextInputs extends StatelessWidget {
  final TextEditingController txtEditingController;
  final TextInputType txtInputType;
  final bool isPassword;
  final String hintText;
  final InputType type;

  const TextInputs({
    Key? key,
    required this.txtInputType,
    required this.hintText,
    this.isPassword = false,
    required this.txtEditingController,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inputBorder =
        OutlineInputBorder(borderSide: Divider.createBorderSide(context));

    return TextFormField(
      controller: txtEditingController,
      keyboardType: txtInputType,
      obscureText: isPassword, //use to make the input visible or not
      //inputDecoration use to decorate a text fild
      decoration: InputDecoration(
          filled: true,
          hintText: hintText,
          border: inputBorder,
          focusedBorder: inputBorder,
          enabledBorder: inputBorder,
          contentPadding: const EdgeInsets.all(5)),
      validator: (value) {
        if (value!.isEmpty) {
          return "Field can't be left empty";
        }
        if (type == InputType.email) {
          if (!value.contains("@") && !value.contains(".")) {
            return "Enter a valid email";
          }
        }
      },
    );
  }
}
