class User {
  final String id;
  final String email;
  final String? displayName;
  final bool isOfflineAuthenticated;
  final String? deviceId;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  User({
    required this.id,
    required this.email,
    this.displayName,
    this.isOfflineAuthenticated = false,
    this.deviceId,
    this.createdAt,
    this.lastLoginAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'isOfflineAuthenticated': isOfflineAuthenticated,
      'deviceId': deviceId,
      'createdAt': createdAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      isOfflineAuthenticated: json['isOfflineAuthenticated'] as bool? ?? false,
      deviceId: json['deviceId'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : null,
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt'] as String) 
          : null,
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    bool? isOfflineAuthenticated,
    String? deviceId,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isOfflineAuthenticated: isOfflineAuthenticated ?? this.isOfflineAuthenticated,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}