import 'package:flutter/material.dart';
import '../services/schedule_service.dart';

class ScheduleWidget extends StatefulWidget {
  final String donorId;

  const ScheduleWidget({super.key, required this.donorId});

  @override
  _ScheduleWidgetState createState() => _ScheduleWidgetState();
}

class _ScheduleWidgetState extends State<ScheduleWidget> {
  final ScheduleService _scheduleService = ScheduleService();
  List<Map<String, dynamic>> _schedules = [];

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    final schedules = await _scheduleService.getSchedules();
    setState(() => _schedules = schedules);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Scheduled Donations',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addSchedule,
                ),
              ],
            ),

            if (_schedules.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No scheduled donations'),
              ),

            ..._schedules.map((schedule) {
              return ListTile(
                leading: const Icon(Icons.repeat),
                title: Text('${schedule['foodType']} - ${schedule['quantity']}kg'),
                subtitle: Text(
                  'Every ${schedule['days'].join(', ')} at ${schedule['time']}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteSchedule(schedule['id']),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _addSchedule() {
    showDialog(
      context: context,
      builder: (context) => SimpleScheduleDialog(
        onSave: (schedule) async {
          await _scheduleService.saveSchedule(schedule);
          _loadSchedules();
        },
      ),
    );
  }

  void _deleteSchedule(String id) async {
    await _scheduleService.deleteSchedule(id);
    _loadSchedules();
  }
}

class SimpleScheduleDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const SimpleScheduleDialog({super.key, required this.onSave});

  @override
  _SimpleScheduleDialogState createState() => _SimpleScheduleDialogState();
}

class _SimpleScheduleDialogState extends State<SimpleScheduleDialog> {
  final List<String> _selectedDays = ['monday'];
  TimeOfDay _time = TimeOfDay.now();
  String _foodType = 'cooked';
  double _quantity = 5.0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Schedule Donation'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _foodType,
              items: const [
                DropdownMenuItem(value: 'cooked', child: Text('Cooked Food')),
                DropdownMenuItem(value: 'packed', child: Text('Packaged Food')),
              ],
              onChanged: (value) => setState(() => _foodType = value!),
              decoration: const InputDecoration(labelText: 'Food Type'),
            ),

            Slider(
              value: _quantity,
              min: 1,
              max: 50,
              divisions: 49,
              label: '${_quantity.toStringAsFixed(1)}kg',
              onChanged: (value) => setState(() => _quantity = value),
            ),
            Text('Quantity: ${_quantity.toStringAsFixed(1)}kg'),

            const SizedBox(height: 16),
            const Text('Select Days:'),
            Wrap(
              children: [
                _buildDayChip('Monday'),
                _buildDayChip('Tuesday'),
                _buildDayChip('Wednesday'),
                _buildDayChip('Thursday'),
                _buildDayChip('Friday'),
                _buildDayChip('Saturday'),
                _buildDayChip('Sunday'),
              ],
            ),

            ListTile(
              title: const Text('Time'),
              subtitle: Text(_time.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final selectedTime = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (selectedTime != null) {
                  setState(() => _time = selectedTime);
                }
              },
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
            final schedule = {
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'foodType': _foodType,
              'quantity': _quantity,
              'days': _selectedDays,
              'time': _time.format(context),
              'createdAt': DateTime.now().toIso8601String(),
            };

            widget.onSave(schedule);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildDayChip(String day) {
    bool selected = _selectedDays.contains(day.toLowerCase());

    return Padding(
      padding: const EdgeInsets.all(2),
      child: FilterChip(
        label: Text(day.substring(0, 3)),
        selected: selected,
        onSelected: (value) {
          setState(() {
            if (value) {
              _selectedDays.add(day.toLowerCase());
            } else {
              _selectedDays.remove(day.toLowerCase());
            }
          });
        },
      ),
    );
  }
}