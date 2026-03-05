// models/volunteer_task_model.dart
enum TaskType {
  pickup,
  delivery,
}

enum TaskStatus {
  assigned,
  inProgress,
  pickupCompleted,
  deliveryCompleted,
  completed,
  cancelled,
}

class VolunteerTask {
  final String id;
  final String volunteerId;
  final String volunteerName;
  final String donationId;
  final TaskType type;
  final String location;
  final String address;
  final double latitude;
  final double longitude;
  final String contactName;
  final String contactPhone;
  final String foodType;
  final String quantity;
  final DateTime scheduledTime;
  final TaskStatus status;
  final String? notes;

  VolunteerTask({
    required this.id,
    required this.volunteerId,
    required this.volunteerName,
    required this.donationId,
    required this.type,
    required this.location,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.contactName,
    required this.contactPhone,
    required this.foodType,
    required this.quantity,
    required this.scheduledTime,
    this.status = TaskStatus.assigned,
    this.notes,
  });

  factory VolunteerTask.fromJson(Map<String, dynamic> json) {
    return VolunteerTask(
      id: json['id'] ?? '',
      volunteerId: json['volunteerId'] ?? '',
      volunteerName: json['volunteerName'] ?? '',
      donationId: json['donationId'] ?? '',
      type: _parseType(json['type'] ?? 'pickup'),
      location: json['location'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      contactName: json['contactName'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      foodType: json['foodType'] ?? '',
      quantity: json['quantity'] ?? '',
      scheduledTime:
          DateTime.parse(json['scheduledTime'] ?? DateTime.now().toString()),
      status: _parseStatus(json['status'] ?? 'assigned'),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'volunteerId': volunteerId,
      'volunteerName': volunteerName,
      'donationId': donationId,
      'type': _typeToString(type),
      'location': location,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'foodType': foodType,
      'quantity': quantity,
      'scheduledTime': scheduledTime.toIso8601String(),
      'status': _statusToString(status),
      'notes': notes,
    };
  }

  static TaskType _parseType(String type) {
    return type.toLowerCase() == 'delivery'
        ? TaskType.delivery
        : TaskType.pickup;
  }

  static TaskStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'inprogress':
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'pickupcompleted':
      case 'pickup_completed':
        return TaskStatus.pickupCompleted;
      case 'deliverycompleted':
      case 'delivery_completed':
        return TaskStatus.deliveryCompleted;
      case 'completed':
        return TaskStatus.completed;
      case 'cancelled':
        return TaskStatus.cancelled;
      default:
        return TaskStatus.assigned;
    }
  }

  static String _typeToString(TaskType type) {
    return type == TaskType.delivery ? 'delivery' : 'pickup';
  }

  static String _statusToString(TaskStatus status) {
    switch (status) {
      case TaskStatus.assigned:
        return 'assigned';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.pickupCompleted:
        return 'pickup_completed';
      case TaskStatus.deliveryCompleted:
        return 'delivery_completed';
      case TaskStatus.completed:
        return 'completed';
      case TaskStatus.cancelled:
        return 'cancelled';
    }
  }

  String getStatusDisplayName() {
    switch (status) {
      case TaskStatus.assigned:
        return 'Assigned';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.pickupCompleted:
        return 'Pickup Completed';
      case TaskStatus.deliveryCompleted:
        return 'Delivery Completed';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }
}
