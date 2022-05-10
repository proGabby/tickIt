import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ig_clone/models/users_model.dart';
import 'package:ig_clone/providers/user_provider.dart';
import "package:provider/provider.dart";

import '../utils/general_file.dart';

class ResponsiveScreen extends StatefulWidget {
  final Widget webScreenLayout;
  final Widget mobileScreenLayout;
  const ResponsiveScreen(
      {Key? key,
      required this.webScreenLayout,
      required this.mobileScreenLayout})
      : super(key: key);

  @override
  State<ResponsiveScreen> createState() => _ResponsiveScreenState();
}

class _ResponsiveScreenState extends State<ResponsiveScreen> {
  futureFunct() async {
    UserProvider _userProvider =
        Provider.of<UserProvider>(context, listen: false);
    await _userProvider.refreshUserData();
  }

  @override
  void initState() {
    super.initState();
    //invoke the function to fetch the data
    futureFunct();
  }

  @override
  Widget build(BuildContext context) {
    //LayoutBuilder built in flutter widget for making layouts

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > webScreenSize) {
        return widget.webScreenLayout;
      }
      return widget.mobileScreenLayout;
    });
  }
}
