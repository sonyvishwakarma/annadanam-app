// services/volunteer_assignment_service.dart
import '../services/location_service.dart';
import '../services/api_service.dart';

class VolunteerAssignmentService {
  static final VolunteerAssignmentService _instance =
      VolunteerAssignmentService._internal();
  factory VolunteerAssignmentService() => _instance;
  VolunteerAssignmentService._internal();

  final ApiService _apiService = ApiService();

  // Mock volunteer data with locations (In a real system, volunteers' live locations would be tracked)
  final List<Map<String, dynamic>> _mockVolunteers = [
    {
      'id': 'vol_001',
      'name': 'Rajesh Kumar',
      'phone': '+91 9876543210',
      'latitude': 17.3850,
      'longitude': 78.4867,
      'available': true,
      'currentTasks': 1,
      'maxTasks': 3,
    },
    {
      'id': 'vol_002',
      'name': 'Priya Sharma',
      'phone': '+91 9876543211',
      'latitude': 17.4065,
      'longitude': 78.4772,
      'available': true,
      'currentTasks': 0,
      'maxTasks': 3,
    },
    {
      'id': 'vol_003',
      'name': 'Amit Patel',
      'phone': '+91 9876543212',
      'latitude': 17.4239,
      'longitude': 78.4738,
      'available': true,
      'currentTasks': 2,
      'maxTasks': 3,
    },
  ];

  /// Find the nearest available volunteer to the given location
  Future<Map<String, dynamic>?> findNearestVolunteer({
    required double donorLatitude,
    required double donorLongitude,
  }) async {
    // Filter available volunteers
    final availableVolunteers = _mockVolunteers.where((v) {
      return v['available'] == true && v['currentTasks'] < v['maxTasks'];
    }).toList();

    if (availableVolunteers.isEmpty) {
      return null;
    }

    Map<String, dynamic>? nearestVolunteer;
    double minDistance = double.infinity;

    for (var volunteer in availableVolunteers) {
      final distance = LocationService.calculateDistance(
        donorLatitude,
        donorLongitude,
        volunteer['latitude'],
        volunteer['longitude'],
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestVolunteer = {
          ...volunteer,
          'distance': distance,
        };
      }
    }

    return nearestVolunteer;
  }

  /// Assign a donation to a volunteer using the real backend
  Future<Map<String, dynamic>> assignDonationToVolunteer({
    String? donationId,
    required String volunteerId,
    String? requestId,
  }) async {
    return await _apiService.assignTask(
      donationId: donationId,
      volunteerId: volunteerId,
      requestId: requestId,
    );
  }

  /// Auto-assign donation to nearest volunteer
  Future<Map<String, dynamic>?> autoAssignDonation({
    String? donationId,
    required double donorLatitude,
    required double donorLongitude,
    String? requestId,
  }) async {
    final nearestVolunteer = await findNearestVolunteer(
      donorLatitude: donorLatitude,
      donorLongitude: donorLongitude,
    );

    if (nearestVolunteer == null) {
      return {
        'success': false,
        'message': 'No volunteers available in your area',
      };
    }

    final result = await assignDonationToVolunteer(
      donationId: donationId,
      volunteerId: nearestVolunteer['id'],
      requestId: requestId,
    );

    if (result['success'] == true) {
      return {
        ...result,
        'volunteerName': nearestVolunteer['name'],
        'volunteerPhone': nearestVolunteer['phone'],
        'distance': nearestVolunteer['distance'],
      };
    }

    return result;
  }
}
