class Post {
  final String id_user;
  int like;
  final String title;
  final String text;
  String id_category;
  final String photo;
  final String comments;
  bool isLiked;


  Post({
    required this.id_user,
    required this.like,
    required this.title,
    required this.text,
    required this.id_category,
    required this.photo,
    required this.comments,
    this.isLiked = false,
  
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    var tab = json['keyData'];

    var comments = tab['comments'];
    if (comments == null) {
      comments = '';
    }

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
      photo: tab['photo'],
      comments: comments,
   
    );

    return post;
  }
}