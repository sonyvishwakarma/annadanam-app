import 'package:flutter/material.dart';
import 'auth/auth_page.dart';
import '../models/user_role.dart';
import '../utils/colors.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white10,
        elevation: 0,
        title: const Text(
          'Annadanam',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select your role',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose how you want to contribute or benefit',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Role Cards
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ListView(
                  children: [
                    _buildRoleCard(
                      role: UserRole.donor,
                      context: context,
                    ),
                    const SizedBox(height: 20),
                    _buildRoleCard(
                      role: UserRole.volunteer,
                      context: context,
                    ),
                    const SizedBox(height: 20),
                    _buildRoleCard(
                      role: UserRole.recipient,
                      context: context,
                    ),
                    const SizedBox(height: 20),
                    _buildRoleCard(
                      role: UserRole.admin,
                      context: context,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required BuildContext context,
  }) {
    final primaryColor = RoleColors.getPrimaryColor(role);
    final lightColor = RoleColors.getLightColor(role);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AuthPage(initialRole: role), // Pass the selected role
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: lightColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getRoleIcon(role),
                  size: 32,
                  color: primaryColor,
                ),
              ),

              const SizedBox(width: 20),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getRoleName(role),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _getRoleDescription(role),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: primaryColor.withOpacity(0.7),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.donor:
        return Icons.restaurant;
      case UserRole.volunteer:
        return Icons.volunteer_activism;
      case UserRole.recipient:
        return Icons.people;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.donor:
        return 'Food Donor';
      case UserRole.volunteer:
        return 'Volunteer';
      case UserRole.recipient:
        return 'Recipient';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.donor:
        return 'Donate excess food to help those in need';
      case UserRole.volunteer:
        return 'Help collect and distribute food donations';
      case UserRole.recipient:
        return 'Receive food donations for your organization';
      case UserRole.admin:
        return 'Manage the platform and oversee operations';
    }
  }
}
