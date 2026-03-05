import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SimpleRoutingService {
  // Using OSRM (Open Source Routing Machine) - FREE
  static const String _baseUrl = 'http://router.project-osrm.org/route/v1/driving';

  Future<Map<String, dynamic>> getRoute(
      double startLng, double startLat,
      double endLng, double endLat,
      ) async {
    final url = '$_baseUrl/$startLng,$startLat;$endLng,$endLat?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get route: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get route: $e');
    }
  }

  // Simple nearest neighbor algorithm (FREE)
  static List<int> calculateOptimalRoute(
      List<List<double>> locations, // [lat, lng]
      int startIndex,
      ) {
    if (locations.isEmpty) return [];

    List<int> route = [startIndex];
    List<int> unvisited = List.generate(locations.length, (i) => i);
    unvisited.remove(startIndex);

    while (unvisited.isNotEmpty) {
      int current = route.last;
      int nearestIndex = 0;
      double nearestDistance = double.infinity;

      for (int i = 0; i < unvisited.length; i++) {
        double distance = calculateDistance(
          locations[current][0], locations[current][1],
          locations[unvisited[i]][0], locations[unvisited[i]][1],
        );

        if (distance < nearestDistance) {
          nearestDistance = distance;
          nearestIndex = i;
        }
      }

      route.add(unvisited[nearestIndex]);
      unvisited.removeAt(nearestIndex);
    }

    return route;
  }

  // Haversine formula to calculate distance between two points
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // Earth's radius in km
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat/2) * sin(dLat/2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
            sin(dLon/2) * sin(dLon/2);
    double c = 2 * atan2(sqrt(a), sqrt(1-a));
    return R * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }

  // Convert distance to time estimate (simple)
  static String estimateTime(double distanceKm, String mode) {
    double speed = mode == 'driving' ? 40.0 : // km/h
    mode == 'walking' ? 5.0 :
    mode == 'bicycling' ? 15.0 : 40.0;

    double hours = distanceKm / speed;
    int minutes = (hours * 60).round();

    if (minutes < 60) {
      return '$minutes minutes';
    } else {
      int hoursPart = minutes ~/ 60;
      int minutesPart = minutes % 60;
      return '$hoursPart hours ${minutesPart}min';
    }
  }
}