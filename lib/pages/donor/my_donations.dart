// pages/donor/my_donations.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/colors.dart';
import '../../services/api_service.dart';
import '../chat/api_chat_page.dart';

class MyDonationsPage extends StatefulWidget {
  final User user;

  const MyDonationsPage({super.key, required this.user});

  @override
  _MyDonationsPageState createState() => _MyDonationsPageState();
}

class _MyDonationsPageState extends State<MyDonationsPage> {
  final ApiService _apiService = ApiService();
  List<dynamic> _donations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDonations();
  }

  Future<void> _fetchDonations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getDonorDonations(widget.user.id);
      if (response['success'] == true) {
        setState(() {
          _donations = response['donations'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load donations';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'picked_up':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = RoleColors.getPrimaryColor(widget.user.role);

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchDonations,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Donations',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Track your food donation history',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: _fetchDonations,
                          icon: Icon(Icons.refresh,
                              color: primaryColor, size: 28),
                          tooltip: 'Refresh list',
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Stats row
                    Row(
                      children: [
                        _buildStatCard(
                          title: 'My Donations',
                          value: _donations.length.toString(),
                          unit: '',
                          color: primaryColor,
                          icon: Icons.inventory,
                        ),
                        const SizedBox(width: 15),
                        _buildStatCard(
                          title: 'Status',
                          value: 'Active',
                          unit: '',
                          color: Colors.blue,
                          icon: Icons.check_circle,
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),
                    if (_errorMessage != null)
                      Center(
                        child: Column(
                          children: [
                            Text(_errorMessage!,
                                style: const TextStyle(color: Colors.red)),
                            TextButton(
                                onPressed: _fetchDonations,
                                child: const Text('Retry')),
                          ],
                        ),
                      )
                    else if (_donations.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: Column(
                            children: [
                              Icon(Icons.inventory_2_outlined,
                                  size: 80, color: Colors.grey[300]),
                              const SizedBox(height: 20),
                              const Text('No donations found',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey)),
                            ],
                          ),
                        ),
                      )
                    else
                      Column(
                        children: _donations.map((donation) {
                          return _buildDonationCard(donation, primaryColor);
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                '$value $unit',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDonationCard(dynamic donation, Color primaryColor) {
    final statusColor = _getStatusColor(donation['status']);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  donation['foodType'].toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    donation['status'].toString().toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.scale, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  '${donation['quantity']} (${donation['servings']} servings)',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const Spacer(),
                Icon(Icons.calendar_today,
                    size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  '${donation['pickupDate']}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    donation['pickupAddress'],
                    style: TextStyle(color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => _viewDetails(donation),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _viewDetails(Map<String, dynamic> donation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Donation Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Food Type:', donation['foodType']),
              _buildDetailRow('Quantity:', donation['quantity']),
              _buildDetailRow('Servings:', donation['servings'].toString()),
              _buildDetailRow('Date:', donation['pickupDate']),
              _buildDetailRow('Time:', donation['pickupTime']),
              _buildDetailRow('Address:', donation['pickupAddress']),
              _buildDetailRow(
                  'Instructions:', donation['specialInstructions'] ?? 'None'),
              _buildDetailRow(
                  'Status:', donation['status'].toString().toUpperCase()),
            ],
          ),
        ),
        actions: [
          if (donation['status'] == 'assigned' ||
              donation['status'] == 'picked_up')
            ElevatedButton.icon(
              onPressed: () => _startChat(donation),
              icon: const Icon(Icons.chat, size: 18),
              label: const Text('Chat with Volunteer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  void _startChat(Map<String, dynamic> donation) async {
    final apiService = ApiService();
    final volunteerId = donation['volunteerId'];
    final volunteerName = donation['volunteerName'] ?? 'Volunteer';

    if (volunteerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No volunteer assigned yet')),
      );
      return;
    }

    final chatId = await apiService.apiCreateChat(
      user1Id: widget.user.id,
      user2Id: volunteerId,
      user1Name: widget.user.name,
      user2Name: volunteerName,
    );

    if (mounted) {
      if (chatId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to initialize chat in database')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            chatId: chatId,
            currentUserId: widget.user.id,
            currentUserName: widget.user.name,
            currentUserRole: widget.user.role,
            otherUserName: volunteerName,
          ),
        ),
      );
    }
  }
}
