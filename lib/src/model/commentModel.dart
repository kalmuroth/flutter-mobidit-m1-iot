class Comment {
  String id_post;
  String content;
  int like;
  bool isLiked;

  Comment({
    required this.id_post,
    required this.content,
    this.like = 0,
    this.isLiked = false});


  factory Comment.fromJson(Map<String, dynamic> json) {
    var tab = json;

    var content = tab['content'];
    if (content == null) {
      content = '';
    }

    var like = tab['like'];
    if (like == null) {
      like = 0;
    }
   
    var comment =  Comment(
      id_post: tab['id_post'],
      like: like,
      content: content, 
    );

    return comment;
  }  
}
