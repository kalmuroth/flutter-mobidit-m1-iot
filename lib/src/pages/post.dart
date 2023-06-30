// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobidit_m1_iot/src/pages/addCategory.dart';
import 'package:flutter_mobidit_m1_iot/src/pages/addPost.dart';
import 'package:flutter_mobidit_m1_iot/src/pages/login.dart';
import '../model/postModel.dart';
import '../model/commentModel.dart';
import '../model/userModel.dart';
import '../services/dbService.dart';
import 'package:http/http.dart' as http;


class Posts extends StatelessWidget {
  const Posts({super.key});
  static const routeName = '/home';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
      theme: ThemeData(
        primarySwatch: Colors.orange,
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
   String idUser = '';
  bool status = false;
  

  String selectedCategory = '';


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
    isAdmin();

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


Future<String> getUserInfo(String userId) async {
  final response = await http.get(
    Uri.parse('https://europe-west2-flutter-mobidit-m1-iot.cloudfunctions.net/admin-user/$userId'),
  );

  if (response.statusCode == 200) {
    Map<String, dynamic> responseBody = jsonDecode(response.body);
    Map<String, dynamic> keyData = responseBody['keyData'];
    Users user = Users.fromJson(keyData);
    return user.speudo; // assuming Users has a pseudo field
  } else {
    throw Exception('Failed to load user data');
  }
}

Future<String?> deletePost(String postId) async {
  final response = await http.delete(
    Uri.parse('https://europe-west2-flutter-mobidit-m1-iot.cloudfunctions.net/admin-post/$postId'),
  );

  if (response.statusCode == 200) {
    print("Post deleted");
    await refreshPosts();
  } else {
    throw Exception('Failed to delete post');
  }
}

Future<void> refreshPosts() async {
  await fetchPosts();
}

Future<void> isAdmin() async {
  try {
    User? user = await FirebaseAuth.instance.currentUser;
    String userId = user?.uid ?? '';
    bool fetchedStatus = await postService.getUserStatus(userId);
    setState(() {
        status = fetchedStatus;
    });
  } catch (e) {
    print('$e');
  }
}


@override
Widget build(BuildContext context) {
   return Scaffold(
        appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Notreddit"),
          ],
        ),
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
                          MaterialPageRoute(builder: (context) => const AddCategoryPage()),
                        );
                      },
                      child: Text('Add Category'),
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
    return FutureBuilder<String>(
      future: getUserInfo(post.id_user),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
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
  child: Align(
    alignment: Alignment.centerLeft,
    child: FractionallySizedBox(
      widthFactor: 0.75, // Set the width factor to 75%
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      post.title,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              Text(
                'Posted by ${snapshot.data}',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                post.text,
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 12.0),
              Container(
                width: MediaQuery.of(context).size.width * 0.6, // Adjust the width factor as desired
                height: MediaQuery.of(context).size.height * 0.6, // Adjust the height factor as desired
                child: Image.network(
                  post.photo,
                  fit: BoxFit.cover,
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
              ),
              SizedBox(height: 12.0),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      post.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                      color: post.isLiked ? Colors.orange : null,
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
                  Spacer(),
                  Visibility(
                    visible: status || idUser == post.id_user, // Replace 'status' with your boolean variable
                    child: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        deletePost(post.id_post.toString());
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
;
      },
    );
  },
),
          ),
        ],
      ),
    floatingActionButton: 
     StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(); // Return an empty container while waiting for the auth state
              }
              final user = snapshot.data;
              if (user != null) {
                return FloatingActionButton(
        onPressed: () {
          // Add navigation to the 'Add Post' screen here
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPostPage()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,
      );
              } else {
                return Container();
              }
            },
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


class PostDetailPage extends StatefulWidget {
  final Post post;

  PostDetailPage({required this.post});

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  Post get post => widget.post;

  final DatabaseService service = DatabaseService();
  Comment tmp = Comment(id_post: '', content: '');
  final TextEditingController commentController = TextEditingController();
  List<Comment> comments = [];

  @override
  void initState() {
    super.initState();
    comments = post.comments;
  }

  void submitComment(Comment comment) {
    service.updateComment(comment);
  }

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
                    color: widget.post.isLiked ? Colors.orange : null,
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
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  comment.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                                  color: comment.isLiked ? Colors.orange : null,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (comment.isLiked) {
                                      comment.like--;
                                    } else {
                                      comment.like++;
                                    }
                                    comment.isLiked = !comment.isLiked;
                                  });
                                },
                              ),
                              Text(comment.like.toString()),
                            ],
                          ),
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
                  tmp = Comment(
                    id_post: post.id_post,
                    content: commentController.text,
                  );
                  comments.add(tmp);
                  commentController.clear();
                });
                submitComment(tmp);
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}