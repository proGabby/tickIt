import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:uuid/uuid.dart';

class StorageMethod {
  final FirebaseStorage _fireStorage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadImageToStorage(
      String path, Uint8List file, bool isPost) async {
    //create a storage bucket for each user
    Reference ref =
        _fireStorage.ref().child(path).child(_auth.currentUser!.uid);

    //create another ref with specail id for every userid if it ispost is true
    if (isPost) {
      String id = const Uuid().v1();
      ref = ref.child(id);
    }

    UploadTask uploadTask =
        ref.putData(file); //using putData since it is a Uint8List file
    TaskSnapshot snapshot = await uploadTask;

    String downloadedUrl = await snapshot.ref.getDownloadURL();

    return downloadedUrl;
  }
}
