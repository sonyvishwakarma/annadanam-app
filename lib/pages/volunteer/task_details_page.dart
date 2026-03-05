// pages/volunteer/task_details_page.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/user_model.dart';
import '../../utils/colors.dart';
import 'route_navigation_page.dart';
import '../common/report_issue_page.dart';
import '../../services/api_service.dart';
import '../chat/api_chat_page.dart';

class TaskDetailsPage extends StatefulWidget {
  final User user;
  final Map<String, dynamic>
      taskData; // Temporary, will use VolunteerTask model

  const TaskDetailsPage({
    super.key,
    required this.user,
    required this.taskData,
  });

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  bool _isProcessing = false;

  Future<void> _makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not make phone call'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _verifyPickup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Pickup'),
        content: const Text('Have you successfully picked up the food?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Picked Up'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isProcessing = true);
      try {
        // TODO: Call API to update status to pickup_completed
        setState(() {
          widget.taskData['status'] = 'pickup_completed';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pickup recorded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } finally {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _verifyDelivery() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delivery'),
        content: const Text('Have you successfully delivered the food?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Delivered'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isProcessing = true);
      try {
        // TODO: Call API to update status to completed
        setState(() {
          widget.taskData['status'] = 'completed';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery recorded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } finally {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _navigate() {
    // Use mock coordinates if not available
    final lat = widget.taskData['latitude'] ?? 17.3850;
    final lng = widget.taskData['longitude'] ?? 78.4867;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RouteNavigationPage(
          user: widget.user,
          destinationName: widget.taskData['location'],
          destinationAddress:
              widget.taskData['address'] ?? widget.taskData['location'],
          destinationLat: lat,
          destinationLng: lng,
        ),
      ),
    );
  }

  void _reportIssue() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportIssuePage(
          user: widget.user,
          relatedTaskId: widget.taskData['id'],
          relatedDonationId: widget.taskData['donationId'],
        ),
      ),
    );
  }

  void _startChat() async {
    final apiService = ApiService();
    final bool isPickup = widget.taskData['type'] == 'Pickup' || widget.taskData['donationId'] != null;
    final otherUserId =
        isPickup ? widget.taskData['donorId'] : widget.taskData['recipientId'];
    final otherUserName = isPickup
        ? (widget.taskData['donorName'] ?? 'Donor')
        : (widget.taskData['recipientName'] ?? 'Recipient');

    if (otherUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot start chat: User not found')),
      );
      return;
    }

    final chatId = await apiService.apiCreateChat(
      user1Id: widget.user.id,
      user2Id: otherUserId,
      user1Name: widget.user.name,
      user2Name: otherUserName,
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
            otherUserName: otherUserName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = RoleColors.getPrimaryColor(widget.user.role);
    final bool isPickup = widget.taskData['type'] == 'Pickup' || widget.taskData['donationId'] != null;
    final String displayType = widget.taskData['type'] ?? (isPickup ? 'Pickup' : 'Delivery');
    final status = widget.taskData['status'] ?? 'upcoming';

    return Scaffold(
      appBar: AppBar(
        title: Text('$displayType Details'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            onPressed: _reportIssue,
            icon: const Icon(Icons.report_problem),
            tooltip: 'Report Issue',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getStatusColor(status)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(status),
                    size: 18,
                    color: _getStatusColor(status),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    status.toUpperCase().replaceAll('_', ' '),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Location Card
            Card(
              elevation: 2,
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
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.taskData['location'] ?? 'Location Details',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (widget.taskData['address'] != null || widget.taskData['location'] != null)
                                Text(
                                  widget.taskData['address'] ?? widget.taskData['location'] ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Task Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Task Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildInfoRow(Icons.fastfood, 'Food Type',
                        widget.taskData['foodType'] ?? 'N/A'),
                    _buildInfoRow(
                        Icons.scale, 'Quantity', widget.taskData['quantity'] ?? 'N/A'),
                    _buildInfoRow(
                        Icons.access_time, 'Time', widget.taskData['time'] ?? 'ASAP'),
                    _buildInfoRow(
                        Icons.calendar_today, 'Date', widget.taskData['date']?.toString().split('T')[0] ?? 'Today'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Contact Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.taskData[isPickup
                                    ? 'donorContact'
                                    : 'recipientContact'] ??
                                'N/A',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            final contact = widget.taskData[
                                isPickup ? 'donorContact' : 'recipientContact'];
                            if (contact != null) {
                              _makePhoneCall(contact);
                            }
                          },
                          icon: const Icon(Icons.phone, size: 18),
                          label: const Text('Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isPickup)
                          ElevatedButton.icon(
                            onPressed: _startChat,
                            icon: const Icon(Icons.chat, size: 18),
                            label: const Text('Chat'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Action Buttons
            Column(
              children: [
                // Navigate Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _navigate,
                    icon: const Icon(Icons.navigation),
                    label: const Text(
                      'Navigate to Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Verify Pickup/Delivery Button
                if (status != 'completed')
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing
                          ? null
                          : (status == 'pickup_completed'
                              ? _verifyDelivery
                              : _verifyPickup),
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                        status == 'pickup_completed'
                            ? 'Verify Delivery'
                            : 'Verify Pickup',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // Report Issue Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _reportIssue,
                    icon: const Icon(Icons.report_problem),
                    label: const Text(
                      'Report Issue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.orange.shade700),
                      foregroundColor: Colors.orange.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
      case 'assigned':
        return Colors.orange;
      case 'in-progress':
      case 'pickup_completed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'upcoming':
      case 'assigned':
        return Icons.schedule;
      case 'in-progress':
      case 'pickup_completed':
        return Icons.local_shipping;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }
}
