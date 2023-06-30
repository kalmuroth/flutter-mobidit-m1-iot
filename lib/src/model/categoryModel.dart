class Category {
  final String name;
  final String id_user;

  Category({
    required this.name,
    required this.id_user,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'] as String,
      id_user: json['id_user'] as String,
    );
  }
}
