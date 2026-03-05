// models/food_request.dart
class FoodRequest {
  final String id;
  final String recipientId;
  final String recipientName;
  final int numberOfPeople;
  final String address;
  final String contactNumber;
  final DateTime preferredDate;
  final String preferredTime;
  final String specialRequirements;
  final String status; // pending, approved, delivered, cancelled
  final DateTime createdAt;

  FoodRequest({
    required this.id,
    required this.recipientId,
    required this.recipientName,
    required this.numberOfPeople,
    required this.address,
    required this.contactNumber,
    required this.preferredDate,
    required this.preferredTime,
    required this.specialRequirements,
    required this.status,
    required this.createdAt,
  });

  factory FoodRequest.fromJson(Map<String, dynamic> json) {
    return FoodRequest(
      id: json['id'] ?? '',
      recipientId: json['recipientId'] ?? '',
      recipientName: json['recipientName'] ?? '',
      numberOfPeople: json['numberOfPeople'] ?? 1,
      address: json['address'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      preferredDate: DateTime.parse(json['preferredDate'] ?? DateTime.now().toString()),
      preferredTime: json['preferredTime'] ?? '12:00 PM',
      specialRequirements: json['specialRequirements'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
    );
  }
}