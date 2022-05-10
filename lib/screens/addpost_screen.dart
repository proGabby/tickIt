import 'dart:typed_data';

import "package:flutter/material.dart";
import 'package:ig_clone/models/users_model.dart';
import 'package:ig_clone/providers/user_provider.dart';
import 'package:ig_clone/resource/firebase_resource.dart';
import 'package:ig_clone/screens/feed_screen.dart';
import 'package:ig_clone/utils/general_file.dart';
import 'package:ig_clone/utils/image_picker.dart';
import 'package:ig_clone/utils/showDialog.dart';
import 'package:image_picker/image_picker.dart';
import "package:provider/provider.dart";

import '../reponsive/mobileScreenLayout.dart';
import '../reponsive/responsive_screen.dart';
import '../reponsive/webScreenLayout.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _image;
  final TextEditingController _postText = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _postText.dispose();
    super.dispose();
  }

  void sendPost(
      {required Uint8List file,
      required String username,
      required description,
      required userId,
      required profileImage}) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final res = await FirebaseMethods().uploadPostOnFirebase(
          file: file,
          username: username,
          description: description,
          userId: userId,
          profileImage: profileImage);

      if (res == "successful") {
        setState(() {
          _isLoading = false;
        });
        showSnackBar(context, "Post Successful");
        setState(() {
          _image = null;
        });
      } else {
        showSnackBar(context, res);
      }
    } catch (e) {
      showSnackBar(context, "An error occur");
    }
  }

  //selecte image from gallery or camery
  _selectImage(BuildContext context) {
    return showDialog(
        context: context,
        builder: (ctx) {
          return SimpleDialog(
            title: const Text("create a post"),
            children: [
              SimpleDialogOption(
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List cameryImage = await pickImage(ImageSource.camera);
                  setState(() {
                    _image = cameryImage;
                  });
                },
                padding: const EdgeInsets.all(25),
                child: const Text("Take a photo"),
              ),
              SimpleDialogOption(
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List cameryImage = await pickImage(ImageSource.gallery);
                  setState(() {
                    _image = cameryImage;
                  });
                },
                padding: const EdgeInsets.all(25),
                child: const Text("Attach a photo"),
              ),
              SimpleDialogOption(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                padding: const EdgeInsets.all(25),
                child: const Text("Cancel"),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size;
    final user = Provider.of<UserProvider>(context).getUser;

    //return a upload icon when image is null otherwise addpost
    return
        // const Scaffold(body: Center(child: Text("You are at add post")));
        _image == null
            ? Center(
                child: IconButton(
                icon: (deviceSize.width < webScreenSize)
                    ? const Icon(
                        Icons.upload_file_rounded,
                      )
                    : const Icon(
                        Icons.add,
                        size: 40,
                      ),
                onPressed: () {
                  _selectImage(context);
                },
              ))
            : Scaffold(
                appBar: AppBar(
                  backgroundColor: theme.primaryColor,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        _image = null;
                      });
                    },
                  ),
                  title: const Text("Send to"),
                  centerTitle: false,
                  actions: [
                    TextButton(
                        onPressed: () {
                          sendPost(
                              file: _image!,
                              username: user.username,
                              description: _postText.text,
                              userId: user.id,
                              profileImage: user.userPhotoUrl);
                        },
                        child: const Text(
                          "Send",
                          style: TextStyle(color: Colors.pinkAccent),
                        ))
                  ],
                ),
                body: Column(
                  children: [
                    _isLoading
                        ? const LinearProgressIndicator(
                            color: Colors.blueAccent)
                        : const Padding(padding: EdgeInsets.zero),
                    Row(
                      children: [
                        //holds the userprofile
                        CircleAvatar(
                          backgroundImage: NetworkImage(user.userPhotoUrl),
                        ),
                        SizedBox(
                          //hold the write caption textfield
                          width: deviceSize.width * 0.3,
                          child: TextField(
                            decoration: const InputDecoration(
                                //Creates a bundle of the border, labels, icons, and styles used to decorate a Material Design text field
                                hintText: "Write caption",
                                border: InputBorder.none),
                            maxLines: 8,
                            controller: _postText,
                          ),
                        ),
                        //hold the image to post
                        SizedBox(
                          height: 30,
                          width: 30,
                          child: AspectRatio(
                            aspectRatio: 200 / 350,
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: MemoryImage(_image!),
                                      fit: BoxFit
                                          .fill /* Fill the target box by distorting the source's aspect ratio. */,
                                      alignment: FractionalOffset
                                          .topCenter /*An offset that's expressed as a fraction of a [Size]*/)),
                            ),
                          ),
                        ),
                        const Divider(
                          height: 20,
                        ),
                      ],
                    )
                  ],
                ),
              );
  }
}
