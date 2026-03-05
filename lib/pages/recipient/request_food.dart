// pages/recipient/request_food.dart
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/colors.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class RequestFoodPage extends StatefulWidget {
  final User user;

  const RequestFoodPage({super.key, required this.user});

  @override
  _RequestFoodPageState createState() => _RequestFoodPageState();
}

class _RequestFoodPageState extends State<RequestFoodPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _peopleController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _addressController = TextEditingController();
  final _contactController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _foodTypeController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isVeg = true;
  bool _isLoading = false;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _contactController.text = widget.user.phone;
    _addressController.text = widget.user.additionalInfo?['address'] ?? '';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _peopleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _requirementsController.dispose();
    _foodTypeController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _foodTypeController.clear();
    _peopleController.clear();
    _dateController.clear();
    _timeController.clear();
    _requirementsController.clear();
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
      _isVeg = true;
    });
    // Re-populate user defaults
    _contactController.text = widget.user.phone;
    _addressController.text = widget.user.additionalInfo?['address'] ?? '';
    // Scroll back to top
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = RoleColors.getPrimaryColor(widget.user.role);

    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request Food',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Submit your food request',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 25),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Food Type
                      TextFormField(
                        controller: _foodTypeController,
                        decoration: InputDecoration(
                          labelText: 'Food Type *',
                          prefixIcon: const Icon(Icons.restaurant_menu),
                          hintText: 'e.g. Rice, Vegetable Curry',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter food type';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Number of People
                      TextFormField(
                        controller: _peopleController,
                        decoration: InputDecoration(
                          labelText: 'Number of People to Feed *',
                          prefixIcon: const Icon(Icons.people),
                          helperText: 'Total number of beneficiaries',
                          hintText: 'e.g. 50',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter number of people';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Veg / Non-Veg
                      Row(
                        children: [
                          const Icon(Icons.eco, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text('Vegetarian Food',
                              style: TextStyle(fontSize: 16)),
                          const Spacer(),
                          Switch(
                            value: _isVeg,
                            onChanged: (v) => setState(() => _isVeg = v),
                            activeColor: Colors.green,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Preferred Date
                      TextFormField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          labelText: 'Preferred Date *',
                          prefixIcon: const Icon(Icons.calendar_today),
                          helperText: 'Choose the day for delivery',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_month),
                            onPressed: () => _selectDate(context),
                          ),
                        ),
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a date';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Preferred Time
                      TextFormField(
                        controller: _timeController,
                        decoration: InputDecoration(
                          labelText: 'Preferred Time *',
                          prefixIcon: const Icon(Icons.access_time),
                          helperText: 'Select your preferred delivery slot',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.schedule),
                            onPressed: () => _selectTime(context),
                          ),
                        ),
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a time';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Delivery Address
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Delivery Address *',
                          prefixIcon: const Icon(Icons.location_on),
                          helperText:
                              'Full address where food should be delivered',
                          hintText: 'Enter complete address',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter delivery address';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Contact Number
                      TextFormField(
                        controller: _contactController,
                        decoration: InputDecoration(
                          labelText: 'Contact Number *',
                          prefixIcon: const Icon(Icons.phone),
                          helperText: 'Primary contact for coordinates',
                          hintText: '10-digit phone number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter contact number';
                          }
                          if (value.length < 10) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Special Requirements
                      TextFormField(
                        controller: _requirementsController,
                        decoration: InputDecoration(
                          labelText: 'Special Requirements',
                          prefixIcon: const Icon(Icons.note_add),
                          helperText:
                              'Any specific food needs or delivery notes',
                          hintText: 'e.g. No spicy food, vegetarian only',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 30),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'SUBMIT REQUEST',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Guidelines Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: primaryColor),
                        const SizedBox(width: 10),
                        Text(
                          'Request Guidelines',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                        '• Submit requests at least 24 hours in advance'),
                    const Text('• Be specific about number of people'),
                    const Text('• Mention any dietary restrictions'),
                    const Text('• Ensure someone is available to receive'),
                    const Text('• Our team will confirm via phone'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Build the request body aligned with backend schema
      final requestData = {
        'recipientId': widget.user.id,
        'foodType': _foodTypeController.text.trim(),
        'category': 'others',
        'quantityRequired': _peopleController.text.trim(),
        'servingsRequired': _peopleController.text.trim(),
        'description':
            'Date: ${_dateController.text}, Time: ${_timeController.text}. ${_requirementsController.text.trim()}',
        'isVeg': _isVeg,
        'address': _addressController.text.trim(),
      };

      final response = await _apiService.createRequest(requestData);

      if (!mounted) return;

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Food request submitted successfully! Our team will contact you soon.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        // Reset entire form to blank state
        _resetForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                response['message'] ?? 'Failed to submit request. Try again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
