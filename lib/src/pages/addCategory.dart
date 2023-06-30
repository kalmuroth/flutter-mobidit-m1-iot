// ignore_for_file: prefer_const_constructors, prefer_const_declarations

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobidit_m1_iot/src/model/categoryModel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data'; // Needed for Uint8List
import 'package:flutter/material.dart';
import '../model/categoryModel.dart';
import '../services/dbService.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({Key? key}) : super(key: key);

  static const routeName = '/addcategory';

  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String name = '';
  Uint8List? _imageBytes;
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  final DatabaseService categoryService = DatabaseService();
  String selectedCategory = '';
  String selectedCategoryId = '';
  List<Map<String, dynamic>> categories = [];
  String idUser = '';
  FirebaseAuth _auth = FirebaseAuth.instance;
  num NbLikes = 0;
  String photoUrl = '';

  @override
  void initState() {
    super.initState();
    if (_auth.currentUser != null) {
      idUser =
          _auth.currentUser!.uid; // Here you get the uid of the current user
    } else {
      // handle case where no user is signed in.
    }
  }


  Future<void> addCategory(String name, String idUser) async {
    final url = 'https://europe-west2-flutter-mobidit-m1-iot.cloudfunctions.net/admin-category';
    final String categoryName = "n/" + name;
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'name': categoryName,
        'id_user': idUser
      }),
    );

    if (response.statusCode != 200) {
      print('Failed to add category. Status code: ${response.statusCode}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Category'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10.0),
            ),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                  String name = _titleController.text;
                  await addCategory(name, idUser);
                  ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processing Data')),
                  );
                  // Navigate back to the home page
                  Navigator.pop(context);
              },
              child: Text('Add Category'),
            )
          ],
        ),
      ),
    );
  }

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
}
