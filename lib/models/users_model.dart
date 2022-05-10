import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';

class UserClass {
  final String username;
  final String email;
  final String id;
  final String bio;
  final List followers;
  final List following;
  final List bookmarks;
  final String userPhotoUrl;

  UserClass(
      {required this.username,
      required this.bio,
      required this.email,
      required this.followers,
      required this.following,
      required this.id,
      required this.bookmarks,
      required this.userPhotoUrl});

  Map<String, dynamic> changeToJson() {
    return {
      "username": username,
      "email": email,
      "profilePic": userPhotoUrl,
      "bio": bio,
      "followers": [],
      "following": [],
      "bookmarks": [],
      "id": id,
    };
  }

  static UserClass createUserFromFirebaseDataFormat(
      // use as static so we can call the method without instantiating
      DocumentSnapshot firebaseDocSnapshot) {
    var dataSnapshot = firebaseDocSnapshot.data() as Map<String,
        dynamic>; //.data contains all data return by firebase. it returns a nullable object

    return UserClass(
        username: dataSnapshot["username"],
        bio: dataSnapshot["bio"],
        email: dataSnapshot["email"],
        followers: dataSnapshot["followers"],
        following: dataSnapshot["following"],
        id: dataSnapshot["id"],
        userPhotoUrl: dataSnapshot["profilePic"],
        bookmarks: dataSnapshot["bookmarks"]);
  }
}
