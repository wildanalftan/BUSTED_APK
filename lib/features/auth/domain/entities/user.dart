class UserEntity {
  final String name;
  final String email;
  final String password;
  final bool isAdmin;
  final bool isBlocked;

  UserEntity({
    required this.name,
    required this.email,
    required this.password,
    this.isAdmin = false,
    this.isBlocked = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'isAdmin': isAdmin,
      'isBlocked': isBlocked,
    };
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      isAdmin: json['isAdmin'] as bool? ?? false,
      isBlocked: json['isBlocked'] as bool? ?? false,
    );
  }

  UserEntity copyWith({
    String? name,
    String? email,
    String? password,
    bool? isAdmin,
    bool? isBlocked,
  }) {
    return UserEntity(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      isAdmin: isAdmin ?? this.isAdmin,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
