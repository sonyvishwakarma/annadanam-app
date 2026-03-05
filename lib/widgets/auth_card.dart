// lib/widgets/auth_card.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';
import '../utils/colors.dart';
import 'package:annadanam_food_charity/pages/auth/auth_form.dart';
import '../pages/auth/forget_password.dart';

class AuthCard extends StatelessWidget {
  final UserRole role;
  final bool isLogin;
  final VoidCallback onToggle;
  final Function(User) onSuccess;

  const AuthCard({
    super.key,
    required this.role,
    required this.isLogin,
    required this.onToggle,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = RoleColors.getPrimaryColor(role);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Custom Tab Switcher
          _buildTabSwitcher(primaryColor),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                AuthForm(
                  role: role,
                  isLogin: isLogin,
                  onSuccess: onSuccess,
                ),
                if (isLogin) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordPage(role: role),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher(Color primaryColor) {
    if (role == UserRole.admin) {
      return Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.05),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: const Center(
          child: Text(
            'Admin Login',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
              letterSpacing: 1.2,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          _buildTabItem('Login', isLogin, primaryColor, onToggle),
          _buildTabItem('Sign Up', !isLogin, primaryColor, onToggle),
        ],
      ),
    );
  }

  Widget _buildTabItem(
      String title, bool active, Color primaryColor, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: active ? null : onTap,
        borderRadius: BorderRadius.only(
          topLeft: title == 'Login' ? const Radius.circular(24) : Radius.zero,
          topRight:
              title == 'Sign Up' ? const Radius.circular(24) : Radius.zero,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius:
                active ? BorderRadius.circular(24) : BorderRadius.zero,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? primaryColor : Colors.grey.shade500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
