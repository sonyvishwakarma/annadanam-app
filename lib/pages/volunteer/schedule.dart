// pages/volunteer/schedule.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/colors.dart';
import '../../services/api_service.dart';
import 'task_details_page.dart';

class SchedulePage extends StatefulWidget {
  final User user;

  const SchedulePage({super.key, required this.user});

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _allTasks = [];
  DateTime _selectedDate = DateTime.now();

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
          _allTasks = List<Map<String, dynamic>>.from(response['tasks'] ?? []);
        });
      }
    } catch (e) {
      debugPrint('Error fetching schedule: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  String _formatDisplayDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}';
  }

  List<Map<String, dynamic>> get _tasksForSelectedDate {
    final selected = _formatDate(_selectedDate);
    return _allTasks.where((task) {
      final taskDate = (task['assignedAt'] ?? task['date'] ?? '').toString();
      return taskDate.startsWith(selected);
    }).toList();
  }

  // Build a 7-day strip
  List<DateTime> get _weekDays {
    final today = DateTime.now();
    return List.generate(14, (i) => today.add(Duration(days: i - 3)));
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = RoleColors.getPrimaryColor(widget.user.role);
    final dayTasks = _tasksForSelectedDate;

    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : RefreshIndicator(
              onRefresh: _fetchTasks,
              color: primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Schedule',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          Text(
                            _formatDisplayDate(_selectedDate),
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Date Strip
                    SizedBox(
                      height: 76,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _weekDays.length,
                        itemBuilder: (context, index) {
                          final day = _weekDays[index];
                          final isSelected =
                              _formatDate(day) == _formatDate(_selectedDate);
                          final isToday =
                              _formatDate(day) == _formatDate(DateTime.now());
                          // Count tasks on this day
                          final dayCount = _allTasks.where((t) {
                            final td =
                                (t['assignedAt'] ?? t['date'] ?? '').toString();
                            return td.startsWith(_formatDate(day));
                          }).length;

                          const weekDayLabels = [
                            'M',
                            'T',
                            'W',
                            'T',
                            'F',
                            'S',
                            'S'
                          ];

                          return GestureDetector(
                            onTap: () => setState(() => _selectedDate = day),
                            child: Container(
                              width: 52,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primaryColor
                                    : isToday
                                        ? primaryColor.withOpacity(0.1)
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected || isToday
                                      ? primaryColor
                                      : Colors.grey.shade200,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: primaryColor.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    weekDayLabels[day.weekday - 1],
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isSelected
                                          ? Colors.white70
                                          : Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${day.day}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade800,
                                    ),
                                  ),
                                  if (dayCount > 0)
                                    Container(
                                      margin: const EdgeInsets.only(top: 3),
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white
                                            : primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        dayTasks.isEmpty
                            ? 'No tasks scheduled'
                            : '${dayTasks.length} task${dayTasks.length > 1 ? 's' : ''} scheduled',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Task list
                    if (dayTasks.isEmpty)
                      _buildEmptyState(primaryColor)
                    else
                      ...dayTasks
                          .map((task) => _buildScheduleCard(task, primaryColor))
                          .toList(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState(Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.event_available, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'Rest day!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No tasks scheduled for this date.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> task, Color primaryColor) {
    final status = (task['status'] ?? 'assigned').toString();
    final taskType = (task['type'] ?? 'Delivery').toString();
    final location =
        (task['pickupAddress'] ?? task['location'] ?? 'Unknown').toString();
    final foodType =
        (task['foodType'] ?? task['category'] ?? 'Food').toString();
    final assignedAt = (task['assignedAt'] ?? task['time'] ?? '').toString();

    Color typeColor = taskType == 'Pickup' ? Colors.blue : Colors.green;
    Color statusColor = Colors.grey;
    if (status == 'assigned' || status == 'upcoming') {
      statusColor = Colors.orange;
    } else if (status == 'in-progress') {
      statusColor = Colors.blue;
    } else if (status == 'completed') {
      statusColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type indicator strip
            Container(
              width: 4,
              height: 70,
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          taskType,
                          style: TextStyle(
                            fontSize: 11,
                            color: typeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    location,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$foodType • ${assignedAt.length > 16 ? assignedAt.substring(0, 16) : assignedAt}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskDetailsPage(
                    user: widget.user,
                    taskData: task,
                  ),
                ),
              ).then((_) => _fetchTasks()),
              icon: Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }
}
