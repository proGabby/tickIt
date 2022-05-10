import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/general_file.dart';
import '../widgets/Feed_widget.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: (_screenSize.width < webScreenSize)
          ? AppBar(
              title: const Text(
                appTitle,
                style: TextStyle(
                    color: titleColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              backgroundColor: theme.primaryColor,
              actions: [
                IconButton(
                    onPressed: () {}, icon: const Icon(Icons.messenger_outline))
              ],
            )
          : null,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("posts").snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapShotData) {
          if (snapShotData.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return (_screenSize.width < webScreenSize)
              ? ListView.builder(
                  itemBuilder: (ctx, i) {
                    return PostWidget(
                      firebaseSnapshot: snapShotData.data!.docs[i],
                      widgetkey: ValueKey(snapShotData.data!.docs[i]["postId"]
                          as String), // to ensure deleting and rendering works smoothly
                    );
                  },
                  itemCount: snapShotData.data!.docs.length)
              : Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: _screenSize.width / 5),
                  child: ListView.builder(
                      itemBuilder: (ctx, i) {
                        return PostWidget(
                          firebaseSnapshot: snapShotData.data!.docs[i],
                          widgetkey: ValueKey(snapShotData.data!.docs[i]
                                  ["postId"]
                              as String), // to ensure deleting and rendering works smoothly
                        );
                      },
                      itemCount: snapShotData.data!.docs.length),
                );
        },
      ),
    );
  }
}
