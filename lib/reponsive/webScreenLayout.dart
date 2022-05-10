import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";

import '../screens/addpost_screen.dart';
import '../screens/feed_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/search_screen.dart';
import '../utils/general_file.dart';

class WebScreen extends StatefulWidget {
  const WebScreen({Key? key}) : super(key: key);

  @override
  State<WebScreen> createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen> {
  int _page = 0;
  late PageController pageController;

  void navigationTapper(int page) {
    pageController.jumpToPage(page);
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController(); //assigning to a pagecontroller instance
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void pageChanger(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          appTitle,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.pink),
        ),
        actions: [
          IconButton(
              onPressed: () {
                navigationTapper(0);
              },
              icon: const Icon(Icons.home)),
          IconButton(
            onPressed: () {
              navigationTapper(1);
            },
            icon: Icon(Icons.search),
          ),
          IconButton(
              onPressed: () {
                navigationTapper(2);
              },
              icon: Icon(Icons.photo_camera_rounded)),
          IconButton(
              onPressed: () {
                navigationTapper(3);
              },
              icon: Icon(Icons.person))
        ],
      ),
      body: PageView(
        children: [
          const FeedScreen(),
          const SearchScreen(),
          const AddPostScreen(),
          // BookMarkScreen(),
          ProfileScreen(
            userId: FirebaseAuth.instance.currentUser!.uid,
          ), //using the username id from firebase to ensure we can ....
        ],
        physics:
            const NeverScrollableScrollPhysics(), //stop the screen from scrolling sideways
        controller: pageController,
        onPageChanged: pageChanger,
      ),
    );
  }
}
