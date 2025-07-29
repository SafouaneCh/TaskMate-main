class UserModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String token;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.token,
    required this.createdAt,
    required this.updatedAt,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? token,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? json;
    return UserModel(
      id: user['id'] ?? '',
      email: user['email'] ?? '',
      name: user['name'] ?? '',
      phone: user['phone'] ?? '',
      token: json['token'] ?? user['token'] ?? '',
      createdAt:
          DateTime.parse(user['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(user['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'token': token,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return '''UserModel(id: $id, email: $email, name: $name, phone: $phone, token: $token, createdAt: $createdAt, updatedAt: $updatedAt)''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.phone == phone &&
        other.token == token &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        name.hashCode ^
        phone.hashCode ^
        token.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
