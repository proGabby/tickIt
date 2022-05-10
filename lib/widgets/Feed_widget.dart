import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:ig_clone/resource/firebase_resource.dart';
import 'package:ig_clone/screens/comments_sceen.dart';
import 'package:ig_clone/utils/showDialog.dart';
import "package:intl/intl.dart";
import "package:provider/provider.dart";

import '../providers/user_provider.dart';
import '../widgets/like_animation_widget.dart';

class PostWidget extends StatefulWidget {
  final firebaseSnapshot;
  final Key widgetkey;
  const PostWidget(
      {Key? key, required this.firebaseSnapshot, required this.widgetkey})
      : super(key: key);

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  int commentLength = 0;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  List _bookmarks = [];

  @override
  void didChangeDependencies() {
    fechBookmark(userId);
    getCommentLen();
    super.didChangeDependencies();
  }

  Future<void> fechBookmark(String userId) async {
    try {
      final userData = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .get();
      setState(() {
        _bookmarks = userData.data()!["bookmarks"];
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> getCommentLen() async {
    try {
      final QuerySnapshot commentsData = await FirebaseFirestore.instance
          .collection("posts")
          .doc(widget.firebaseSnapshot["postId"])
          .collection("comments")
          .get();
      setState(() {
        commentLength = commentsData.docs.length;
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  bool isAnimating = false;
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context);
    final theme = Theme.of(context);
    final user = Provider.of<UserProvider>(context).getUser;

    return Container(
      color: theme.primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(children: [
        //Header Section
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage:
                  NetworkImage(widget.firebaseSnapshot["profileImageUrl"]),
              radius: 12,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${widget.firebaseSnapshot["username"]}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            // if (user.id == widget.firebaseSnapshot["userId"])
            IconButton(
                onPressed: () async {
                  await showDialog(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          actions: [
                            Center(
                              child: TextButton(
                                child: const Text("Delete"),
                                onPressed: () async {
                                  await FirebaseMethods().deletePost(
                                      widget.firebaseSnapshot["postId"]);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ],
                        );
                      });
                },
                icon: const Icon(Icons.more_vert_outlined)),
          ],
        ),
        //Image section

        GestureDetector(
          onDoubleTap: () async {
            //implement like post
            await FirebaseMethods().likeAndUnlikePost(
                user.id,
                widget.firebaseSnapshot["likes"],
                widget.firebaseSnapshot["postId"]);
            setState(() {
              isAnimating = true;
            });
          },
          child: Stack(alignment: Alignment.center, children: [
            SizedBox(
              height: deviceSize.size.height * 0.35,
              width: double.infinity,
              child: Image.network(
                widget.firebaseSnapshot["postImage"] as String,
                fit: BoxFit.cover,
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: isAnimating ? 1.0 : 0.0,
              child: LikeAnimation(
                child:
                    const Icon(Icons.favorite, color: Colors.white, size: 100),
                isAnimating: isAnimating,
                duration: const Duration(milliseconds: 400),
                onEnd: () {
                  setState(() {
                    isAnimating = false;
                  });
                },
              ),
            )
          ]),
        ),

        //LIKE AND COMMENT SECTION
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            LikeAnimation(
              isAnimating:
                  (widget.firebaseSnapshot["likes"] as List).contains(user.id),
              isSmallLikeButton: true,
              child: IconButton(
                onPressed: () async {
                  //implement like
                  await FirebaseMethods().likeAndUnlikePost(
                      user.id,
                      widget.firebaseSnapshot["likes"],
                      widget.firebaseSnapshot["postId"]);
                },
                icon:
                    (widget.firebaseSnapshot["likes"] as List).contains(user.id)
                        ? const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )
                        : const Icon(Icons.favorite_border),
              ),
            ),
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                    return CommentScreen(
                      firebaseSnapShot: widget.firebaseSnapshot,
                    );
                  }));
                },
                icon: const Icon(Icons.comment_rounded)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.send)),
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: LikeAnimation(
                  isAnimating:
                      _bookmarks.contains(widget.firebaseSnapshot["postId"]),
                  isSmallLikeButton: true,
                  child: IconButton(
                      icon:
                          _bookmarks.contains(widget.firebaseSnapshot["postId"])
                              ? const Icon(
                                  Icons.bookmark_border,
                                  color: Colors.pink,
                                )
                              : const Icon(Icons.bookmark_add),
                      onPressed: () async {
                        await FirebaseMethods().addOrRemoveBookmark(
                            user.id, widget.firebaseSnapshot["postId"]);
                      }),
                ),
              ),
            )
          ],
        ),

        //DESCRIPTION AND NUMBER OF COMMENTS
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultTextStyle(
                  //Creates a default text style
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(fontWeight: FontWeight.w800),
                  child: Text(
                    "${(widget.firebaseSnapshot["likes"] as List).length}",
                    style: Theme.of(context).textTheme.bodyText2,
                  )),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 8,
                ),
                child: RichText(
                  //to create a multitext paragraph
                  text: TextSpan(
                    style: const TextStyle(color: Colors.white),
                    children: [
                      TextSpan(
                        text: widget.firebaseSnapshot["username"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: "  ${widget.firebaseSnapshot["description"]}",
                      ),
                    ],
                  ),
                ),
              ),
              //view section
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                    return CommentScreen(
                      firebaseSnapShot: widget.firebaseSnapshot,
                    );
                  }));
                },
                child: Container(
                  child: Text(
                    'View all $commentLength comments',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.greenAccent,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                ),
              ),
              //date of post
              Container(
                child: Text(
                  DateFormat.yMMMd()
                      .format(widget.firebaseSnapshot["postDate"].toDate()),
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 4),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
