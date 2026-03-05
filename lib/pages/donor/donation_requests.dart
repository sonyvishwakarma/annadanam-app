// pages/donor/donation_requests.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/colors.dart';

import '../../services/api_service.dart';

class DonationRequestsPage extends StatefulWidget {
  final User user;

  const DonationRequestsPage({super.key, required this.user});

  @override
  _DonationRequestsPageState createState() => _DonationRequestsPageState();
}

class _DonationRequestsPageState extends State<DonationRequestsPage> {
  final ApiService _apiService = ApiService();
  List<dynamic> _requests = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getAvailableRequests();
      if (response['success'] == true) {
        setState(() {
          _requests = response['requests'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load requests';
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

  @override
  Widget build(BuildContext context) {
    final primaryColor = RoleColors.getPrimaryColor(widget.user.role);

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchRequests,
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
                              'Donation Requests',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Food requests from recipients near you',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: _fetchRequests,
                          icon: Icon(Icons.refresh, color: primaryColor),
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
                                onPressed: _fetchRequests,
                                child: const Text('Retry')),
                          ],
                        ),
                      )
                    else if (_requests.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: Column(
                            children: [
                              Icon(Icons.volunteer_activism_outlined,
                                  size: 80, color: Colors.grey[300]),
                              const SizedBox(height: 20),
                              const Text('No current food requests',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey)),
                            ],
                          ),
                        ),
                      )
                    else
                      Column(
                        children: _requests.map((request) {
                          return _buildRequestCard(request, primaryColor);
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRequestCard(dynamic request, Color primaryColor) {
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
                Expanded(
                  child: Text(
                    request['recipientName'] ?? 'Recipient',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Text(
                    request['status'].toString().toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  '${request['servingsRequired']} meals needed',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const Spacer(),
                Icon(Icons.category, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  request['foodType'] ?? '',
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
                    request['address'] ?? 'No address',
                    style: TextStyle(color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Posted: ${request['createdAt'].toString().substring(0, 10)}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (request['status'] == 'pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _declineRequest(request['id']),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Decline',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _acceptRequest(request['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Accept'),
                  ),
                ],
              ),
            if (request['status'] == 'accepted')
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'You accepted this request',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptRequest(String id) async {
    // Optimistic UI update
    setState(() {
      final index = _requests.indexWhere((r) => r['id'] == id);
      if (index != -1) {
        _requests[index]['status'] = 'accepted';
      }
    });

    final response = await _apiService.updateRequestStatus(
      requestId: id,
      status: 'accepted',
      donorId: widget.user.id,
    );

    if (response['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request accepted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // Revert if failed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to accept request'),
            backgroundColor: Colors.red,
          ),
        );
        _fetchRequests(); // Reload correct state
      }
    }
  }

  void _declineRequest(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for declining:'),
            const SizedBox(height: 10),
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter reason...',
              ),
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
              Navigator.pop(context); // Close dialog

              // Keep a backup to revert
              final requestBackup = _requests.firstWhere((r) => r['id'] == id);

              // Optimistic UI update
              setState(() {
                _requests.removeWhere((r) => r['id'] == id);
              });

              final response = await _apiService.updateRequestStatus(
                requestId: id,
                status: 'declined',
              );

              if (response['success'] == true) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Request declined'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                // Revert
                setState(() {
                  _requests.add(requestBackup);
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          response['message'] ?? 'Failed to decline request'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }
}
