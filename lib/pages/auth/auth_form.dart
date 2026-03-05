// lib/pages/auth/auth_form.dart
import 'package:flutter/material.dart';
import '../../models/user_role.dart';
import '../../models/user_model.dart';
import '../../utils/colors.dart';
import 'package:annadanam_food_charity/widgets/text_field.dart';
import 'package:annadanam_food_charity/services/api_service.dart';

class AuthForm extends StatefulWidget {
  final UserRole role;
  final bool isLogin;
  final Function(User) onSuccess;

  const AuthForm({
    super.key,
    required this.role,
    required this.isLogin,
    required this.onSuccess,
  });

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();

  // Basic controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Role-specific controllers
  final _organizationController = TextEditingController();
  final _locationController = TextEditingController();
  final _capacityController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _orgTypeController = TextEditingController();

  bool _isProcessing = false;
  bool _termsAccepted = false;
  String? _errorMessage;
  bool _usePhoneForLogin = false;
  final bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _organizationController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    _confirmPasswordController.dispose();
    _vehicleController.dispose();
    _orgTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = RoleColors.getPrimaryColor(widget.role);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildErrorDisplay(),
          if (!widget.isLogin) ...[
            _buildFieldGroup('Personal Information', [
              AuthTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                primaryColor: primaryColor,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
            ]),
          ],
          _buildAuthMethodToggle(primaryColor),
          const SizedBox(height: 16),
          _buildMainFields(primaryColor),
          if (!widget.isLogin) ...[
            const SizedBox(height: 16),
            _buildRoleSpecificFields(primaryColor),
          ],
          const SizedBox(height: 16),
          _buildPasswordFields(primaryColor),
          if (!widget.isLogin) _buildTermsCheckbox(primaryColor),
          const SizedBox(height: 32),
          _buildSubmitButton(primaryColor),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay() {
    if (_errorMessage == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: Colors.red),
            onPressed: () => setState(() => _errorMessage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthMethodToggle(Color primaryColor) {
    if (!widget.isLogin) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _methodToggleItem('Email', !_usePhoneForLogin, primaryColor,
              () => setState(() => _usePhoneForLogin = false)),
          _methodToggleItem('Phone', _usePhoneForLogin, primaryColor,
              () => setState(() => _usePhoneForLogin = true)),
        ],
      ),
    );
  }

  Widget _methodToggleItem(
      String label, bool active, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: active
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                color: active ? color : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainFields(Color primaryColor) {
    final showEmail = !widget.isLogin || !_usePhoneForLogin;
    final showPhone = !widget.isLogin || _usePhoneForLogin;

    return Column(
      children: [
        if (showEmail)
          AuthTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            primaryColor: primaryColor,
            keyboardType: TextInputType.emailAddress,
            hintText: 'example@gmail.com',
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v)) {
                return 'Invalid email format';
              }
              return null;
            },
          ),
        if (showEmail && showPhone) const SizedBox(height: 16),
        if (showPhone)
          AuthTextField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            primaryColor: primaryColor,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            hintText: '10-digit number',
            validator: (v) {
              if (v == null || v.isEmpty) return 'Phone is required';
              if (!RegExp(r'^[0-9]{10}$').hasMatch(v)) {
                return 'Enter valid 10-digit number';
              }
              return null;
            },
          ),
      ],
    );
  }

  Widget _buildPasswordFields(Color primaryColor) {
    return Column(
      children: [
        AuthTextField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.lock_outline,
          primaryColor: primaryColor,
          isPassword: !_showPassword,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Password is required';
            if (v.length < 6) return 'Minimum 6 characters';
            return null;
          },
        ),
        if (!widget.isLogin) ...[
          const SizedBox(height: 16),
          AuthTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            icon: Icons.lock_reset_outlined,
            primaryColor: primaryColor,
            isPassword: true,
            validator: (v) {
              if (v != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildRoleSpecificFields(Color primaryColor) {
    switch (widget.role) {
      case UserRole.donor:
        return _buildFieldGroup('Donation Details', [
          AuthTextField(
            controller: _organizationController,
            label: 'Organization (if any)',
            icon: Icons.business_outlined,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _capacityController,
            label: 'Monthly Food Capacity (kg)',
            icon: Icons.line_weight_outlined,
            primaryColor: primaryColor,
            keyboardType: TextInputType.number,
          ),
        ]);
      case UserRole.volunteer:
        return _buildFieldGroup('Volunteer Details', [
          AuthTextField(
            controller: _locationController,
            label: 'Preferred Search Area',
            icon: Icons.map_outlined,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _vehicleController,
            label: 'Vehicle (e.g. Scooter, Car)',
            icon: Icons.delivery_dining_outlined,
            primaryColor: primaryColor,
          ),
        ]);
      case UserRole.recipient:
        return _buildFieldGroup('Recipient Info', [
          AuthTextField(
            controller: _locationController,
            label: 'Delivery Address',
            icon: Icons.home_work_outlined,
            primaryColor: primaryColor,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _capacityController,
            label: 'People to Feed (Daily)',
            icon: Icons.groups_outlined,
            primaryColor: primaryColor,
            keyboardType: TextInputType.number,
          ),
        ]);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFieldGroup(String label, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.blueGrey)),
        ),
        ...children,
      ],
    );
  }

  Widget _buildTermsCheckbox(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Checkbox(
            value: _termsAccepted,
            activeColor: primaryColor,
            onChanged: (v) => setState(() => _termsAccepted = v ?? false),
          ),
          Expanded(
            child: Text(
              'I agree to the Terms & Privacy Policy',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(Color primaryColor) {
    return ElevatedButton(
      onPressed: _isProcessing ? null : _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        shadowColor: primaryColor.withOpacity(0.4),
      ),
      child: _isProcessing
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2))
          : Text(
              widget.isLogin ? 'LOGIN' : 'CREATE ACCOUNT',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
            ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (!widget.isLogin && !_termsAccepted) {
      setState(() => _errorMessage = 'Please accept the Terms & Conditions');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final apiService = ApiService();
      Map<String, dynamic> result;

      if (widget.isLogin) {
        if (_usePhoneForLogin) {
          result = await apiService.loginWithPhone(
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
          );
        } else {
          result = await apiService.loginWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
        }
      } else {
        result = await apiService.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          role: widget.role,
          additionalInfo: _getAdditionalInfo(),
        );
      }

      if (result['success'] == true) {
        widget.onSuccess(result['user']);
      } else {
        setState(() => _errorMessage = result['message'] ?? 'Action failed');
      }
    } catch (e) {
      setState(() => _errorMessage = 'A network error occurred');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Map<String, dynamic> _getAdditionalInfo() {
    final info = <String, dynamic>{};
    if (widget.role == UserRole.donor) {
      info['organization'] = _organizationController.text;
      info['capacity'] = _capacityController.text;
    } else if (widget.role == UserRole.volunteer) {
      info['location'] = _locationController.text;
      info['vehicle'] = _vehicleController.text;
    } else if (widget.role == UserRole.recipient) {
      info['address'] = _locationController.text;
      info['peopleCount'] = _capacityController.text;
    }
    return info;
  }
}
