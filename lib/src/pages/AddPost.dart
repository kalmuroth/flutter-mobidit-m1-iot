import 'package:flutter/material.dart';

class AddPostPage extends StatelessWidget {
  const AddPostPage({Key? key}) : super(key: key);

  static const routeName = '/addpost';

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
            // Add photo input field or image picker here
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
