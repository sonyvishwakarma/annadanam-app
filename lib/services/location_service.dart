import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;

class LocationService {
  /// Get current location with platform-specific handling
  static Future<Position> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kIsWeb) {
          // On web, this might return false even if browser location is available
          print(
              'Location services check returned false on web - attempting anyway');
        } else {
          throw Exception(
              'Location services are disabled. Please enable location in your device settings.');
        }
      }

      // Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception(
              'Location permission denied. Please allow location access in your browser/device settings.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Location permissions are permanently denied. Please enable them in your device settings.');
      }

      // Get position with platform-specific settings
      Position position;
      if (kIsWeb) {
        // Web-specific: Use lower accuracy for better compatibility
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 10),
        ).timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw Exception(
                'Location request timed out. Please ensure location is enabled in your browser.');
          },
        );
      } else {
        // Mobile: Use high accuracy
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
      }

      print('Location obtained: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('Error getting location: $e');

      // Provide helpful error messages based on platform
      if (kIsWeb) {
        if (e.toString().contains('denied')) {
          throw Exception(
              'Browser blocked location access. Click the location icon in your browser address bar and allow location access.');
        } else if (e.toString().contains('timeout')) {
          throw Exception(
              'Location request timed out. Please check your browser settings and try again.');
        }
      }

      rethrow;
    }
  }

  /// Get address from coordinates with better error handling
  static Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      print('Attempting to get address for: $lat, $lng');

      // Add timeout for web compatibility
      List<Placemark> placemarks =
          await placemarkFromCoordinates(lat, lng).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Geocoding timed out');
          return [];
        },
      );

      print('Received ${placemarks.length} placemarks');

      if (placemarks.isEmpty) {
        // Fallback: return coordinates as address
        return 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}';
      }

      Placemark place = placemarks[0];
      print('Placemark: ${place.toString()}');

      // Build address from available components
      List<String> addressParts = [];
      if (place.street != null && place.street!.isNotEmpty) {
        addressParts.add(place.street!);
      }
      if (place.subLocality != null && place.subLocality!.isNotEmpty) {
        addressParts.add(place.subLocality!);
      }
      if (place.locality != null && place.locality!.isNotEmpty) {
        addressParts.add(place.locality!);
      }
      if (place.administrativeArea != null &&
          place.administrativeArea!.isNotEmpty) {
        addressParts.add(place.administrativeArea!);
      }
      if (place.country != null && place.country!.isNotEmpty) {
        addressParts.add(place.country!);
      }

      if (addressParts.isEmpty) {
        // Fallback: return coordinates
        return 'Location: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
      }

      return addressParts.join(', ');
    } catch (e) {
      print('Error getting address: $e');
      print('Error type: ${e.runtimeType}');

      // Return coordinates as fallback instead of error
      return 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)} (Address lookup unavailable)';
    }
  }

  /// Get coordinates from address string
  static Future<Map<String, double>?> getCoordinatesFromAddress(
      String address) async {
    try {
      List<Location> locations = await locationFromAddress(address).timeout(
        const Duration(seconds: 10),
        onTimeout: () => [],
      );

      if (locations.isEmpty) {
        return null;
      }

      Location location = locations[0];
      return {
        'latitude': location.latitude,
        'longitude': location.longitude,
      };
    } catch (e) {
      print('Error getting coordinates: $e');
      return null;
    }
  }

  /// Calculate distance between two points using Haversine formula
  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // Earth's radius in km
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }

  /// Format distance for display
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)} m';
    } else {
      return '${distanceKm.toStringAsFixed(1)} km';
    }
  }

  /// Check if location permissions are granted
  static Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Request location permissions
  static Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Check if running on web platform
  static bool isWeb() {
    return kIsWeb;
  }

  /// Get platform-specific help message
  static String getPlatformHelpMessage() {
    if (kIsWeb) {
      return 'For web browsers:\n'
          '1. Click the location icon (🔒) in your browser address bar\n'
          '2. Allow location access for this site\n'
          '3. Make sure location is enabled in your device/computer settings';
    } else {
      return 'For mobile devices:\n'
          '1. Go to Settings → Apps → Annadanam\n'
          '2. Enable Location permission\n'
          '3. Make sure Location/GPS is turned on';
    }
  }
}
