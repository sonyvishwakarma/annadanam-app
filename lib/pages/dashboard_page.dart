// pages/dashboard_page.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';
import '../services/api_service.dart';
import '../utils/colors.dart';

// Donor Pages
import 'donor/donate_food.dart';
import 'donor/donation_requests.dart';
import 'donor/donor_dashboard.dart';
import 'donor/my_donations.dart';

// Volunteer Pages
import 'volunteer/my_tasks.dart';
import 'volunteer/schedule.dart';
import 'volunteer/volunteer_dashboard.dart';

// Recipient Pages
import 'recipient/my_deliveries.dart';
import 'recipient/recipient_dashboard.dart';
import 'recipient/request_food.dart';

// Admin Pages
import 'admin/admin_dashboard.dart';
import 'admin/donors_management.dart';
import 'admin/volunteers_management.dart';
import 'admin/recipients_management.dart';

// Chat Pages
import 'chat/chat_inbox_page.dart';

// Common Pages
import 'common/profile_page.dart';

class DashboardPage extends StatefulWidget {
  final User user;

  const DashboardPage({super.key, required this.user});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final primaryColor = RoleColors.getPrimaryColor(widget.user.role);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () => _showNotifications(),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: _getCurrentPage(),
      bottomNavigationBar: _buildBottomNavigationBar(primaryColor),
    );
  }

  String _getAppBarTitle() {
    switch (widget.user.role) {
      case UserRole.donor:
        final tabs = [
          'Dashboard',
          'Donate Food',
          'My Donations',
          'Requests',
          'Chat',
          'Profile',
        ];
        return tabs[_selectedIndex];
      case UserRole.volunteer:
        final tabs = [
          'Dashboard',
          'My Tasks',
          'Schedule',
          'Chat',
          'Profile',
        ];
        return tabs[_selectedIndex];
      case UserRole.recipient:
        final tabs = [
          'Dashboard',
          'Request Food',
          'My Deliveries',
          'Profile'
        ];
        return tabs[_selectedIndex];
      case UserRole.admin:
        final tabs = [
          'Dashboard',
          'Donors',
          'Volunteers',
          'Recipients',
          'Profile'
        ];
        return tabs[_selectedIndex];
    }
  }

  Widget _getCurrentPage() {
    switch (widget.user.role) {
      case UserRole.donor:
        return _getDonorPage();
      case UserRole.volunteer:
        return _getVolunteerPage();
      case UserRole.recipient:
        return _getRecipientPage();
      case UserRole.admin:
        return _getAdminPage();
    }
  }

  Widget _getDonorPage() {
    switch (_selectedIndex) {
      case 0:
        return DonorDashboardPage(user: widget.user);
      case 1:
        return DonateFoodPage(user: widget.user);
      case 2:
        return MyDonationsPage(user: widget.user);
      case 3:
        return DonationRequestsPage(user: widget.user);
      case 4:
        return ChatInboxPage(user: widget.user);
      case 5:
        return ProfilePage(user: widget.user);
      default:
        return DonorDashboardPage(user: widget.user);
    }
  }

  Widget _getVolunteerPage() {
    switch (_selectedIndex) {
      case 0:
        return VolunteerDashboardPage(user: widget.user);
      case 1:
        return MyTasksPage(user: widget.user);
      case 2:
        return SchedulePage(user: widget.user);
      case 3:
        return ChatInboxPage(user: widget.user);
      case 4:
        return ProfilePage(user: widget.user);
      default:
        return VolunteerDashboardPage(user: widget.user);
    }
  }

  Widget _getRecipientPage() {
    switch (_selectedIndex) {
      case 0:
        return RecipientDashboardPage(user: widget.user);
      case 1:
        return RequestFoodPage(user: widget.user);
      case 2:
        return MyDeliveriesPage(user: widget.user);
      case 3:
        return ProfilePage(user: widget.user);
      default:
        return RecipientDashboardPage(user: widget.user);
    }
  }

  Widget _getAdminPage() {
    switch (_selectedIndex) {
      case 0:
        return AdminDashboardPage(user: widget.user);
      case 1:
        return DonorsManagementPage(user: widget.user);
      case 2:
        return VolunteersManagementPage(user: widget.user);
      case 3:
        return RecipientsManagementPage(user: widget.user);
      case 4:
        return ProfilePage(user: widget.user);
      default:
        return AdminDashboardPage(user: widget.user);
    }
  }

  BottomNavigationBar _buildBottomNavigationBar(Color primaryColor) {
    switch (widget.user.role) {
      case UserRole.donor:
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.add_circle), label: 'Donate'),
            BottomNavigationBarItem(
                icon: Icon(Icons.food_bank), label: 'Donations'),
            BottomNavigationBarItem(
                icon: Icon(Icons.request_page), label: 'Requests'),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        );
      case UserRole.volunteer:
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
            BottomNavigationBarItem(
                icon: Icon(Icons.schedule), label: 'Schedule'),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        );
      case UserRole.recipient:
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.add_alert), label: 'Request'),
            BottomNavigationBarItem(
                icon: Icon(Icons.delivery_dining), label: 'Deliveries'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        );
      case UserRole.admin:
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.business), label: 'Donors'),
            BottomNavigationBarItem(
                icon: Icon(Icons.volunteer_activism), label: 'Volunteers'),
            BottomNavigationBarItem(
                icon: Icon(Icons.people), label: 'Recipients'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        );
    }
  }

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No new notifications'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final apiService = ApiService();
              await apiService.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
