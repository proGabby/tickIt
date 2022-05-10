import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ig_clone/screens/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool isSearching = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TextEditingController _searchFieldEditor = TextEditingController();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          title: TextFormField(
            controller: _searchFieldEditor,
            decoration:
                const InputDecoration(hintText: "Search for a user here"),
            onFieldSubmitted: (_) {
              setState(() {
                isSearching = true;
              });
            },
          ),
        ),
        body: isSearching
            ? FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection("users")
                    .where("username",
                        isGreaterThanOrEqualTo: _searchFieldEditor.text)
                    .get(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        dataSnapshot) {
                  if (dataSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (!dataSnapshot.hasData) {
                    return const Center(
                      child: Text("No user with that name"),
                    );
                  }
                  final snapShotDocs = dataSnapshot.data!.docs;
                  return ListView.builder(
                      itemBuilder: (ctx, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(snapShotDocs[index]["profilePic"]),
                          ),
                          title: Text(snapShotDocs[index]["username"]),
                          onTap: () {
                            //open profile screen
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => ProfileScreen(
                                  userId: snapShotDocs[index]["id"]),
                            ));
                          },
                        );
                      },
                      itemCount: snapShotDocs.length);
                },
              )
            : //will display a Staggered grid view instead
            FutureBuilder(
                future: FirebaseFirestore.instance.collection("posts").get(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapShot) {
                  if (snapShot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (!snapShot.hasData) {
                    return const Text("No Feed available..");
                  }
                  //implement a staggered gridview
                  return GridView.custom(
                    gridDelegate: SliverQuiltedGridDelegate(
                      crossAxisCount: 4,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      repeatPattern: QuiltedGridRepeatPattern.inverted,
                      pattern: const [
                        QuiltedGridTile(2, 2),
                        QuiltedGridTile(1, 1),
                        QuiltedGridTile(1, 1),
                        QuiltedGridTile(1, 2),
                      ],
                    ),
                    childrenDelegate: SliverChildBuilderDelegate(
                        (context, index) => Image.network(
                            snapShot.data!.docs[index]["profileImageUrl"]),
                        childCount: snapShot.data!.docs.length),
                  );
                }));
  }
}
