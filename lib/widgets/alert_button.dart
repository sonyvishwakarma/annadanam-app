import 'package:flutter/material.dart';
import '../services/alert_service.dart';

class SimpleAlertButton extends StatefulWidget {
  final String restaurantName;
  final String foodType;
  final double quantity;

  const SimpleAlertButton({
    super.key,
    required this.restaurantName,
    required this.foodType,
    required this.quantity,
  });

  @override
  _SimpleAlertButtonState createState() => _SimpleAlertButtonState();
}

class _SimpleAlertButtonState extends State<SimpleAlertButton> {
  final FreeAlertService _alertService = FreeAlertService();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _alertService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isSending ? null : _sendAlert,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      icon: _isSending
          ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      )
          : const Icon(Icons.notifications_active),
      label: const Text('ALERT VOLUNTEERS'),
    );
  }

  Future<void> _sendAlert() async {
    setState(() => _isSending = true);

    await _alertService.showLeftoverAlert(
      restaurantName: widget.restaurantName,
      foodType: widget.foodType,
      quantity: widget.quantity,
    );

    setState(() => _isSending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alert sent to volunteers!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}