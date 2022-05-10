import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:ig_clone/resource/storage_resource.dart';
import 'package:ig_clone/utils/showDialog.dart';
import 'package:uuid/uuid.dart';

import '../models/post_model.dart';

class FirebaseMethods {
  final FirebaseFirestore _firebaseStorage = FirebaseFirestore.instance;

  Future<String> uploadPostOnFirebase(
      {required Uint8List file,
      required String username,
      required String description,
      required String userId,
      required String profileImage}) async {
    String res = "an error occur";
    try {
      //upload file to firestore and get it url
      String postImageUrl =
          await StorageMethod().uploadImageToStorage("posts", file, true);

      String postId =
          const Uuid().v1(); // Uuid().v1() instance of Uuid dependency..

      PostClass post = PostClass(
        username: username,
        description: description,
        postDate: DateTime.now(),
        postImage: postImageUrl,
        postId: postId,
        profileImageUrl: profileImage,
        likes: [],
        userId: userId,
      );

      //save post to firebase
      _firebaseStorage
          .collection("posts")
          .doc(postId)
          .set(post.changePostClassToJsonFormat());

      res = "successful";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> likeAndUnlikePost(
      String userId, List likes, String postId) async {
    try {
      if (likes.contains(userId)) {
        await _firebaseStorage.collection("posts").doc(postId).update({
          "likes": FieldValue.arrayRemove([
            userId
          ]) // userId passed inside an array because arrayRemove required an array... FieldValue is provided by cloud_firestore package to update field in the database
        });
      } else {
        await _firebaseStorage.collection("posts").doc(postId).update({
          "likes": FieldValue.arrayUnion([userId])
        });
      }
    } on Exception catch (e) {
      // TODO
      log(e.toString());
    }
  }

//postingComment to firebase
  Future<void> postComments(String comments, String postId, String username,
      String userId, String profilePic) async {
    try {
      final commentId = const Uuid().v1();
      if (comments.isNotEmpty) {
        await _firebaseStorage
            .collection("posts")
            .doc(postId)
            .collection("comments")
            .doc(commentId)
            .set({
          "commentId": commentId,
          "comment": comments,
          "postId": postId,
          "commentDate": DateTime.now(),
          "username": username,
          "userId": userId,
          "userProfilePic": profilePic,
        });
      }
    } catch (e) {
      log("error form posting comments" + e.toString());
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firebaseStorage.collection("posts").doc(postId).delete();
    } catch (e) {
      log(e.toString());
    }
  }

  //logic to follow and follower a user
  Future<void> followUser(String userId, String followingId) async {
    try {
      final userDataFromFirebase =
          await _firebaseStorage.collection("users").doc(userId).get();
      List usersYouFollow = userDataFromFirebase.data()!["following"];

      if (usersYouFollow.contains(followingId)) {
        //remove me from his followers
        await _firebaseStorage.collection("users").doc(followingId).update({
          "followers": FieldValue.arrayRemove([userId])
        });

        //remove user from my following
        await _firebaseStorage.collection("users").doc(userId).update({
          "following": FieldValue.arrayRemove([followingId])
        });
      } else {
        await _firebaseStorage.collection("users").doc(followingId).update({
          "followers": FieldValue.arrayUnion([userId])
        });

        await _firebaseStorage.collection("users").doc(userId).update({
          "following": FieldValue.arrayUnion([followingId])
        });
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> addOrRemoveBookmark(String userId, String postId) async {
    final bookMarkData =
        await _firebaseStorage.collection("users").doc(userId).get();

    final List bookmarkList = bookMarkData.data()!["bookmarks"];

    if (!bookmarkList.contains(postId)) {
      await _firebaseStorage.collection("users").doc(userId).update({
        "bookmarks": FieldValue.arrayUnion([postId])
      });
    } else {
      await _firebaseStorage.collection("users").doc(userId).update({
        "bookmarks": FieldValue.arrayRemove([postId])
      });
    }
  }
}
