import 'commentModel.dart';

class Post {
  final String id_post;
  final String id_user;
  int like;
  final String title;
  final String text;
  String id_category;
  List<Comment> comments;
  final String photo;
  bool isLiked;


  Post({
    this.id_post = '',
    required this.id_user,
    required this.like,
    required this.title,
    required this.text,
    required this.id_category,
    this.comments = const [],
    required this.photo,
    this.isLiked = false,
  
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    var id = json['keyId'];
    var tab = json['keyData'];

    var text = tab['text'];
    if (text == null) {
      text = '';
    }
   
    var post =  Post(
      id_user: tab['id_user'],
      like: tab['like'],
      title: tab['title'],
      text: text, 
      id_category: tab['id_category'],
      id_post: id,
      photo: tab['photo'],

    );

    return post;
  }
}