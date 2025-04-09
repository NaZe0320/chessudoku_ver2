class User {
  final String id;
  final String email;
  final String? displayName;
  final bool isOfflineAuthenticated;

  User({
    required this.id,
    required this.email,
    this.displayName,
    this.isOfflineAuthenticated = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'isOfflineAuthenticated': isOfflineAuthenticated,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      isOfflineAuthenticated: json['isOfflineAuthenticated'] as bool? ?? false,
    );
  }
}
