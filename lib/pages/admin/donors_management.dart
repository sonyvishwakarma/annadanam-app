// pages/admin/donors_management.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/colors.dart';
import '../../services/api_service.dart';

class DonorsManagementPage extends StatefulWidget {
  final User user;

  const DonorsManagementPage({super.key, required this.user});

  @override
  _DonorsManagementPageState createState() => _DonorsManagementPageState();
}

class _DonorsManagementPageState extends State<DonorsManagementPage> {
  List<Map<String, dynamic>> _donors = [];
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchDonors();
  }

  Future<void> _fetchDonors() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getAdminUsers('donor');
      if (response['success'] == true) {
        setState(() {
          _donors = List<Map<String, dynamic>>.from(response['users'] ?? []);
        });
      }
    } catch (e) {
      print('Error fetching donors: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'all';
  String _filterType = 'all';

  @override
  Widget build(BuildContext context) {
    final primaryColor = RoleColors.getPrimaryColor(widget.user.role);

    List<Map<String, dynamic>> filteredDonors = _donors.where((donor) {
      final name = (donor['name'] ?? '').toString().toLowerCase();
      final email = (donor['email'] ?? '').toString().toLowerCase();
      final searchTerm = _searchController.text.toLowerCase();
      final matchesSearch =
          name.contains(searchTerm) || email.contains(searchTerm);

      final status = (donor['status'] ?? 'active').toString();
      final matchesStatus = _filterStatus == 'all' || status == _filterStatus;

      // type comes from additionalInfo.donorType
      final additionalInfo = donor['additionalInfo'];
      final donorType =
          additionalInfo is Map ? (additionalInfo['donorType'] ?? '') : '';
      final matchesType = _filterType == 'all' || donorType == _filterType;

      return matchesSearch && matchesStatus && matchesType;
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
                          hintText: 'Search donors...',
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
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _filterStatus,
                              items: const [
                                DropdownMenuItem(
                                    value: 'all', child: Text('All Status')),
                                DropdownMenuItem(
                                    value: 'active', child: Text('Active')),
                                DropdownMenuItem(
                                    value: 'inactive', child: Text('Inactive')),
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
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _filterType,
                              items: const [
                                DropdownMenuItem(
                                    value: 'all', child: Text('All Types')),
                                DropdownMenuItem(
                                    value: 'restaurant',
                                    child: Text('Restaurant')),
                                DropdownMenuItem(
                                    value: 'catering', child: Text('Catering')),
                                DropdownMenuItem(
                                    value: 'organization',
                                    child: Text('Organization')),
                                DropdownMenuItem(
                                    value: 'hotel', child: Text('Hotel')),
                                DropdownMenuItem(
                                    value: 'community',
                                    child: Text('Community')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _filterType = value!;
                                });
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Stats Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildStatChip('Total: ${_donors.length}', primaryColor),
                      const SizedBox(width: 10),
                      _buildStatChip(
                          'Active: ${_donors.where((d) => d['status'] == 'active').length}',
                          Colors.green),
                      const SizedBox(width: 10),
                      _buildStatChip(
                          'Inactive: ${_donors.where((d) => d['status'] == 'inactive').length}',
                          Colors.orange),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Donors List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredDonors.length,
                    itemBuilder: (context, index) {
                      final donor = filteredDonors[index];
                      return _buildDonorCard(donor, primaryColor);
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewDonor,
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
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

  Widget _buildDonorCard(Map<String, dynamic> donor, Color primaryColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getDonorIcon(() {
              final ai = donor['additionalInfo'];
              return ai is Map ? (ai['donorType'] ?? '') : '';
            }()),
            color: primaryColor,
            size: 20,
          ),
        ),
        title: Text(donor['name'] ?? ''),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(donor['email'] ?? ''),
            Text('${donor['donationCount'] ?? 0} donations'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (donor['status'] ?? 'active') == 'active'
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                (donor['status'] ?? 'active').toString().toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: (donor['status'] ?? 'active') == 'active'
                      ? Colors.green
                      : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        onTap: () => _viewDonorDetails(donor),
      ),
    );
  }

  IconData _getDonorIcon(String? type) {
    switch (type) {
      case 'restaurant':
        return Icons.restaurant;
      case 'catering':
        return Icons.room_service;
      case 'organization':
        return Icons.business;
      case 'hotel':
        return Icons.hotel;
      case 'community':
        return Icons.people;
      default:
        return Icons.business;
    }
  }

  void _viewDonorDetails(Map<String, dynamic> donor) {
    final additionalInfo = donor['additionalInfo'];
    final donorType =
        additionalInfo is Map ? (additionalInfo['donorType'] ?? 'N/A') : 'N/A';
    final status = (donor['status'] ?? 'active').toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(donor['name'] ?? ''),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email:', donor['email'] ?? 'N/A'),
              _buildDetailRow('Phone:', donor['phone'] ?? 'N/A'),
              _buildDetailRow('Type:', donorType),
              _buildDetailRow('Status:', status),
              _buildDetailRow(
                  'Total Donations:', '${donor['donationCount'] ?? 0}'),
              _buildDetailRow(
                  'Last Donation:', donor['lastDonation']?.toString() ?? 'Never'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (status == 'active')
            TextButton(
              onPressed: () => _deactivateDonor(donor),
              child: const Text('Deactivate',
                  style: TextStyle(color: Colors.orange)),
            ),
          if (status == 'inactive')
            TextButton(
              onPressed: () => _activateDonor(donor),
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

  Future<void> _activateDonor(Map<String, dynamic> donor) async {
    try {
      final response =
          await _apiService.updateAdminUserStatus(donor['id'], 'active');
      if (response['success'] == true) {
        _fetchDonors();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${donor['name']} activated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error activating donor: $e');
    }
  }

  Future<void> _deactivateDonor(Map<String, dynamic> donor) async {
    try {
      final response =
          await _apiService.updateAdminUserStatus(donor['id'], 'inactive');
      if (response['success'] == true) {
        _fetchDonors();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${donor['name']} deactivated'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error deactivating donor: $e');
    }
  }

  void _addNewDonor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Donor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Type'),
                items: [
                  'restaurant',
                  'catering',
                  'organization',
                  'hotel',
                  'community',
                ].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type[0].toUpperCase() + type.substring(1)),
                  );
                }).toList(),
                onChanged: (value) {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Donor added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
