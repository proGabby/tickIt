import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:cloud_firestore/cloud_firestore.dart';

class PostClass {
  final String username;
  final String description;
  final String userId;
  final String postId;
  final DateTime postDate;
  final String postImage;
  final String profileImageUrl;
  final likes;

  PostClass(
      {required this.username,
      required this.description,
      required this.postDate,
      required this.postImage,
      required this.postId,
      required this.profileImageUrl,
      required this.likes,
      required this.userId});

  Map<String, dynamic> changePostClassToJsonFormat() {
    return {
      "username": username,
      "description": description,
      "postImage": postImage,
      "postDate": postDate,
      "likes": [],
      "profileImageUrl": profileImageUrl,
      "userId": userId,
      "postId": postId,
    };
  }
}
