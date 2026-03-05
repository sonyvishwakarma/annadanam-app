// utils/colors.dart
import 'package:flutter/material.dart';
import '../models/user_role.dart';

class RoleColors {
  static Map<UserRole, Color> primaryColors = {
    UserRole.donor: Colors.green,
    UserRole.volunteer: Colors.blue,
    UserRole.recipient: Colors.orange,
    UserRole.admin: Colors.purple,
  };

  static Map<UserRole, Color> lightColors = {
    UserRole.donor: Colors.green.shade50,
    UserRole.volunteer: Colors.blue.shade50,
    UserRole.recipient: Colors.orange.shade50,
    UserRole.admin: Colors.purple.shade50,
  };

  static Map<UserRole, Color> darkColors = {
    UserRole.donor: Colors.green.shade800,
    UserRole.volunteer: Colors.blue.shade800,
    UserRole.recipient: Colors.orange.shade800,
    UserRole.admin: Colors.purple.shade800,
  };

  static Color getPrimaryColor(UserRole role) {
    return primaryColors[role] ?? Colors.green;
  }

  static Color getLightColor(UserRole role) {
    return lightColors[role] ?? Colors.green.shade50;
  }

  static Color getDarkColor(UserRole role) {
    return darkColors[role] ?? Colors.green.shade800;
  }
}