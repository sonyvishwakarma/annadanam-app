// pages/volunteer/my_tasks.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/colors.dart';
import '../../services/api_service.dart';
import 'task_details_page.dart';

class MyTasksPage extends StatefulWidget {
  final User user;

  const MyTasksPage({super.key, required this.user});

  @override
  _MyTasksPageState createState() => _MyTasksPageState();
}

class _MyTasksPageState extends State<MyTasksPage> {
  int _selectedFilter = 0; // 0: All, 1: Upcoming, 2: In Progress, 3: Completed
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getVolunteerTasks(widget.user.id);
      if (response['success'] == true) {
        setState(() {
          _tasks = List<Map<String, dynamic>>.from(response['tasks'] ?? []);
        });
      }
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredTasks {
    switch (_selectedFilter) {
      case 1:
        return _tasks
            .where((t) =>
                (t['status'] ?? '') == 'assigned' ||
                (t['status'] ?? '') == 'upcoming')
            .toList();
      case 2:
        return _tasks
            .where((t) => (t['status'] ?? '') == 'in-progress')
            .toList();
      case 3:
        return _tasks.where((t) => (t['status'] ?? '') == 'completed').toList();
      default:
        return _tasks;
    }
  }

  // Counts
  int get _activeCount => _tasks
      .where((t) =>
          (t['status'] ?? '') == 'in-progress' ||
          (t['status'] ?? '') == 'assigned')
      .length;
  int get _upcomingCount =>
      _tasks.where((t) => (t['status'] ?? '') == 'assigned').length;
  int get _completedCount =>
      _tasks.where((t) => (t['status'] ?? '') == 'completed').length;

  @override
  Widget build(BuildContext context) {
    final primaryColor = RoleColors.getPrimaryColor(widget.user.role);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchTasks,
        color: primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Tasks',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your volunteer tasks',
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
                    title: 'Active',
                    value: '$_activeCount',
                    color: Colors.blue,
                    icon: Icons.play_circle_fill,
                  ),
                  const SizedBox(width: 15),
                  _buildStatCard(
                    title: 'Upcoming',
                    value: '$_upcomingCount',
                    color: Colors.orange,
                    icon: Icons.schedule,
                  ),
                  const SizedBox(width: 15),
                  _buildStatCard(
                    title: 'Completed',
                    value: '$_completedCount',
                    color: Colors.green,
                    icon: Icons.check_circle,
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
                    _buildFilterTab('In Progress', 2, Colors.blue),
                    const SizedBox(width: 10),
                    _buildFilterTab('Completed', 3, Colors.green),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tasks List
              if (_isLoading)
                Center(child: CircularProgressIndicator(color: primaryColor))
              else if (_filteredTasks.isEmpty)
                _buildEmptyState(primaryColor)
              else
                Column(
                  children: _filteredTasks.map((task) {
                    return _buildTaskCard(task, primaryColor);
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.assignment_outlined,
              size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No tasks found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tasks assigned to you will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
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
            color:
                _selectedFilter == index ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, Color primaryColor) {
    final status = (task['status'] ?? 'assigned').toString();
    Color statusColor = Colors.grey;
    if (status == 'upcoming' || status == 'assigned') {
      statusColor = Colors.orange;
    } else if (status == 'in-progress') {
      statusColor = Colors.blue;
    } else if (status == 'completed') {
      statusColor = Colors.green;
    }

    // Map backend fields to display values
    final location =
        task['pickupAddress'] ?? task['location'] ?? 'Unknown Location';
    final foodType = task['foodType'] ?? task['category'] ?? 'Food';
    final quantity = task['quantity'] ?? task['servings'] ?? '';
    final assignedAt = task['assignedAt'] ?? task['date'] ?? '';
    final taskType = task['type'] ?? 'Delivery';

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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: taskType == 'Pickup'
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: taskType == 'Pickup' ? Colors.blue : Colors.green,
                    ),
                  ),
                  child: Text(
                    taskType,
                    style: TextStyle(
                      fontSize: 12,
                      color: taskType == 'Pickup' ? Colors.blue : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
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
                    status.toUpperCase(),
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
            Text(
              location,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.fastfood, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    foodType,
                    style: TextStyle(color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (quantity.isNotEmpty) ...[
                  Icon(Icons.scale, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    quantity.toString(),
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ]
              ],
            ),
            if (assignedAt.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    assignedAt.toString().length > 16
                        ? assignedAt.toString().substring(0, 16)
                        : assignedAt.toString(),
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status == 'upcoming' || status == 'assigned')
                  OutlinedButton(
                    onPressed: () => _updateTaskStatus(task, 'in-progress'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Start',
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                if (status == 'in-progress')
                  OutlinedButton(
                    onPressed: () => _showCompleteDialog(task),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Complete',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _viewTaskDetails(task),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateTaskStatus(
      Map<String, dynamic> task, String newStatus) async {
    try {
      final taskId = (task['id'] ?? task['taskId'] ?? '').toString();
      final response = await _apiService.updateTaskStatus(taskId, newStatus);
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Task ${newStatus == 'in-progress' ? 'started' : 'updated'}!'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchTasks();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Update failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showCompleteDialog(Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please confirm task completion:'),
            const SizedBox(height: 10),
            CheckboxListTile(
              title: const Text('Food delivered safely'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Recipient satisfied'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('No issues reported'),
              value: true,
              onChanged: (value) {},
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
              _updateTaskStatus(task, 'completed');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _viewTaskDetails(Map<String, dynamic> task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailsPage(
          user: widget.user,
          taskData: task,
        ),
      ),
    ).then((_) => _fetchTasks());
  }
}
