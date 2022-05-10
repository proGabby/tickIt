import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ig_clone/resource/auth.dart';
import 'package:ig_clone/resource/firebase_resource.dart';
import 'package:ig_clone/screens/login_screen.dart';
import 'package:ig_clone/utils/general_file.dart';

import '../utils/showDialog.dart';
import '../widgets/followbutton_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, required this.userId}) : super(key: key);
  final String userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final userIdFromFirebase = FirebaseAuth.instance.currentUser!.uid;
  var postLen = 0;
  var followers = 0;
  var following = 0;
  var userData = {};
  bool isfollowing = false;
  bool isLoading = false;

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userDataFromFirestore = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .get();

      userData = userDataFromFirestore.data()!;

      var postDataFromFirestore = await FirebaseFirestore.instance
          .collection("posts")
          .where("userId", isEqualTo: userIdFromFirebase)
          .get();

      //get the length of post
      postLen = postDataFromFirestore.docs.length;
      //get the length of followers array as number of followers
      followers = userDataFromFirestore.data()!["followers"].length;

      following = userDataFromFirestore.data()!["following"].length;
      isfollowing = userDataFromFirestore
          .data()!["followers"]
          .contains(userIdFromFirebase);
    } catch (e) {
      showSnackBar(context, e.toString());
      log(e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _screenSize = MediaQuery.of(context).size;
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
                title: Text(userData["username"]),
                centerTitle: false,
                backgroundColor: theme.primaryColor,
                actions: [
                  IconButton(
                      icon: const Icon(Icons.logout_rounded),
                      onPressed: () async {
                        await AuthMethod().logoutUser();
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const LoginScreen()));
                      })
                ]),
            body: ListView(padding: const EdgeInsets.all(20), children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 5, right: 5, top: 10, bottom: 10),
                child: Column(
                  children: [
                    Padding(
                      padding: (_screenSize.width < webScreenSize)
                          ? const EdgeInsets.all(8.0)
                          : EdgeInsets.symmetric(
                              horizontal: _screenSize.width / 4),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                NetworkImage(userData["profilePic"]),
                            radius: 50.0,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    profileInfo(postLen, "posts"),
                                    profileInfo(followers, "followers"),
                                    profileInfo(following, "following"),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: (userIdFromFirebase == widget.userId)
                                      ? FollowButton(
                                          backgroundColor: theme.primaryColor,
                                          borderColor: Colors.white,
                                          text: "Edit Profile",
                                          textColor: Colors.white,
                                          function: () {},
                                        )
                                      : isfollowing
                                          ? FollowButton(
                                              backgroundColor: Colors.white,
                                              borderColor: Colors.pinkAccent,
                                              text: "Unfollow",
                                              textColor: Colors.blue,
                                              function: () async {
                                                await FirebaseMethods()
                                                    .followUser(
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid,
                                                        userData["id"]);
                                                //update screen
                                                setState(() {
                                                  isfollowing = false;
                                                  followers -= followers;
                                                });
                                              },
                                            )
                                          : FollowButton(
                                              backgroundColor: Colors.blue,
                                              borderColor: Colors.blue,
                                              text: "Follow",
                                              textColor: Colors.white,
                                              function: () async {
                                                await FirebaseMethods()
                                                    .followUser(
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid,
                                                        userData["id"]);

                                                //update screen
                                                setState(() {
                                                  isfollowing = true;
                                                  followers += followers;
                                                });
                                              },
                                            ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      padding: (_screenSize.width < webScreenSize)
                          ? const EdgeInsets.all(8.0)
                          : EdgeInsets.symmetric(
                              horizontal: _screenSize.width / 4),
                      child: Column(
                        children: [
                          Text(
                            userData["username"].toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(userData["bio"].toString()),
                        ],
                      ),
                    ),
                    const Divider(),

                    //display a gridview of user posts
                    FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection("posts")
                            .where("userId", isEqualTo: widget.userId)
                            .get(),
                        builder: (context,
                            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                snapShot) {
                          if (snapShot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (!snapShot.hasData) {
                            return const Center(
                              child: Text("No post yet"),
                            );
                          }
                          return GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 5,
                                      mainAxisSpacing: 1.5,
                                      childAspectRatio: 1),
                              itemCount: snapShot.data!.docs.length,
                              itemBuilder: (context, i) {
                                final snapData = snapShot.data!.docs[i];
                                return Container(
                                    child:
                                        Image.network(snapData["postImage"]));
                              });
                        }),
                  ],
                ),
              ),
            ]),
          );
  }
}

Widget profileInfo(int count, String infoType) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Text(
        "$count",
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const SizedBox(
        height: 10,
      ),
      Text(infoType)
    ],
  );
}
