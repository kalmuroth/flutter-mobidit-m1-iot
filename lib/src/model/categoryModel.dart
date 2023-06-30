class Categories {
  final String name;
  final String id_user;
Categories
  Categories({
    required this.name,
    required this.id_user
  });

  // function to convert the raw map to a User instance
  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
      name: json['name'],
      id_user: json['id_user']
    );
  }
}