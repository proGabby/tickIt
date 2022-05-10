import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ig_clone/providers/user_provider.dart';
import 'package:ig_clone/resource/firebase_resource.dart';
import 'package:provider/provider.dart';

import '../widgets/comment_widget.dart';

class CommentScreen extends StatefulWidget {
  const CommentScreen({Key? key, required this.firebaseSnapShot})
      : super(key: key);
  final firebaseSnapShot;

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _mediaQuery = MediaQuery.of(context);
    final _theme = Theme.of(context);
    final user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Comments"),
        backgroundColor: _theme.primaryColor,
        centerTitle: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("posts")
            .doc(widget.firebaseSnapShot["postId"])
            .collection("comments")
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> commentData) {
          if (commentData.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
              itemCount: commentData.data!.docs.length,
              itemBuilder: (ctx, index) {
                return CommentBody(
                  commentData: commentData.data!.docs[index],
                );
              });
        },
      ),
      bottomNavigationBar: SafeArea(
          // SafeArea helps to avoid operating UI interferrence
          child: Container(
        height: kToolbarHeight,
        margin: EdgeInsets.only(bottom: _mediaQuery.viewInsets.bottom),
        padding: const EdgeInsets.only(left: 20, right: 10),
        child: Row(
          children: [
            //user profilepic
            CircleAvatar(
              backgroundImage: NetworkImage(user.userPhotoUrl),
              radius: 20,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 10),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Enter your comment as ${user.username}",
                  ),
                  controller: _commentController,
                ),
              ),
            ),
            Container(
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () async {
                  await FirebaseMethods().postComments(
                      _commentController.text,
                      widget.firebaseSnapShot["postId"],
                      user.username,
                      user.id,
                      user.userPhotoUrl);
                  setState(() {
                    _commentController.text = "";
                  });
                },
              ),
            ),
          ],
        ),
      )),
    );
  }
}
