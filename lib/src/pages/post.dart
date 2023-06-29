// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobidit_m1_iot/src/pages/AddPost.dart';
import 'package:flutter_mobidit_m1_iot/src/pages/login.dart';
import '../model/postModel.dart';
import '../services/dbService.dart';
import 'package:http/http.dart' as http;

class Posts extends StatelessWidget {
  const Posts({super.key});

  static const routeName = '/home';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homme',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RedditHomePage(),
    );
  }
}

class RedditHomePage extends StatefulWidget {
  @override
  _RedditHomePageState createState() => _RedditHomePageState();
}

class _RedditHomePageState extends State<RedditHomePage> {

  final DatabaseService postService = DatabaseService();
  List<Post> posts = [];
  
  String selectedCategory = '';

  @override
  void initState() {
    super.initState();
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





  @override
  Widget build(BuildContext context) {
    return Scaffold(
         appBar: AppBar(
        title: Text('Reddit'),
        actions: [
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(); // Return an empty container while waiting for the auth state
              }
              final user = snapshot.data;
              if (user == null) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                );
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceEvenly, // for evenly space between buttons
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                         Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddPostPage()),
                    );
                      },
                      child: Text('Add Post'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                      },
                      child: Text('Logout'),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
      body: Column(
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
          Expanded(
            child: posts.isEmpty
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      Post post = posts[index];
                      if (selectedCategory.isNotEmpty && post.id_category != selectedCategory) {
                        return Container();
                      }
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailPage(post: post),
                            ),
                          );
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.title,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  post.text,
                                  style: TextStyle(fontSize: 16.0),
                                ),
                                SizedBox(height: 12.0),
                                Image.network(
  post.photo,   // use Image.network to load image from network
  fit: BoxFit.cover,      // use BoxFit.cover to maintain the aspect ratio of image
  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) {
      return child;
    }
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
            : null,
      ),
    );
  },
  errorBuilder: (context, error, stackTrace) {
    return Text('Failed to load image.');
  },
),
SizedBox(height: 12.0),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        post.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                                        color: post.isLiked ? Colors.blue : null,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (post.isLiked) {
                                            post.like--;
                                          } else {
                                            post.like++;
                                          }
                                          post.isLiked = !post.isLiked;
                                        });
                                      },
                                    ),
                                    Text(post.like.toString()),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add navigation to the 'Add Post' screen here
            Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddPostPage()),
                          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  List<DropdownMenuItem<String>> getCategoriesDropdownItems() {
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
  }

}


class Comment {
  final String content;

  Comment({required this.content});
}

class PostDetailPage extends StatefulWidget {
  final Post post;

  PostDetailPage({required this.post});

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {

  final TextEditingController commentController = TextEditingController();
  List<Comment> comments = [];

  @override
  void dispose() {

    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Detail'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.post.title,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              widget.post.text,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 12.0),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    widget.post.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    color: widget.post.isLiked ? Colors.blue : null,
                  ),
                  onPressed: () {
                    setState(() {
                      if (widget.post.isLiked) {
                        widget.post.like--;
                      } else {
                        widget.post.like++;
                      }
                      widget.post.isLiked = !widget.post.isLiked;
                    });
                  },
                ),
                Text(widget.post.like.toString()),
              ],
            ),
            SizedBox(height: 20.0),
            Text(
              'Comments',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4.0),
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4.0),
                          Text(comment.content),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Comment',
              ),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  comments.add(Comment(
                    content: commentController.text,
                  ));
                  commentController.clear();
                });
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}