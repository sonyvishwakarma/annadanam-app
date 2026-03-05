// pages/recipient/my_deliveries.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/colors.dart';
import '../../services/api_service.dart';

class MyDeliveriesPage extends StatefulWidget {
  final User user;

  const MyDeliveriesPage({super.key, required this.user});

  @override
  _MyDeliveriesPageState createState() => _MyDeliveriesPageState();
}

class _MyDeliveriesPageState extends State<MyDeliveriesPage> {
  int _selectedFilter = 0; // 0: All, 1: Upcoming, 2: Completed, 3: Cancelled
  final ApiService _apiService = ApiService();
  List<dynamic> _deliveries = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDeliveries();
  }

  Future<void> _fetchDeliveries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getRecipientRequests(widget.user.id);
      if (response['success'] == true) {
        setState(() {
          _deliveries = response['requests'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load deliveries';
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

  List<dynamic> get _filteredDeliveries {
    switch (_selectedFilter) {
      case 1:
        return _deliveries.where((d) => d['status'] == 'assigned').toList();
      case 2:
        return _deliveries.where((d) => d['status'] == 'completed').toList();
      case 3:
        return _deliveries.where((d) => d['status'] == 'cancelled').toList();
      default:
        return _deliveries;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = RoleColors.getPrimaryColor(widget.user.role);

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchDeliveries,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Deliveries',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your food delivery history',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Stats
                    Row(
                      children: [
                        _buildStatCard(
                          title: 'Total',
                          value: '${_deliveries.length}',
                          color: primaryColor,
                          icon: Icons.delivery_dining,
                        ),
                        const SizedBox(width: 15),
                        _buildStatCard(
                          title: 'Completed',
                          value:
                              '${_deliveries.where((d) => d['status'] == 'completed').length}',
                          color: Colors.green,
                          icon: Icons.check_circle,
                        ),
                        const SizedBox(width: 15),
                        _buildStatCard(
                          title: 'Upcoming',
                          value:
                              '${_deliveries.where((d) => d['status'] == 'assigned').length}',
                          color: Colors.orange,
                          icon: Icons.schedule,
                        ),
                      ],
                    ),

            const SizedBox(height: 25),

            // Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterTab('All', 0, primaryColor),
                  const SizedBox(width: 10),
                  _buildFilterTab('Upcoming', 1, Colors.orange),
                  const SizedBox(width: 10),
                  _buildFilterTab('Completed', 2, Colors.green),
                  const SizedBox(width: 10),
                  _buildFilterTab('Cancelled', 3, Colors.red),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Deliveries List
            if (_filteredDeliveries.isEmpty)
              _buildEmptyState()
            else
              Column(
                children: _filteredDeliveries.map((delivery) {
                  return _buildDeliveryCard(delivery, primaryColor);
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
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  const Spacer(),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTab(String text, int index, Color color) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _selectedFilter == index ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: _selectedFilter == index ? color : Colors.grey.shade300,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: _selectedFilter == index ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryCard(Map<String, dynamic> delivery, Color primaryColor) {
    Color statusColor = Colors.grey;
    String status = (delivery['status'] ?? 'pending').toString().toLowerCase();
    
    if (status == 'assigned' || status == 'upcoming') statusColor = Colors.orange;
    if (status == 'completed') statusColor = Colors.green;
    if (status == 'cancelled') statusColor = Colors.red;
    if (status == 'pending') statusColor = Colors.blue;

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
                  delivery['createdAt'] != null 
                    ? delivery['createdAt'].toString().split('T')[0] 
                    : 'N/A',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    delivery['status'].toString().toUpperCase(),
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
                Icon(Icons.fastfood, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  delivery['foodType'] ?? 'Unknown',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const Spacer(),
                Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  '${delivery['servingsRequired'] ?? 0} servings',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),

            if (delivery['volunteerName'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Volunteer: ${delivery['volunteerName']}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],



            if (delivery['rating'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    'Rating: ${delivery['rating']}/5',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _viewDeliveryDetails(delivery),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Details'),
                ),
                if (delivery['status'] == 'upcoming')
                  const SizedBox(width: 10),
                if (delivery['status'] == 'upcoming')
                  ElevatedButton(
                    onPressed: () => _trackDelivery(delivery),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Track'),
                  ),
                if (delivery['status'] == 'completed' && delivery['rating'] == null)
                  const SizedBox(width: 10),
                if (delivery['status'] == 'completed' && delivery['rating'] == null)
                  ElevatedButton(
                    onPressed: () => _rateDelivery(delivery['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Rate'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _trackDelivery(Map<String, dynamic> delivery) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Track Delivery'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delivery_dining, size: 60, color: Colors.green),
            const SizedBox(height: 16),
            if (delivery['volunteerName'] != null) ...[
              const SizedBox(height: 8),
              Text(
                'Volunteer: ${delivery['volunteerName']}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Status: ${delivery['status']}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _viewDeliveryDetails(Map<String, dynamic> delivery) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delivery Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Food Type:', delivery['foodType'] ?? 'Unknown'),
              _buildDetailRow('Servings:', '${delivery['servingsRequired'] ?? 0}'),
              _buildDetailRow('Status:', delivery['status'] ?? 'pending'),
              if (delivery['volunteerName'] != null)
                _buildDetailRow('Volunteer:', delivery['volunteerName']),
              _buildDetailRow('Address:', delivery['address'] ?? 'N/A'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _rateDelivery(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate Delivery'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How was your delivery experience?'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    Icons.star,
                    color: index < 4 ? Colors.amber : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      final deliveryIndex = _deliveries.indexWhere((d) => d['id'] == id);
                      if (deliveryIndex != -1) {
                        _deliveries[deliveryIndex]['rating'] = (index + 1).toDouble();
                      }
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you for your rating!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 10),
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Comments (optional)',
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rating submitted successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No deliveries found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your requested food and deliveries will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
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
}