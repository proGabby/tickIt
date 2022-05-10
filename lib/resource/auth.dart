import 'dart:developer';
import 'dart:typed_data';

import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './storage_resource.dart';
import "../models/users_model.dart";

class AuthMethod {
  final FirebaseAuth _auth =
      FirebaseAuth.instance; // createing an instance of auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> signUpUser(
      {required String email,
      required String password,
      required String username,
      required String bio,
      required Uint8List? file}) async {
    String res = "some error occurred";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty ||
          file != null) {
        //register user on firebase
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password:
                password); // firebase will respond with data's saved on credentails variables

        String profilePicUrl = await StorageMethod().uploadImageToStorage(
            "profilePics",
            file!,
            false); //profilePicUrl holds the url of the pic uploaded to firestore

        // log(profilePicUrl);

        //create a user with the data
        UserClass _user = UserClass(
            username: username,
            bio: bio,
            email: email,
            followers: [],
            following: [],
            id: credential.user!.uid,
            userPhotoUrl: profilePicUrl,
            bookmarks: []);

        //save user data in cloub firestore
        await _firestore
            .collection("users")
            .doc(credential.user?.uid)
            .set(_user.changeToJson());
        res = "successful";
      }
    } on FirebaseAuthException catch (error) {
      //TODO: set error message base on firebase auth error
      res = error.toString();
    } catch (error) {
      res = error.toString();
    }
    return res;
  }

  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = "some error occurred";
    try {
      if (email.isEmpty || password.isEmpty) {
        res = "Please no fields should be left empty";
      } else {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "Successful";
      }
    } on FirebaseAuthException catch (error) {
      //TODO:  implement custom error message base on firebase exception
      res = error.toString();
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<UserClass> setUserData() async {
    User currentUser = _auth
        .currentUser!; //a firebase user. Note not an instance of UserClass class

    // DocumentSnapshot<Object?> userData =
    //     await _firestore.collection("users").doc(currentUserId).get();

    DocumentSnapshot<Object?> userData =
        await _firestore.collection("users").doc(currentUser.uid).get();

    if (userData.exists) {
      log(userData.data().toString());
    }

    return UserClass.createUserFromFirebaseDataFormat(userData);
  }

  Future<void> logoutUser() async {
    await _auth.signOut();
  }
}
