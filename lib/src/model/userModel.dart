class Users {
  final String uid;
  final bool isAdmin;
  final String email;
  final String speudo;

  Users({
    required this.uid,
    required this.isAdmin,
    required this.email,
    required this.speudo,
  });

  // function to convert the raw map to a User instance
  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      uid: json['uid'],
      isAdmin: json['isAdmin'],
      email: json['email'],
      speudo: json['speudo'],
    );
  }
}