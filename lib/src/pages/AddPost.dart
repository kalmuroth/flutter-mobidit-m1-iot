import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobidit_m1_iot/src/model/postModel.dart';
import 'package:flutter_mobidit_m1_iot/src/pages/post.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data'; // Needed for Uint8List
import 'package:flutter/material.dart';
import '../model/postModel.dart';
import '../services/dbService.dart';


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
        _loadImageBytes(pickedFile); // Load the image bytes
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
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextFormField(
              controller: _textController,
              decoration: InputDecoration(labelText: 'Text'),
              maxLines: null, // Allow multiple lines of text
            ),
            _imageBytes == null
              ? Text('No image selected.')
              : Image.memory(_imageBytes!),
            TextButton(
              onPressed: getImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                String title = _titleController.text;
                String text = _textController.text;
                String category = selectedCategory;
                String imagePath = base64Encode(_imageBytes!);

                await addPost(title, text, category, imagePath);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processing Data')),
                );
              },
              child: Text('Add Post'),
            ),
          ],
        ),
      ),
    );
  }
}
