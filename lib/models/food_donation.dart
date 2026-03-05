// models/food_donation.dart

enum DonationStatus {
  pending,
  scheduled,
  pickedUp,
  delivered,
  cancelled,
}

enum FoodType {
  cooked,
  raw,
  packaged,
  freshProduce,
  canned,
  baked,
  other,
}

class FoodDonation {
  final String id;
  final String donorId;
  final String donorName;
  final String foodType;
  final double quantity; // in kg
  final DateTime pickupDate;
  final String pickupTime;
  final String address;
  final String contactNumber;
  final String specialInstructions;
  final DonationStatus status;
  final DateTime createdAt;
  final List<String> images;

  FoodDonation({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.foodType,
    required this.quantity,
    required this.pickupDate,
    required this.pickupTime,
    required this.address,
    required this.contactNumber,
    required this.specialInstructions,
    required this.status,
    required this.createdAt,
    this.images = const [],
  });

  factory FoodDonation.fromJson(Map<String, dynamic> json) {
    return FoodDonation(
      id: json['id'] ?? '',
      donorId: json['donorId'] ?? '',
      donorName: json['donorName'] ?? '',
      foodType: json['foodType'] ?? 'cooked',
      quantity: (json['quantity'] ?? 0).toDouble(),
      pickupDate: DateTime.parse(json['pickupDate'] ?? DateTime.now().toString()),
      pickupTime: json['pickupTime'] ?? '10:00 AM',
      address: json['address'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      specialInstructions: json['specialInstructions'] ?? '',
      status: _parseStatus(json['status'] ?? 'pending'),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      images: List<String>.from(json['images'] ?? []),
    );
  }

  static DonationStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return DonationStatus.scheduled;
      case 'pickedup':
        return DonationStatus.pickedUp;
      case 'delivered':
        return DonationStatus.delivered;
      case 'cancelled':
        return DonationStatus.cancelled;
      default:
        return DonationStatus.pending;
    }
  }
}