class Comment {
  String id_comment;
  String id_post;
  String content;
  int like;
  bool isLiked;
  String id_user;

  Comment({
    this.id_comment = '',
    required this.id_post,
    required this.content,
    required this.id_user,
    this.like = 0,
    this.isLiked = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    var tab = json;

    var id = json['id'] ?? '';
    var id_user = tab['id_user'] ?? '';
    var like = tab['like'] ?? 0;
    var content = tab['content'] ?? '';

    var comment = Comment(
      id_post: tab['id_post'],
      like: like,
      id_comment: id,
      content: content,
      id_user: id_user,
    );

    return comment;
  }
}
