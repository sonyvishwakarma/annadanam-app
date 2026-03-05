// pages/admin/volunteers_management.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/colors.dart';
import '../../services/api_service.dart';

class VolunteersManagementPage extends StatefulWidget {
  final User user;

  const VolunteersManagementPage({super.key, required this.user});

  @override
  _VolunteersManagementPageState createState() =>
      _VolunteersManagementPageState();
}

class _VolunteersManagementPageState extends State<VolunteersManagementPage> {
  List<Map<String, dynamic>> _volunteers = [];
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchVolunteers();
  }

  Future<void> _fetchVolunteers() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getAdminUsers('volunteer');
      if (response['success'] == true) {
        setState(() {
          _volunteers =
              List<Map<String, dynamic>>.from(response['users'] ?? []);
        });
      }
    } catch (e) {
      print('Error fetching volunteers: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final primaryColor = RoleColors.getPrimaryColor(widget.user.role);

    List<Map<String, dynamic>> filteredVolunteers =
        _volunteers.where((volunteer) {
      final matchesSearch = volunteer['name']
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          volunteer['email']
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());

      final matchesStatus =
          _filterStatus == 'all' || volunteer['status'] == _filterStatus;

      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search and Filter Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search volunteers...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          ),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _filterStatus,
                        items: const [
                          DropdownMenuItem(
                              value: 'all', child: Text('All Status')),
                          DropdownMenuItem(
                              value: 'active', child: Text('Active')),
                          DropdownMenuItem(
                              value: 'inactive', child: Text('Inactive')),
                          DropdownMenuItem(
                              value: 'pending', child: Text('Pending')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterStatus = value!;
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Stats Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildStatChip(
                          'Total: ${_volunteers.length}', primaryColor),
                      _buildStatChip(
                          'Active: ${_volunteers.where((v) => v['status'] == 'active').length}',
                          Colors.green),
                      _buildStatChip(
                          'Inactive: ${_volunteers.where((v) => v['status'] == 'inactive').length}',
                          Colors.orange),
                      _buildStatChip(
                          'Pending: ${_volunteers.where((v) => v['status'] == 'pending').length}',
                          Colors.blue),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Volunteers List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredVolunteers.length,
                    itemBuilder: (context, index) {
                      final volunteer = filteredVolunteers[index];
                      return _buildVolunteerCard(volunteer, primaryColor);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildVolunteerCard(
      Map<String, dynamic> volunteer, Color primaryColor) {
    Color statusColor = Colors.grey;
    if (volunteer['status'] == 'active') statusColor = Colors.green;
    if (volunteer['status'] == 'inactive') statusColor = Colors.orange;
    if (volunteer['status'] == 'pending') statusColor = Colors.blue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: primaryColor.withOpacity(0.1),
          child: Text(
            (volunteer['name'] ?? 'V')[0].toUpperCase(),
            style: TextStyle(color: primaryColor),
          ),
        ),
        title: Text(volunteer['name'] ?? 'Noname'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(volunteer['email'] ?? 'No email'),
            Row(
              children: [
                if (volunteer['rating'] != '0' && volunteer['rating'] != '0.0')
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('${volunteer['rating']}'),
                      const SizedBox(width: 8),
                    ],
                  ),
                Text('${volunteer['taskCount'] ?? 0} tasks'),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                (volunteer['status'] ?? 'pending').toString().toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        onTap: () => _viewVolunteerDetails(volunteer),
      ),
    );
  }

  void _viewVolunteerDetails(Map<String, dynamic> volunteer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(volunteer['name'] ?? 'Volunteer Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email:', volunteer['email'] ?? 'N/A'),
              _buildDetailRow('Phone:', volunteer['phone'] ?? 'N/A'),
              _buildDetailRow('Status:', volunteer['status'] ?? 'N/A'),
              _buildDetailRow(
                  'Tasks Completed:', '${volunteer['taskCount'] ?? 0}'),
              if (volunteer['rating'] != null &&
                  volunteer['rating'].toString() != '0' &&
                  volunteer['rating'].toString() != '0.0')
                _buildDetailRow('Rating:', volunteer['rating'].toString()),
              if (volunteer['lastActivity'] != null)
                _buildDetailRow('Last Activity:', volunteer['lastActivity'].toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (volunteer['status'] == 'pending')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => _approveVolunteer(volunteer),
                  child: const Text('Approve',
                      style: TextStyle(color: Colors.green)),
                ),
                TextButton(
                  onPressed: () => _rejectVolunteer(volunteer),
                  child:
                      const Text('Reject', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          if (volunteer['status'] == 'active')
            TextButton(
              onPressed: () => _deactivateVolunteer(volunteer),
              child: const Text('Deactivate',
                  style: TextStyle(color: Colors.orange)),
            ),
          if (volunteer['status'] == 'inactive')
            TextButton(
              onPressed: () => _activateVolunteer(volunteer),
              child:
                  const Text('Activate', style: TextStyle(color: Colors.green)),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _approveVolunteer(Map<String, dynamic> volunteer) async {
    try {
      final response =
          await _apiService.updateAdminUserStatus(volunteer['id'], 'active');
      if (response['success'] == true) {
        _fetchVolunteers();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${volunteer['name']} approved'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error approving volunteer: $e');
    }
  }

  Future<void> _activateVolunteer(Map<String, dynamic> volunteer) async {
    try {
      final response =
          await _apiService.updateAdminUserStatus(volunteer['id'], 'active');
      if (response['success'] == true) {
        _fetchVolunteers();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${volunteer['name']} activated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error activating volunteer: $e');
    }
  }

  Future<void> _deactivateVolunteer(Map<String, dynamic> volunteer) async {
    try {
      final response =
          await _apiService.updateAdminUserStatus(volunteer['id'], 'inactive');
      if (response['success'] == true) {
        _fetchVolunteers();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${volunteer['name']} deactivated'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error deactivating volunteer: $e');
    }
  }

  void _rejectVolunteer(Map<String, dynamic> volunteer) {
    // For now removal is okay manually, but ideally should be an API call
    setState(() {
      _volunteers.removeWhere((v) => v['id'] == volunteer['id']);
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${volunteer['name']} rejected'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
