import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({Key? key}) : super(key: key);

  static const routeName = '/addpost';

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = pickedFile;
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Post'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Category'),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              decoration: InputDecoration(labelText: 'Text'),
              maxLines: null, // Allow multiple lines of text
            ),
            SizedBox(height: 16.0),
            _image == null
              ? Text('No image selected.')
              : Image.file(File(_image!.path)),
            TextButton(
              onPressed: getImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Add post logic here
              },
              child: Text('Add Post'),
            ),
          ],
        ),
      ),
    );
  }
}
