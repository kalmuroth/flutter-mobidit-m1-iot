import 'package:http/http.dart' as http;
import '../model/postModel.dart';
import '../model/commentModel.dart';
import 'dart:convert';

class DatabaseService {

  Future<List<Post>> getAllPost() async {
    var url = 'https://europe-west2-flutter-mobidit-m1-iot.cloudfunctions.net/admin-post';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      List<Post> postList = [];
      List<Comment> comments = [];
      for (var postJson in jsonResponse) {
        Post post = Post.fromJson(postJson);
        var category = await getCategory(post.id_category);
        post.id_category = category;
        comments = await getAllComment(post.id_post);
        post.comments = comments;
        postList.add(post);
      }
      return postList;
    } else {
      throw Exception('error');
    }
  }

  Future<String> getCategory(String categoryId) async {
    var url = 'https://europe-west2-flutter-mobidit-m1-iot.cloudfunctions.net/admin-category/' + categoryId;
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      var category = jsonResponse['categoryData']['name'];
      return category;
    } else {
      throw Exception('Error fetching category');
    }

  }

  Future<List<Comment>> getAllComment(String id_post) async {
    var url = 'https://europe-west2-flutter-mobidit-m1-iot.cloudfunctions.net/admin-getPost/' + id_post;
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      List<Comment> commentList = [];
      for (var commentJson in jsonResponse) {
        Comment comment = Comment.fromJson(commentJson);
        commentList.add(comment);
      }
      return commentList;
    } else {
      throw Exception('error');
    }
  }
  
  Future<void> updateComment(Comment comment) async {
    final url = 'https://europe-west2-flutter-mobidit-m1-iot.cloudfunctions.net/admin-comment';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'id_post': comment.id_post,
          'content': comment.content,
          //'like': 0,
        },
      );

      if (response.statusCode == 200) {
        print('success');
      } else {
        throw Exception('Error updating comment');
      }
    } catch (e) {
      throw Exception('Error updating comment: $e');
    }
  }
}