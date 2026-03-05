// pages/common/terms_conditions_page.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/colors.dart';
import '../../services/api_service.dart';

class TermsConditionsPage extends StatefulWidget {
  final User user;
  final bool showPrivacyPolicy;

  const TermsConditionsPage({
    super.key,
    required this.user,
    this.showPrivacyPolicy = false,
  });

  @override
  _TermsConditionsPageState createState() => _TermsConditionsPageState();
}

class _TermsConditionsPageState extends State<TermsConditionsPage> {
  bool _acceptedTerms = false;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkExistingAcceptance();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingAcceptance() async {
    // Check if user has already accepted terms
    // This is a placeholder - implement actual check from SharedPreferences or backend
    final user = await _apiService.getStoredUser();
    if (user != null && mounted) {
      setState(() {
        _acceptedTerms = true; // Or load from stored preference
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = RoleColors.getPrimaryColor(widget.user.role);
    final isPrivacyPolicy = widget.showPrivacyPolicy;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isPrivacyPolicy ? 'Privacy Policy' : 'Terms & Conditions',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printDocument,
            tooltip: 'Print/Save as PDF',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareDocument,
            tooltip: 'Share',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      )
          : Column(
        children: [
          // Header with version info
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            color: primaryColor.withValues(alpha : 0.1),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Last updated: ${_getLastUpdatedDate(isPrivacyPolicy)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (!isPrivacyPolicy)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Version 2.1.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick navigation tabs
                    _buildQuickNavigationTabs(isPrivacyPolicy, primaryColor),
                    const SizedBox(height: 24),

                    // Main content
                    if (!isPrivacyPolicy) ...[
                      _buildTermsContent(),
                    ] else ...[
                      _buildPrivacyContent(),
                    ],

                    const SizedBox(height: 30),

                    // Contact Section
                    _buildContactSection(primaryColor),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // Accept Button (only for Terms & Conditions)
          if (!isPrivacyPolicy) _buildAcceptButton(primaryColor),
        ],
      ),
    );
  }

  Widget _buildQuickNavigationTabs(bool isPrivacyPolicy, Color primaryColor) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildNavChip('Overview', 0, isPrivacyPolicy, primaryColor),
          _buildNavChip('Information', 1, isPrivacyPolicy, primaryColor),
          _buildNavChip('Rights', 2, isPrivacyPolicy, primaryColor),
          _buildNavChip('Security', 3, isPrivacyPolicy, primaryColor),
          _buildNavChip('Contact', 4, isPrivacyPolicy, primaryColor),
        ],
      ),
    );
  }

  Widget _buildNavChip(String label, int index, bool isPrivacyPolicy, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: false,
        onSelected: (_) => _scrollToSection(index),
        backgroundColor: Colors.grey.shade100,
        selectedColor: primaryColor.withValues(alpha:0.2),
        checkmarkColor: primaryColor,
        labelStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildTermsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade200.withValues(alpha:0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.gavel, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Text(
                    'Terms of Service',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Welcome to Annadanam Food Charity. By using our platform, you agree to these terms. Please read them carefully.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        _buildSectionSubtitle('1. Acceptance of Terms', 1),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Text(
            'By accessing and using the Annadanam Food Charity platform, you accept and agree to be bound by these terms and conditions. If you do not agree to any part of these terms, you may not access or use our services.',
            style: TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
          ),
        ),

        const SizedBox(height: 20),
        _buildSectionSubtitle('2. Description of Service', 2),
        const SizedBox(height: 8),
        const Text(
          'Annadanam Food Charity is a platform that connects food donors with volunteers and recipients to reduce food waste and fight hunger.',
          style: TextStyle(fontSize: 14, height: 1.6),
        ),
        const SizedBox(height: 12),
        _buildBulletList([
          'Food donation listings with real-time updates',
          'Volunteer coordination and scheduling',
          'Recipient request management system',
          'Delivery tracking and notifications',
          'Impact metrics and reporting',
        ], Icons.check_circle, Colors.green),

        const SizedBox(height: 20),
        _buildSectionSubtitle('3. User Responsibilities', 3),
        const SizedBox(height: 8),
        const Text(
          'As a user of our platform, you agree to:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        _buildBulletList([
          'Provide accurate, current, and complete information',
          'Maintain and update your information',
          'Maintain food safety standards and quality',
          'Respect other users\' privacy and rights',
          'Not misuse the platform for illegal activities',
          'Report any suspicious or fraudulent activities',
        ], Icons.verified_user, Colors.blue),

        const SizedBox(height: 20),
        _buildSectionSubtitle('4. Food Safety & Quality', 4),
        const SizedBox(height: 8),
        const Text(
          'Food donors are responsible for ensuring that all donated food meets these standards:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        _buildBulletList([
          'Fresh and safe for human consumption',
          'Properly packaged and sealed',
          'Clearly labeled with preparation date and ingredients',
          'Stored at appropriate temperatures',
          'Free from contamination and spoilage',
          'Within expiration date',
        ], Icons.food_bank, Colors.orange),

        const SizedBox(height: 20),
        _buildSectionSubtitle('5. Liability Limitations', 5),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.amber.shade800, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Important Disclaimer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Annadanam Food Charity acts as a platform connector and is not responsible for:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              _buildBulletList([
                'Quality, safety, or suitability of donated food',
                'Actions, omissions, or conduct of individual users',
                'Delivery delays, damages, or failures',
                'Any health issues arising from consumed food',
                'Third-party services or integrations',
              ], Icons.warning, Colors.amber.shade800),
            ],
          ),
        ),

        const SizedBox(height: 20),
        _buildSectionSubtitle('6. Account Termination', 6),
        const SizedBox(height: 8),
        const Text(
          'We reserve the right to suspend or terminate accounts that:',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 12),
        _buildBulletList([
          'Violate our terms of service',
          'Provide false or misleading information',
          'Engage in fraudulent or deceptive activities',
          'Harass or harm other users',
          'Attempt to circumvent our systems',
        ], Icons.block, Colors.red),

        const SizedBox(height: 20),
        _buildSectionSubtitle('7. Intellectual Property', 7),
        const SizedBox(height: 8),
        const Text(
          'All content and materials available on the platform, including but not limited to text, graphics, logos, and software, are the property of Annadanam Food Charity and are protected by applicable intellectual property laws.',
          style: TextStyle(fontSize: 14, height: 1.6),
        ),

        const SizedBox(height: 20),
        _buildSectionSubtitle('8. Modifications to Terms', 8),
        const SizedBox(height: 8),
        const Text(
          'We may modify these terms at any time. We will notify users of any material changes via email or through the platform. Continued use of the service after such modifications constitutes acceptance of the updated terms.',
          style: TextStyle(fontSize: 14, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildPrivacyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade50, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.shade200.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.privacy_tip, color: Colors.green.shade700),
                  const SizedBox(width: 12),
                  Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Your privacy is important to us. This policy explains how we collect, use, and protect your personal information.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        _buildSectionSubtitle('1. Information We Collect', 1),
        const SizedBox(height: 8),
        const Text(
          'We collect the following types of information to provide and improve our services:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        _buildBulletList([
          'Personal Information: Name, email address, phone number',
          'Location Data: For food pickup and delivery coordination',
          'Usage Data: App interactions, preferences, and feedback',
          'Device Information: Device type, OS version, unique identifiers',
          'Donation/Request History: Records of your platform activity',
        ], Icons.info, Colors.blue),

        const SizedBox(height: 20),
        _buildSectionSubtitle('2. How We Use Your Information', 2),
        const SizedBox(height: 8),
        _buildBulletList([
          'Provide, maintain, and improve our services',
          'Connect donors with volunteers and recipients',
          'Ensure food safety and traceability',
          'Send important updates and notifications',
          'Analyze platform usage and user behavior',
          'Prevent fraud and enhance security',
          'Comply with legal obligations',
        ], Icons.settings_applications, Colors.purple),

        const SizedBox(height: 20),
        _buildSectionSubtitle('3. Data Sharing and Disclosure', 3),
        const SizedBox(height: 8),
        const Text(
          'We may share your information with:',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 12),
        _buildBulletList([
          'Other users necessary for service delivery',
          'Service providers and business partners',
          'Law enforcement when required by law',
          'During business transfers or mergers',
        ], Icons.share, Colors.orange),

        const SizedBox(height: 20),
        _buildSectionSubtitle('4. Data Security', 4),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.security, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Security Measures',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildBulletList([
                'End-to-end encryption for sensitive data',
                'Secure HTTPS connections',
                'Regular security audits and penetration testing',
                'Strict access controls and authentication',
                'Data anonymization where applicable',
              ], Icons.check, Colors.blue.shade700),
            ],
          ),
        ),

        const SizedBox(height: 20),
        _buildSectionSubtitle('5. Your Rights and Choices', 5),
        const SizedBox(height: 8),
        _buildBulletList([
          'Access your personal data',
          'Correct inaccurate or incomplete information',
          'Request deletion of your data',
          'Opt-out of marketing communications',
          'Export your data in portable format',
          'Withdraw consent at any time',
        ], Icons.verified_user, Colors.green),

        const SizedBox(height: 20),
        _buildSectionSubtitle('6. Cookies and Tracking', 6),
        const SizedBox(height: 8),
        const Text(
          'We use cookies and similar technologies to:',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 12),
        _buildBulletList([
          'Remember user preferences and settings',
          'Analyze site traffic and usage patterns',
          'Improve user experience',
          'Personalize content and recommendations',
        ], Icons.cookie, Colors.brown),

        const SizedBox(height: 20),
        _buildSectionSubtitle('7. Data Retention', 7),
        const SizedBox(height: 8),
        const Text(
          'We retain your personal information for as long as your account is active or as needed to provide services. You may request deletion of your account at any time, and we will delete your information within 30 days, subject to legal requirements.',
          style: TextStyle(fontSize: 14, height: 1.6),
        ),

        const SizedBox(height: 20),
        _buildSectionSubtitle('8. Children\'s Privacy', 8),
        const SizedBox(height: 8),
        const Text(
          'Our services are not intended for individuals under the age of 13. We do not knowingly collect personal information from children under 13. If we become aware that a child under 13 has provided us with personal information, we will take steps to delete such information.',
          style: TextStyle(fontSize: 14, height: 1.6),
        ),

        const SizedBox(height: 20),
        _buildSectionSubtitle('9. International Data Transfers', 9),
        const SizedBox(height: 8),
        const Text(
          'Your information may be transferred to and processed in countries other than your own. We ensure appropriate safeguards are in place to protect your data in accordance with this policy.',
          style: TextStyle(fontSize: 14, height: 1.6),
        ),

        const SizedBox(height: 20),
        _buildSectionSubtitle('10. Changes to This Policy', 10),
        const SizedBox(height: 8),
        const Text(
          'We may update this privacy policy from time to time. We will notify you of any significant changes by posting the new policy on this page and updating the "Last updated" date.',
          style: TextStyle(fontSize: 14, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildContactSection(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha:0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contact_support, color: primaryColor),
              const SizedBox(width: 12),
              Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'For any questions about these terms or privacy policy, please contact us:',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          _buildContactItem(Icons.email, 'Email:', 'privacy@annadanam.org'),
          const SizedBox(height: 12),
          _buildContactItem(Icons.phone, 'Phone:', '+91 98765 43210'),
          const SizedBox(height: 12),
          _buildContactItem(Icons.location_on, 'Address:',
              'Annadanam Foundation, 123 Charity Street, Andheri East, Mumbai - 400069, India'),
          const SizedBox(height: 12),
          _buildContactItem(Icons.access_time, 'Response Time:', 'Within 48 hours'),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildBulletList(List<String> items, IconData icon, Color iconColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  icon,
                  size: 16,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSectionSubtitle(String subtitle, int sectionNumber) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              sectionNumber.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildAcceptButton(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha : 0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Agreement checkbox with improved styling
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() => _acceptedTerms = !_acceptedTerms);
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _acceptedTerms ? primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _acceptedTerms ? primaryColor : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: _acceptedTerms
                          ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18,
                      )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'I have read and agree to the Terms & Conditions',
                        style: TextStyle(
                          color: _acceptedTerms ? primaryColor : Colors.grey.shade700,
                          fontWeight: _acceptedTerms ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Accept button with loading state
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _acceptedTerms && !_isLoading ? _acceptTerms : null,
              icon: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.check_circle),
              label: Text(
                _isLoading ? 'Processing...' : 'Accept & Continue',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: _acceptedTerms ? 2 : 0,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Additional info
          Text(
            'By accepting, you confirm that you are legally bound by these terms',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getLastUpdatedDate(bool isPrivacyPolicy) {
    // Return actual last updated dates
    if (isPrivacyPolicy) {
      return 'February 15, 2024';
    } else {
      return 'February 10, 2024';
    }
  }

  void _scrollToSection(int index) {
    double offset = 0;
    switch (index) {
      case 0: offset = 0; break;
      case 1: offset = 400; break;
      case 2: offset = 800; break;
      case 3: offset = 1200; break;
      case 4: offset = 2000; break;
    }
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _printDocument() async {
    // TODO: Implement print/PDF functionality
    _showSnackBar(
      'Preparing document for print/PDF...',
      Colors.blue,
    );
  }

  Future<void> _shareDocument() async {
    // TODO: Implement share functionality
    _showSnackBar(
      'Sharing document...',
      Colors.green,
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

  Future<void> _acceptTerms() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Save acceptance to backend/local storage
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      if (mounted) {
        _showSnackBar(
          'Terms & Conditions accepted successfully!',
          Colors.green,
        );

        Navigator.pop(context, true); // Return true to indicate acceptance
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Failed to accept terms. Please try again.',
          Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}