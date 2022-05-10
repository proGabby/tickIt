import "package:flutter/material.dart";

import 'package:ig_clone/screens/feed_screen.dart';
import 'package:ig_clone/screens/profile_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../screens/addpost_screen.dart';
import '../screens/search_screen.dart';

class MobileScreen extends StatefulWidget {
  const MobileScreen({Key? key}) : super(key: key);

  @override
  State<MobileScreen> createState() => _MobileScreenState();
}

class _MobileScreenState extends State<MobileScreen> {
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
    final theme = Theme.of(context);
    //final user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
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
        controller: pageController,
        onPageChanged: pageChanger,
      ),
      bottomNavigationBar: BottomNavigationBar(
        //TODO implement custom background color for mobile
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: _page == 0 ? theme.primaryColor : theme.iconTheme.color,
              ),
              label: "Feed",
              backgroundColor: theme.primaryColor),
          BottomNavigationBarItem(
              icon: Icon(Icons.search,
                  color:
                      _page == 1 ? theme.primaryColor : theme.iconTheme.color),
              label: "Search",
              backgroundColor: theme.primaryColor),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle,
                  color:
                      _page == 2 ? theme.primaryColor : theme.iconTheme.color),
              label: "add post",
              backgroundColor: theme.primaryColor),
          BottomNavigationBarItem(
              icon: Icon(Icons.person,
                  color:
                      _page == 3 ? theme.primaryColor : theme.iconTheme.color),
              label: "profile",
              backgroundColor: theme.primaryColor),
        ],
        onTap: navigationTapper,
      ),
    );
  }
}
