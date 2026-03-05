// widgets/location_picker_widget.dart
import 'package:flutter/material.dart';
import '../services/location_service.dart';

class LocationPickerWidget extends StatefulWidget {
  final TextEditingController addressController;
  final Function(double lat, double lng)? onLocationDetected;
  final Color primaryColor;

  const LocationPickerWidget({
    super.key,
    required this.addressController,
    this.onLocationDetected,
    this.primaryColor = Colors.blue,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  bool _isDetecting = false;
  String? _errorMessage;

  Future<void> _detectLocation() async {
    setState(() {
      _isDetecting = true;
      _errorMessage = null;
    });

    try {
      // Check and request permissions
      bool hasPermission = await LocationService.hasLocationPermission();
      if (!hasPermission) {
        bool granted = await LocationService.requestLocationPermission();
        if (!granted) {
          setState(() {
            _errorMessage = 'Location permission denied';
            _isDetecting = false;
          });
          return;
        }
      }

      // Get current location
      final position = await LocationService.getCurrentLocation();

      // Get address from coordinates
      final address = await LocationService.getAddressFromLatLng(
        position.latitude,
        position.longitude,
      );

      // Update address field
      widget.addressController.text = address;

      // Notify parent
      if (widget.onLocationDetected != null) {
        widget.onLocationDetected!(position.latitude, position.longitude);
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('Location detected successfully')),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });

      if (mounted) {
        // Show detailed error with platform-specific help
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700),
                const SizedBox(width: 10),
                const Text('Location Error'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Failed to detect location:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'How to fix:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    LocationService.getPlatformHelpMessage(),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _detectLocation(); // Retry
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor,
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        );
      }
    } finally {
      setState(() {
        _isDetecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.addressController,
                decoration: InputDecoration(
                  labelText: 'Pickup Address',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  errorText: _errorMessage,
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pickup address';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: widget.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                onPressed: _isDetecting ? null : _detectLocation,
                icon: _isDetecting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.my_location, color: Colors.white),
                tooltip: 'Detect My Location',
              ),
            ),
          ],
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
