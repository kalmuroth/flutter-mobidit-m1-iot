import 'package:flutter/material.dart';

class RedditApp extends StatelessWidget {
  const RedditApp({super.key});

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
        title: Text('Reddit'),
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
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                if (selectedCategory.isNotEmpty && post.category != selectedCategory) {
                  return Container(); 
                }
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailPage(post: post),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.all(10.0),
                    elevation: 4.0,
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
                            post.content,
                            style: TextStyle(fontSize: 16.0),
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

class Post {
  final String author;
  int like;
  final String title;
  final String content;
  final String category;
  bool isLiked;

  Post({
    required this.author,
    required this.like,
    required this.title,
    required this.content,
    required this.category,
    this.isLiked = false,
  });
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
              widget.post.content,
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
