// pages/common/profile_page.dart
import 'package:annadanam_food_charity/pages/common/privacy_security_page.dart';
import 'package:annadanam_food_charity/pages/common/terms_conditions_page.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../models/user_role.dart';
import '../../utils/colors.dart';
import '../../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({super.key, required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  bool _isLoading = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    _nameController.text = widget.user.name;
    _emailController.text = widget.user.email;
    _phoneController.text = widget.user.phone ?? '';
    _addressController.text = widget.user.additionalInfo?['address'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = RoleColors.getPrimaryColor(widget.user.role);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileHeader(primaryColor),
              const SizedBox(height: 25),
              _buildProfileDetailsCard(primaryColor),
              const SizedBox(height: 25),
              _buildSettingsCard(primaryColor),
            ],
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: CircularProgressIndicator(color: primaryColor),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileHeader(Color primaryColor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, primaryColor.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Icon(
                _getRoleIcon(widget.user.role),
                size: 50,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.user.name,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              _getRoleDisplayName(widget.user.role),
              style:
                  TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetailsCard(Color primaryColor) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profile Information',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800),
                ),
                IconButton(
                  icon: Icon(_isEditing ? Icons.save : Icons.edit,
                      color: primaryColor),
                  onPressed: () {
                    setState(() {
                      if (_isEditing) _saveProfile();
                      _isEditing = !_isEditing;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildProfileField(
              label: 'Full Name',
              value: _nameController.text,
              icon: Icons.person,
              isEditing: _isEditing,
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            _buildProfileField(
              label: 'Email',
              value: _emailController.text,
              icon: Icons.email,
              isEditing: false,
              controller: _emailController,
            ),
            const SizedBox(height: 16),
            _buildProfileField(
              label: 'Phone Number',
              value: _phoneController.text,
              icon: Icons.phone,
              isEditing: _isEditing,
              controller: _phoneController,
            ),
            const SizedBox(height: 16),
            _buildProfileField(
              label: 'Address',
              value: _addressController.text,
              icon: Icons.location_on,
              isEditing: _isEditing,
              controller: _addressController,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(Color primaryColor) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800),
            ),
            const SizedBox(height: 20),
            _buildSettingItem(
              title: 'Privacy & Security',
              icon: Icons.security,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          PrivacySecurityPage(user: widget.user)),
                );
              },
            ),
            _buildSettingItem(
              title: 'Terms & Conditions',
              icon: Icons.description,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TermsConditionsPage(user: widget.user)),
                );
              },
            ),
            _buildSettingItem(
              title: 'Logout',
              icon: Icons.logout,
              color: Colors.red,
              onTap: () => _logout(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _printInvoice,
                icon: const Icon(Icons.print),
                label: const Text('PRINT INVOICE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _printInvoice() async {
    setState(() => _isLoading = true);
    try {
      final doc = pw.Document();
      final now = DateTime.now();
      final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(now);

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('ANNADANAM FOOD CHARITY',
                        style: pw.TextStyle(
                            fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text('INVOICE',
                        style: const pw.TextStyle(
                            fontSize: 20, color: PdfColors.grey700)),
                  ],
                ),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 20),
                pw.Text('Date: $formattedDate'),
                pw.Text('User ID: ${widget.user.id}'),
                pw.SizedBox(height: 30),
                pw.Text('Billed To:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(widget.user.name),
                pw.Text(widget.user.email),
                pw.Text(widget.user.phone ?? 'N/A'),
                pw.SizedBox(height: 40),
                pw.Table.fromTextArray(
                  headers: ['Description', 'Details'],
                  data: [
                    ['Service', 'Food Charity Platform Usage'],
                    ['Role', _getRoleDisplayName(widget.user.role)],
                    ['Account Status', 'Verified'],
                    ['Total Contribution', 'Calculated at Dashboard'],
                  ],
                  border: pw.TableBorder.all(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellAlignment: pw.Alignment.centerLeft,
                ),
                pw.Spacer(),
                pw.Divider(),
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Text('Thank you for being part of Annadanam!',
                      style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => doc.save());
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Print failed: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _saveProfile() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')));
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _apiService.logout();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required String value,
    required IconData icon,
    required bool isEditing,
    TextEditingController? controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 8),
        isEditing && controller != null
            ? TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(12),
                ),
                maxLines: maxLines,
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(value,
                    style:
                        TextStyle(fontSize: 16, color: Colors.grey.shade800)),
              ),
      ],
    );
  }

  Widget _buildSettingItem(
      {required String title,
      required IconData icon,
      required VoidCallback onTap,
      Color? color}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.grey.shade600),
            const SizedBox(width: 15),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                      fontSize: 16,
                      color: color ?? Colors.grey.shade800,
                      fontWeight: FontWeight.w500)),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

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
      default:
        return Icons.person;
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.donor:
        return 'Food Donor';
      case UserRole.volunteer:
        return 'Volunteer';
      case UserRole.recipient:
        return 'Recipient';
      case UserRole.admin:
        return 'Administrator';
      default:
        return role.name;
    }
  }
}
