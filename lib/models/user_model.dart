// models/user_model.dart
import 'user_role.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final Map<String, dynamic>? additionalInfo;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.additionalInfo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '', // ADD THIS LINE - you were missing the id
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: _parseRole(json['role'] ?? 'donor'),
      additionalInfo: json['additionalInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // ADD THIS LINE to include id in JSON
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'additionalInfo': additionalInfo,
    };
  }

  static UserRole _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'donor':
        return UserRole.donor;
      case 'volunteer':
        return UserRole.volunteer;
      case 'recipient':
        return UserRole.recipient;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.donor;
    }
  }
}