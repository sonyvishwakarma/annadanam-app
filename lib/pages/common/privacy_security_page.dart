// pages/common/privacy_security_page.dart
import 'package:annadanam_food_charity/pages/common/terms_conditions_page.dart';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../utils/colors.dart';

class PrivacySecurityPage extends StatefulWidget {
  final User user;

  const PrivacySecurityPage({super.key, required this.user});

  @override
  _PrivacySecurityPageState createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  // Privacy Settings
  bool _locationSharing = true;
  bool _profileVisibility = true;
  bool _activityTracking = true;
  bool _dataSharing = true;

  // Notification Settings
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;

  // Security Settings
  bool _isLoading = false;

  // Controllers for password change
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _deletePasswordController =
      TextEditingController();

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _deletePasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPreferences() async {
    // Load user preferences from SharedPreferences or backend
    // This is a placeholder - implement actual loading logic
    setState(() {
      // Load saved preferences here
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = RoleColors.getPrimaryColor(widget.user.role);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserPreferences,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Privacy Section
                  _buildPrivacySection(primaryColor),
                  const SizedBox(height: 20),

                  // Notification Section
                  _buildNotificationSection(primaryColor),
                  const SizedBox(height: 20),

                  // Security Section
                  _buildSecuritySection(primaryColor),
                  const SizedBox(height: 20),

                  // Save Button
                  _buildSaveButton(primaryColor),
                  const SizedBox(height: 20),

                  // Privacy Policy Link
                  _buildPrivacyPolicyLink(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildPrivacySection(Color primaryColor) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.privacy_tip, color: primaryColor),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Privacy Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Location Sharing
            SwitchListTile(
              title: const Text(
                'Location Sharing',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                'Allow the app to use your location for better service',
                style: TextStyle(fontSize: 13),
              ),
              value: _locationSharing,
              onChanged: (value) {
                setState(() => _locationSharing = value);
                _showSnackBar(
                  'Location sharing ${value ? 'enabled' : 'disabled'}',
                  Colors.green,
                );
              },
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _locationSharing
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_on,
                  color: _locationSharing ? Colors.green : Colors.grey,
                ),
              ),
              activeThumbColor: Colors.green,
            ),
            const Divider(),

            // Profile Visibility
            SwitchListTile(
              title: const Text(
                'Profile Visibility',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                'Make your profile visible to other users',
                style: TextStyle(fontSize: 13),
              ),
              value: _profileVisibility,
              onChanged: (value) {
                setState(() => _profileVisibility = value);
                _showSnackBar(
                  'Profile is now ${value ? 'visible' : 'hidden'}',
                  Colors.blue,
                );
              },
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _profileVisibility
                      ? Colors.blue.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.visibility,
                  color: _profileVisibility ? Colors.blue : Colors.grey,
                ),
              ),
              activeThumbColor: Colors.blue,
            ),
            const Divider(),

            // Activity Tracking
            SwitchListTile(
              title: const Text(
                'Activity Tracking',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                'Allow the app to track your activity for personalized experience',
                style: TextStyle(fontSize: 13),
              ),
              value: _activityTracking,
              onChanged: (value) {
                setState(() => _activityTracking = value);
                _showSnackBar(
                  'Activity tracking ${value ? 'enabled' : 'disabled'}',
                  Colors.orange,
                );
              },
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _activityTracking
                      ? Colors.orange.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.track_changes,
                  color: _activityTracking ? Colors.orange : Colors.grey,
                ),
              ),
              activeThumbColor: Colors.orange,
            ),
            const Divider(),

            // Data Sharing
            SwitchListTile(
              title: const Text(
                'Data Sharing',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                'Share anonymous data to improve our services',
                style: TextStyle(fontSize: 13),
              ),
              value: _dataSharing,
              onChanged: (value) {
                setState(() => _dataSharing = value);
                _showSnackBar(
                  'Data sharing ${value ? 'enabled' : 'disabled'}',
                  Colors.purple,
                );
              },
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _dataSharing
                      ? Colors.purple.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.share,
                  color: _dataSharing ? Colors.purple : Colors.grey,
                ),
              ),
              activeThumbColor: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(Color primaryColor) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.notifications, color: primaryColor),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Notification Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Email Notifications
            SwitchListTile(
              title: const Text(
                'Email Notifications',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                'Receive updates via email',
                style: TextStyle(fontSize: 13),
              ),
              value: _emailNotifications,
              onChanged: (value) {
                setState(() => _emailNotifications = value);
                _showSnackBar(
                  'Email notifications ${value ? 'enabled' : 'disabled'}',
                  Colors.red,
                );
              },
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _emailNotifications
                      ? Colors.red.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.email,
                  color: _emailNotifications ? Colors.red : Colors.grey,
                ),
              ),
              activeThumbColor: Colors.red,
            ),
            const Divider(),

            // Push Notifications
            SwitchListTile(
              title: const Text(
                'Push Notifications',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                'Receive in-app notifications',
                style: TextStyle(fontSize: 13),
              ),
              value: _pushNotifications,
              onChanged: (value) {
                setState(() => _pushNotifications = value);
                _showSnackBar(
                  'Push notifications ${value ? 'enabled' : 'disabled'}',
                  Colors.amber,
                );
              },
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _pushNotifications
                      ? Colors.amber.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.notifications_active,
                  color: _pushNotifications ? Colors.amber : Colors.grey,
                ),
              ),
              activeThumbColor: Colors.amber,
            ),
            const Divider(),

            // SMS Notifications
            SwitchListTile(
              title: const Text(
                'SMS Notifications',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                'Receive updates via SMS',
                style: TextStyle(fontSize: 13),
              ),
              value: _smsNotifications,
              onChanged: (value) {
                setState(() => _smsNotifications = value);
                _showSnackBar(
                  'SMS notifications ${value ? 'enabled' : 'disabled'}',
                  Colors.green,
                );
              },
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _smsNotifications
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.sms,
                  color: _smsNotifications ? Colors.green : Colors.grey,
                ),
              ),
              activeThumbColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection(Color primaryColor) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.security, color: primaryColor),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Security Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Change Password
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.password, color: primaryColor),
              ),
              title: const Text(
                'Change Password',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                'Update your account password',
                style: TextStyle(fontSize: 13),
              ),
              trailing: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              onTap: _changePassword,
            ),
            const Divider(),

            // Session Management
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.devices, color: primaryColor),
              ),
              title: const Text(
                'Active Sessions',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                'Manage your logged-in devices',
                style: TextStyle(fontSize: 13),
              ),
              trailing: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              onTap: _showActiveSessions,
            ),
            const Divider(),

            // Data Export
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.download, color: primaryColor),
              ),
              title: const Text(
                'Export Data',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                'Download your personal data',
                style: TextStyle(fontSize: 13),
              ),
              trailing: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              onTap: _exportData,
            ),
            const Divider(),

            // Delete Account
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.delete, color: Colors.red),
              ),
              title: const Text(
                'Delete Account',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
              subtitle: const Text(
                'Permanently delete your account and all data',
                style: TextStyle(fontSize: 13, color: Colors.red),
              ),
              trailing: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.red),
              ),
              onTap: _deleteAccount,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(Color primaryColor) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _saveSettings,
        icon: const Icon(Icons.save),
        label: const Text(
          'Save Settings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicyLink() {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TermsConditionsPage(
                user: widget.user,
                showPrivacyPolicy: true,
              ),
            ),
          );
        },
        icon: const Icon(Icons.privacy_tip, size: 18),
        label: const Text('View Privacy Policy'),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  Future<void> _saveSettings() async {
    _setLoading(true);

    try {
      // TODO: Implement API call to save settings
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      if (mounted) {
        _showSnackBar(
          'Privacy settings saved successfully!',
          Colors.green,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Failed to save settings. Please try again.',
          Colors.red,
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _changePassword() async {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _currentPasswordController,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.lock_clock),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_newPasswordController.text.isEmpty) {
                _showSnackBar('New password cannot be empty', Colors.red);
                return;
              }
              if (_newPasswordController.text ==
                  _confirmPasswordController.text) {
                Navigator.pop(context); // Close dialog first
                _setLoading(true);
                try {
                  final result = await _apiService.changePassword(
                    currentPassword: _currentPasswordController.text,
                    newPassword: _newPasswordController.text,
                  );

                  if (result['success'] == true) {
                    _showSnackBar(
                        'Password changed successfully!', Colors.green);
                  } else {
                    _showSnackBar(
                        result['message'] ?? 'Failed to change password',
                        Colors.red);
                  }
                } catch (e) {
                  _showSnackBar(
                      'An error occurred. Please try again.', Colors.red);
                } finally {
                  _setLoading(false);
                }
              } else {
                _showSnackBar('Passwords do not match', Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: RoleColors.getPrimaryColor(widget.user.role),
              foregroundColor: Colors.white,
            ),
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  Future<void> _showActiveSessions() async {
    final sessions = [
      {
        'device': 'iPhone 13',
        'location': 'Mumbai, IN',
        'lastActive': '2 hours ago',
        'current': true
      },
      {
        'device': 'Chrome Browser',
        'location': 'Delhi, IN',
        'lastActive': '1 day ago',
        'current': false
      },
      {
        'device': 'Samsung Galaxy S21',
        'location': 'Bangalore, IN',
        'lastActive': '3 days ago',
        'current': false
      },
    ];

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Active Sessions'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final isCurrent = session['current'] as bool;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.devices,
                      color: isCurrent ? Colors.green : Colors.grey,
                    ),
                  ),
                  title: Text(
                    session['device'] as String,
                    style: TextStyle(
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    '${session['location']} • ${session['lastActive']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: isCurrent
                      ? Chip(
                          label: const Text('Current'),
                          backgroundColor: Colors.green.shade100,
                          labelStyle: const TextStyle(fontSize: 12),
                        )
                      : IconButton(
                          icon: const Icon(Icons.logout, color: Colors.red),
                          onPressed: () {
                            // TODO: Logout from this device
                            Navigator.pop(context);
                            _showSnackBar(
                              'Logged out from ${session['device']}',
                              Colors.green,
                            );
                          },
                        ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _setLoading(true);
              try {
                final result = await _apiService.removeActiveSessions();
                if (result['success'] == true) {
                  _showSnackBar(
                      'Logged out from all other devices', Colors.green);
                } else {
                  _showSnackBar(
                      result['message'] ?? 'Failed to remove sessions',
                      Colors.red);
                }
              } catch (e) {
                _showSnackBar('An error occurred', Colors.red);
              } finally {
                _setLoading(false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout All'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.download_for_offline,
              size: 60,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'Your personal data will be prepared and sent to your registered email address.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.user.email,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'This may take a few minutes.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _setLoading(true);
              try {
                final result = await _apiService.exportData();
                if (result['success'] == true) {
                  // In a real app, you might save this as a file or show it.
                  // For now, we'll tell the user it's been prepared.
                  _showSnackBar(
                    'Data exported successfully! Check your email for details.',
                    Colors.green,
                  );
                } else {
                  _showSnackBar(
                      result['message'] ?? 'Failed to export data', Colors.red);
                }
              } catch (e) {
                _showSnackBar('An error occurred during export', Colors.red);
              } finally {
                _setLoading(false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: RoleColors.getPrimaryColor(widget.user.role),
              foregroundColor: Colors.white,
            ),
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'This action cannot be undone. All your data will be permanently deleted.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Are you absolutely sure you want to proceed?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmAccountDeletion();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAccountDeletion() async {
    _deletePasswordController.clear();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your password to permanently delete your account:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _deletePasswordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.lock),
              ),
              obscureText: true,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_deletePasswordController.text.isNotEmpty) {
                // TODO: API call to delete account
                Navigator.pop(context); // Close confirmation dialog
                Navigator.pop(context); // Close security dialog

                _showSnackBar(
                  'Account deleted successfully',
                  Colors.red,
                );

                // Navigate to login screen after delay
                await Future.delayed(const Duration(seconds: 2));
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Delete'),
          ),
        ],
      ),
    );
  }
}
