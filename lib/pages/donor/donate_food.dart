// pages/donor/donate_food.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../utils/colors.dart';
import '../../widgets/location_picker_widget.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';

class DonateFoodPage extends StatefulWidget {
  final User user;
  final int initialStep;

  const DonateFoodPage({super.key, required this.user, this.initialStep = 0});

  @override
  _DonateFoodPageState createState() => _DonateFoodPageState();
}

class _DonateFoodPageState extends State<DonateFoodPage> {
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _pickupAddressController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  int _currentStep = 0;

  // Form fields
  String _foodType = 'cooked';
  String _quantity = '';
  String _servings = '';
  String _description = '';
  String _specialInstructions = '';
  bool _isVeg = true;
  bool _hasAllergens = false;

  // Location fields
  double? _donorLatitude;
  double? _donorLongitude;

  final List<String> _allergens = [];

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    _pickupAddressController.text =
        widget.user.additionalInfo?['address'] ?? '';
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _pickupAddressController.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      if (_quantity.isEmpty || _servings.isEmpty || _description.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all food details')),
        );
        return false;
      }
    } else if (_currentStep == 1) {
      if (_pickupAddressController.text.isEmpty ||
          _dateController.text.isEmpty ||
          _timeController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all pickup details')),
        );
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = RoleColors.getPrimaryColor(widget.user.role);

    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.initialStep == 1 ? 'Schedule Pickup' : 'Donate Food'),
        backgroundColor: primaryColor,
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_validateCurrentStep()) {
            if (_currentStep < 2) {
              setState(() => _currentStep += 1);
            } else {
              _submitDonation();
            }
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          } else {
            Navigator.pop(context);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(_currentStep == 2 ? 'SUBMIT' : 'NEXT'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: details.onStepCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(_currentStep == 0 ? 'CANCEL' : 'BACK'),
                  ),
                ),
              ],
            ),
          );
        },
        steps: [
          // Step 1: Food Details
          Step(
            title: const Text('Food Details'),
            subtitle: const Text('What are you donating?'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                _buildFoodTypeSection(),
                const SizedBox(height: 20),
                _buildFoodInfoFields(),
              ],
            ),
          ),
          // Step 2: Pickup Details
          Step(
            title: const Text('Pickup & Location'),
            subtitle: const Text('When and where to pick up?'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: _buildPickupSection(primaryColor),
          ),
          // Step 3: Review & Allergens
          Step(
            title: const Text('Review & Safety'),
            subtitle: const Text('Check ingredients and confirm'),
            isActive: _currentStep >= 2,
            content: _buildReviewSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFoodTypeCard(
                title: 'Cooked',
                icon: Icons.restaurant,
                isSelected: _foodType == 'cooked',
                onTap: () => setState(() => _foodType = 'cooked'),
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildFoodTypeCard(
                title: 'Raw',
                icon: Icons.shopping_basket,
                isSelected: _foodType == 'raw',
                onTap: () => setState(() => _foodType = 'raw'),
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildFoodTypeCard(
                title: 'Packed',
                icon: Icons.inventory,
                isSelected: _foodType == 'packed',
                onTap: () => setState(() => _foodType = 'packed'),
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFoodInfoFields() {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
              labelText: 'Quantity (kg/units)',
              prefixIcon: Icon(Icons.scale),
              helperText: 'Approximate weight in kg or number of containers',
              hintText: 'e.g. 10kg or 5 boxes'),
          onChanged: (v) => _quantity = v,
          initialValue: _quantity,
        ),
        const SizedBox(height: 15),
        TextFormField(
          decoration: const InputDecoration(
              labelText: 'Servings',
              prefixIcon: Icon(Icons.people),
              helperText: 'How many people can this amount feed?',
              hintText: 'e.g. 20'),
          onChanged: (v) => _servings = v,
          initialValue: _servings,
        ),
        const SizedBox(height: 15),
        TextFormField(
          decoration: const InputDecoration(
              labelText: 'Description',
              prefixIcon: Icon(Icons.description),
              helperText:
                  'Short summary of the items (e.g. Rice, Dal, Vegetable Curry)',
              hintText: 'What are you donating?'),
          maxLines: 2,
          onChanged: (v) => _description = v,
          initialValue: _description,
        ),
        const SizedBox(height: 15),
        SwitchListTile(
          title: const Text('Vegetarian'),
          value: _isVeg,
          onChanged: (v) => setState(() => _isVeg = v),
          secondary: Icon(Icons.eco, color: _isVeg ? Colors.green : Colors.red),
        ),
      ],
    );
  }

  Widget _buildPickupSection(Color primaryColor) {
    return Column(
      children: [
        LocationPickerWidget(
          addressController: _pickupAddressController,
          onLocationDetected: (lat, lng) {
            setState(() {
              _donorLatitude = lat;
              _donorLongitude = lng;
            });
          },
          primaryColor: primaryColor,
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: _dateController,
          decoration: const InputDecoration(
            labelText: 'Pickup Date',
            prefixIcon: Icon(Icons.calendar_today),
          ),
          readOnly: true,
          onTap: _selectDate,
        ),
        const SizedBox(height: 15),
        TextFormField(
          controller: _timeController,
          decoration: const InputDecoration(
            labelText: 'Pickup Time',
            prefixIcon: Icon(Icons.access_time),
          ),
          readOnly: true,
          onTap: _selectTime,
        ),
      ],
    );
  }

  Widget _buildReviewSection() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Has Allergens'),
          value: _hasAllergens,
          onChanged: (v) => setState(() => _hasAllergens = v),
          secondary: const Icon(Icons.warning, color: Colors.orange),
        ),
        if (_hasAllergens)
          Wrap(
            spacing: 8,
            children: ['Peanuts', 'Milk', 'Eggs', 'Nuts', 'Wheat', 'Soy']
                .map((a) => FilterChip(
                      label: Text(a),
                      selected: _allergens.contains(a),
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _allergens.add(a);
                          } else {
                            _allergens.remove(a);
                          }
                        });
                      },
                    ))
                .toList(),
          ),
        const SizedBox(height: 15),
        TextFormField(
          decoration: const InputDecoration(
              labelText: 'Special Instructions', prefixIcon: Icon(Icons.note)),
          onChanged: (v) => _specialInstructions = v,
        ),
      ],
    );
  }

  Widget _buildFoodTypeCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: isSelected ? color : Colors.grey),
            const SizedBox(height: 4),
            Text(title,
                style: TextStyle(
                    fontSize: 12, color: isSelected ? color : Colors.black)),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
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

  Future<void> _submitDonation() async {
    // If location weren't detected, try geocoding the address first
    if (_donorLatitude == null || _donorLongitude == null) {
      if (_pickupAddressController.text.isNotEmpty) {
        final coords = await LocationService.getCoordinatesFromAddress(
            _pickupAddressController.text);
        if (coords != null) {
          _donorLatitude = coords['latitude'];
          _donorLongitude = coords['longitude'];
        }
      }
    }

    final donationData = {
      'donorId': widget.user.id,
      'foodType': _foodType,
      'quantity': _quantity,
      'servings': _servings,
      'description': _description,
      'isVeg': _isVeg,
      'pickupAddress': _pickupAddressController.text,
      'pickupDate': _dateController.text,
      'pickupTime': _timeController.text,
      'specialInstructions': _specialInstructions,
      'hasAllergens': _hasAllergens,
      'allergens': _allergens,
      'latitude': _donorLatitude ?? 0.0,
      'longitude': _donorLongitude ?? 0.0,
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
    };

    _processDonation(donationData);
  }

  void _processDonation(Map<String, dynamic> donationData) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final apiService = ApiService();
      final response = await apiService.createDonation(donationData);

      Navigator.pop(context); // Close loading

      if (response['success'] == true) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success!'),
            content: const Text('Your donation has been submitted successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close success dialog
                  // Reset the entire form back to step 1
                  setState(() {
                    _currentStep = 0;
                    _foodType = 'cooked';
                    _quantity = '';
                    _servings = '';
                    _description = '';
                    _specialInstructions = '';
                    _isVeg = true;
                    _hasAllergens = false;
                    _allergens.clear();
                    _donorLatitude = null;
                    _donorLongitude = null;
                  });
                  _dateController.clear();
                  _timeController.clear();
                  _pickupAddressController.text =
                      widget.user.additionalInfo?['address'] ?? '';
                },
                child: const Text('Submit Another'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).popUntil((route) =>
                      route.isFirst || route.settings.name == '/dashboard');
                },
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        );
      } else {
        String errorMsg = response['message'] ?? 'Error';
        if (response['errors'] != null && response['errors'] is List) {
          errorMsg = (response['errors'] as List).join(', ');
        } else if (response['error'] != null) {
          errorMsg = response['error'].toString();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
