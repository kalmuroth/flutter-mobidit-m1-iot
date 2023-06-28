// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_mobidit_m1_iot/src/pages/post.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data'; // Needed for Uint8List

class AddPostPage extends StatefulWidget {
  const AddPostPage({Key? key}) : super(key: key);

  static const routeName = '/addpost';

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  Uint8List? _imageBytes;
  final _titleController = TextEditingController();
  final _textController = TextEditingController();

  Future<void> addPost(String title, String text, String category, String imagePath) async {
    final url = 'https://europe-west2-flutter-mobidit-m1-iot.cloudfunctions.net/post';
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'title': title,
        'text': text,
        'category': category,
        'imagePath': imagePath,
      }),
    );

    if (response.statusCode != 200) {
      print('Failed to add post. Status code: ${response.statusCode}.');
    }
  }

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

  // Reads the bytes of the image file and updates _imageBytes
  Future<void> _loadImageBytes(XFile image) async {
    _imageBytes = await image.readAsBytes();
  }

  final List<Post> posts = [
    Post(
      author: 'John Doe',
      like: 10,
      title: 'First Post',
      content: 'This is the content of the first post.',
      category: 'Category A',
    ),
    Post(
      author: 'Jane Smith',
      like: 5,
      title: 'Second Post',
      content: 'This is the content of the second post.',
      category: 'Category B',
    ),
    Post(
      author: 'Alice Johnson',
      like: 3,
      title: 'Third Post',
      content: 'This is the content of the third post.',
      category: 'Category A',
    ),
  ];

  String selectedCategory = '';

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
            Padding(
              padding: EdgeInsets.all(10.0),
              child: DropdownButtonFormField<String>(
                value: selectedCategory,
                onChanged: (newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                  });
                },
                items: getCategoriesDropdownItems(),
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
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

  List<DropdownMenuItem<String>> getCategoriesDropdownItems() {
    Set<String> categoriesSet = Set<String>();
    for (var post in posts) {
      categoriesSet.add(post.category);
    }

    List<DropdownMenuItem<String>> dropdownItems = [];
    dropdownItems.add(DropdownMenuItem<String>(
      value: '',
      child: Text('All'),
    ));

    for (var category in categoriesSet) {
      dropdownItems.add(DropdownMenuItem<String>(
        value: category,
        child: Text(category),
      ));
    }

    return dropdownItems;
  }
}
