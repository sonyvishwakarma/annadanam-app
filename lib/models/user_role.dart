// models/user_role.dart
import 'package:flutter/material.dart';

enum UserRole {
  donor,
  volunteer,
  recipient,
  admin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.donor:
        return 'Food Donor';
      case UserRole.volunteer:
        return 'Volunteer';
      case UserRole.recipient:
        return 'Food Recipient';
      case UserRole.admin:
        return 'Admin';
    }
  }

  String get description {
    switch (this) {
      case UserRole.donor:
        return 'Donate food and make a difference';
      case UserRole.volunteer:
        return 'Help with food distribution and logistics';
      case UserRole.recipient:
        return 'Receive food assistance for those in need';
      case UserRole.admin:
        return 'Manage and coordinate charity operations';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.donor:
        return Icons.handshake_rounded;
      case UserRole.volunteer:
        return Icons.volunteer_activism_rounded;
      case UserRole.recipient:
        return Icons.food_bank_rounded;
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
    }
  }

  String get dashboardTitle {
    switch (this) {
      case UserRole.donor:
        return 'Donor Dashboard';
      case UserRole.volunteer:
        return 'Volunteer Dashboard';
      case UserRole.recipient:
        return 'Recipient Dashboard';
      case UserRole.admin:
        return 'Admin Dashboard';
    }
  }
}
