// pages/admin/recipients_management.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/colors.dart';
import '../../services/api_service.dart';

class RecipientsManagementPage extends StatefulWidget {
  final User user;

  const RecipientsManagementPage({super.key, required this.user});

  @override
  _RecipientsManagementPageState createState() =>
      _RecipientsManagementPageState();
}

class _RecipientsManagementPageState extends State<RecipientsManagementPage> {
  List<Map<String, dynamic>> _recipients = [];
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchRecipients();
  }

  Future<void> _fetchRecipients() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getAdminUsers('recipient');
      if (response['success'] == true) {
        setState(() {
          _recipients =
              List<Map<String, dynamic>>.from(response['users'] ?? []);
        });
      }
    } catch (e) {
      print('Error fetching recipients: $e');
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

    List<Map<String, dynamic>> filteredRecipients =
        _recipients.where((recipient) {
      final name = (recipient['name'] ?? '').toString().toLowerCase();
      final email = (recipient['email'] ?? '').toString().toLowerCase();
      final phone = (recipient['phone'] ?? '').toString().toLowerCase();
      final searchTerm = _searchController.text.toLowerCase();
      final matchesSearch = name.contains(searchTerm) ||
          email.contains(searchTerm) ||
          phone.contains(searchTerm);

      final matchesStatus =
          _filterStatus == 'all' || recipient['status'] == _filterStatus;
      // type comes from additionalInfo
      final additionalInfo = recipient['additionalInfo'];
      final recipientType =
          additionalInfo is Map ? (additionalInfo['recipientType'] ?? '') : '';
      final matchesType = _filterType == 'all' || recipientType == _filterType;

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
                          hintText: 'Search recipients...',
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
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _filterType,
                              items: const [
                                DropdownMenuItem(
                                    value: 'all', child: Text('All Types')),
                                DropdownMenuItem(
                                    value: 'orphanage',
                                    child: Text('Orphanage')),
                                DropdownMenuItem(
                                    value: 'elderly',
                                    child: Text('Elderly Home')),
                                DropdownMenuItem(
                                    value: 'shelter', child: Text('Shelter')),
                                DropdownMenuItem(
                                    value: 'school', child: Text('School')),
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
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildStatChip(
                          'Total: ${_recipients.length}', primaryColor),
                      _buildStatChip(
                          'Active: ${_recipients.where((r) => r['status'] == 'active').length}',
                          Colors.green),
                      _buildStatChip(
                          'Inactive: ${_recipients.where((r) => r['status'] == 'inactive').length}',
                          Colors.orange),
                      _buildStatChip(
                          'Pending: ${_recipients.where((r) => r['status'] == 'pending').length}',
                          Colors.blue),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Recipients List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRecipients.length,
                    itemBuilder: (context, index) {
                      final recipient = filteredRecipients[index];
                      return _buildRecipientCard(recipient, primaryColor);
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewRecipient,
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

  Widget _buildRecipientCard(
      Map<String, dynamic> recipient, Color primaryColor) {
    Color statusColor = Colors.grey;
    final status = (recipient['status'] ?? 'active').toString();
    if (status == 'active') statusColor = Colors.green;
    if (status == 'inactive') statusColor = Colors.orange;
    if (status == 'pending') statusColor = Colors.blue;

    // type comes from additionalInfo
    final ai = recipient['additionalInfo'];
    final recipientType = ai is Map ? (ai['recipientType'] ?? '') : '';
    IconData icon;
    switch (recipientType) {
      case 'orphanage':
        icon = Icons.child_care;
        break;
      case 'elderly':
        icon = Icons.elderly;
        break;
      case 'shelter':
        icon = Icons.home;
        break;
      case 'school':
        icon = Icons.school;
        break;
      case 'community':
        icon = Icons.people;
        break;
      default:
        icon = Icons.location_city;
    }

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
          child: Icon(icon, color: primaryColor, size: 20),
        ),
        title: Text(recipient['name'] ?? ''),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(recipient['email'] ?? ''),
            Row(
              children: [
                const Icon(Icons.people, size: 14),
                const SizedBox(width: 4),
                Text('${recipient['peopleCount'] ?? 0} people'),
                const SizedBox(width: 8),
                const Icon(Icons.request_quote, size: 14),
                const SizedBox(width: 4),
                Text('${recipient['requestCount'] ?? 0} req.'),
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
                (status).toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        onTap: () => _viewRecipientDetails(recipient),
      ),
    );
  }

  void _viewRecipientDetails(Map<String, dynamic> recipient) {
    final recipientStatus = (recipient['status'] ?? 'active').toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(recipient['name'] ?? ''),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Email:', recipient['email'] ?? 'N/A'),
              _buildDetailRow('Phone:', recipient['phone'] ?? 'N/A'),
              _buildDetailRow('Status:', recipientStatus),
              _buildDetailRow(
                  'Total Requests:', '${recipient['requestCount'] ?? 0}'),
              if (recipient['lastRequest'] != null)
                _buildDetailRow('Last Request:', recipient['lastRequest'].toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (recipientStatus == 'pending')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => _approveRecipient(recipient),
                  child: const Text('Approve',
                      style: TextStyle(color: Colors.green)),
                ),
                TextButton(
                  onPressed: () => _rejectRecipient(recipient),
                  child:
                      const Text('Reject', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          if (recipientStatus == 'active')
            TextButton(
              onPressed: () => _deactivateRecipient(recipient),
              child: const Text('Deactivate',
                  style: TextStyle(color: Colors.orange)),
            ),
          if (recipientStatus == 'inactive')
            TextButton(
              onPressed: () => _activateRecipient(recipient),
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

  Future<void> _approveRecipient(Map<String, dynamic> recipient) async {
    try {
      final response =
          await _apiService.updateAdminUserStatus(recipient['id'], 'active');
      if (response['success'] == true) {
        _fetchRecipients();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${recipient['name']} approved'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error approving recipient: $e');
    }
  }

  Future<void> _activateRecipient(Map<String, dynamic> recipient) async {
    try {
      final response =
          await _apiService.updateAdminUserStatus(recipient['id'], 'active');
      if (response['success'] == true) {
        _fetchRecipients();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${recipient['name']} activated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error activating recipient: $e');
    }
  }

  Future<void> _deactivateRecipient(Map<String, dynamic> recipient) async {
    try {
      final response =
          await _apiService.updateAdminUserStatus(recipient['id'], 'inactive');
      if (response['success'] == true) {
        _fetchRecipients();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${recipient['name']} deactivated'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error deactivating recipient: $e');
    }
  }

  void _rejectRecipient(Map<String, dynamic> recipient) {
    setState(() {
      _recipients.removeWhere((r) => r['id'] == recipient['id']);
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${recipient['name']} rejected'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _addNewRecipient() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Recipient'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Organization Name'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contact Person'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 2,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Number of People'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Type'),
                items: [
                  'orphanage',
                  'elderly',
                  'shelter',
                  'school',
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
                  content: Text('Recipient added successfully'),
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
