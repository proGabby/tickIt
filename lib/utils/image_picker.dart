import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';

pickImage(ImageSource source) async {
  //ImageSource is expose by image_picker package
  final ImagePicker _picker = ImagePicker();
  final XFile? _image = await _picker.pickImage(source: source);

  //validation check to ensure image is not null
  if (_image != null) {
    return await _image.readAsBytes();
  }
}
