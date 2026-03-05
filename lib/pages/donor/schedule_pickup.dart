import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/colors.dart';
import '../../widgets/location_picker_widget.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class SchedulePickupPage extends StatefulWidget {
  final User user;

  const SchedulePickupPage({super.key, required this.user});

  @override
  _SchedulePickupPageState createState() => _SchedulePickupPageState();
}

class _SchedulePickupPageState extends State<SchedulePickupPage> {
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _pickupAddressController = TextEditingController();
  final _quantityController = TextEditingController();
  final _servingsController = TextEditingController();
  final _descController = TextEditingController();

  final String _foodType = 'cooked';
  final bool _isVeg = true;
  double? _lat;
  double? _lng;

  @override
  void initState() {
    super.initState();
    _pickupAddressController.text =
        widget.user.additionalInfo?['address'] ?? '';
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _pickupAddressController.dispose();
    _quantityController.dispose();
    _servingsController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  void _submit() async {
    if (_pickupAddressController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _timeController.text.isEmpty ||
        _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required fields')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final apiService = ApiService();
      final response = await apiService.createDonation({
        'donorId': widget.user.id,
        'foodType': _foodType,
        'quantity': _quantityController.text,
        'servings': _servingsController.text,
        'description': _descController.text,
        'isVeg': _isVeg,
        'pickupAddress': _pickupAddressController.text,
        'pickupDate': _dateController.text,
        'pickupTime': _timeController.text,
        'latitude': _lat,
        'longitude': _lng,
        'status': 'pending',
      });

      Navigator.pop(context); // Close loading

      if (response['success'] == true) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Pickup scheduled successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close success dialog
                  // Return until we reach the dashboard, or stop at the root
                  Navigator.of(context).popUntil((route) =>
                      route.isFirst || route.settings.name == '/dashboard');
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to schedule')),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = RoleColors.getPrimaryColor(widget.user.role);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Pickup'),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set Pickup Logistics',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Where and when should we come?'),
            const SizedBox(height: 25),
            LocationPickerWidget(
              addressController: _pickupAddressController,
              onLocationDetected: (lat, lng) {
                setState(() {
                  _lat = lat;
                  _lng = lng;
                });
              },
              primaryColor: primaryColor,
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: _selectDate,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      prefixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    onTap: _selectTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'Quick Food Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                  labelText: 'Approx Quantity (kg/units)',
                  border: OutlineInputBorder(),
                  helperText: 'e.g. 5kg, 3 boxes, 50 packets',
                  hintText: 'Enter amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                  labelText: 'Brief Description',
                  border: OutlineInputBorder(),
                  helperText: 'What kind of food items are these?',
                  hintText: 'e.g. Vegetable Biryani, Bread rolls'),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'CONFIRM PICKUP',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
