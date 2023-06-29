import 'package:http/http.dart' as http;
import '../model/postModel.dart';
import 'dart:convert';

class DatabaseService {

  Future<List<Post>> getAllPost() async {
    var url = 'https://europe-west2-flutter-mobidit-m1-iot.cloudfunctions.net/admin-post';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      List<Post> postList = [];
      for (var postJson in jsonResponse) {
        Post post = Post.fromJson(postJson);
        var category = await getCategory(post.id_category);
        post.id_category = category;
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

  Future<bool> getUserStatus(String userId) async {
    var url = 'https://europe-west2-flutter-mobidit-m1-iot.cloudfunctions.net/admin-user/' + userId;
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      var status = jsonResponse['keyData']['isAdmin'];
      return status;
    } else {
      throw Exception('Error fetching category');
    }
  }
}