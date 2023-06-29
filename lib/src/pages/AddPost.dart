// ignore_for_file: prefer_const_constructors, prefer_const_declarations

import 'package:firebase_auth/firebase_auth.dart';
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
  Uint8List? _imageBytes;
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  final DatabaseService postService = DatabaseService();
  List<Post> posts = [];
  String selectedCategory = '';
  String selectedCategoryId = '';
  List<Map<String, dynamic>> categories = [];
  String idUser = '';
  FirebaseAuth _auth = FirebaseAuth.instance;
  num NbLikes = 0;
  String photoUrl = '';

/*     @override
    void initState() {
      super.initState();
      idUser = _auth.currentUser!.uid;  // Here you get the uid of the current user
      fetchPosts();
    }
 */

  Future<String> uploadBase64ToServer(String base64Image) async {
    // API endpoint
    String apiUrl =
        "https://europe-west2-flutter-mobidit-m1-iot.cloudfunctions.net/upload-uploadFileInBase64";

    // Send a POST request
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"fileData": base64Image}),
    );

    // If the server returns a 200 OK response, parse the JSON.
    if (response.statusCode == 200) {
      String responseBody = jsonDecode(response.body);

      // Assuming the URL is returned in the 'url' key.
      // Change this to the actual key if it's different.
      return responseBody;
    } else {
      // If the server returns an error, throw an exception.
      throw Exception(
          'Failed to upload image. Server responded with status code ${response.statusCode}.');
    }
  }

  @override
  void initState() {
    super.initState();
    if (_auth.currentUser != null) {
      idUser =
          _auth.currentUser!.uid; // Here you get the uid of the current user
    } else {
      // handle case where no user is signed in.
    }
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      List<Post> fetchedPosts = await postService.getAllPost();
      setState(() {
        posts = fetchedPosts;
      });
    } catch (e) {
      print('$e');
    }
  }

  Future<void> addPost(String title, String text, String id_category,
      String photo, String idUser, num like) async {
    final url =
        'https://europe-west2-flutter-mobidit-m1-iot.cloudfunctions.net/admin-post';
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'title': title,
        'text': text,
        'id_category': id_category,
        'photo': photo,
        'id_user': idUser,
        'like': NbLikes,
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
              child: FutureBuilder<List<DropdownMenuItem<String>>>(
                future: getCategoriesDropdownItems(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return DropdownButtonFormField<String>(
                      value: selectedCategory,
                      onChanged: (newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                          //selectedCategoryId = getCategoryID(selectedCategory);
                        });
                      },
                      items: snapshot.data,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Failed to fetch categories');
                  } else {
                    return CircularProgressIndicator();
                  }
                },
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
            /*   ElevatedButton(
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
            ), */
            ElevatedButton(
              onPressed: () async {
                String title = _titleController.text;
                String text = _textController.text;
                //String category = selectedCategoryId;
                String id_category = selectedCategory;
                String photo = base64Encode(_imageBytes!);
                num Likes = NbLikes;

                // Get the selected category ID
                //String categoryId = selectedCategoryId;

                photoUrl = await uploadBase64ToServer(photo);

                print(photoUrl);

                await addPost(
                    title, text, id_category, photoUrl, idUser, Likes);

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

/*   List<DropdownMenuItem<String>> getCategoriesDropdownItems() {
    Set<String> categoriesSet = Set<String>();
    for (var post in posts) {
      categoriesSet.add(post.id_category);
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
  } */
  String getCategoryID(String categoryName) {
    for (var category in categories) {
      if (category['categoryData']['name'] == categoryName) {
        return category['categoryId'];
      }
    }
    return '';
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final url =
        'https://europe-west2-flutter-mobidit-m1-iot.cloudfunctions.net/admin-category';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else if (data is Map<String, dynamic>) {
        return [data];
      }
    }
    throw Exception('Failed to fetch categories');
  }

  Future<List<DropdownMenuItem<String>>> getCategoriesDropdownItems() async {
    List<DropdownMenuItem<String>> dropdownItems = [];

    try {
      List<Map<String, dynamic>> categories = await fetchCategories();

      // Add an option for all categories
      dropdownItems.add(DropdownMenuItem<String>(
        value: '',
        child: Text('All'),
      ));

      // Add dropdown items for each category
      for (var category in categories) {
        dropdownItems.add(DropdownMenuItem<String>(
          value: category['categoryId'],
          child: Text(category['categoryData']['name']),
        ));
      }
    } catch (error) {
      print('Failed to fetch categories: $error');
    }

    return dropdownItems;
  }
}
