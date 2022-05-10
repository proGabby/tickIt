import "package:flutter/material.dart";
import 'package:ig_clone/models/users_model.dart';
import 'package:ig_clone/resource/auth.dart';

class UserProvider with ChangeNotifier {
  UserClass? _user;

  UserClass get getUser {
    return _user!;
  }

  Future<void> refreshUserData() async {
    UserClass user = await AuthMethod().setUserData();

    _user = user;
    notifyListeners();
  }
}
