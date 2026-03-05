// pages/volunteer/route_navigation_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/user_model.dart';
import '../../services/location_service.dart';
import '../../services/routing_service.dart';
import '../../utils/colors.dart';

class RouteNavigationPage extends StatefulWidget {
  final User user;
  final String destinationName;
  final String destinationAddress;
  final double destinationLat;
  final double destinationLng;

  const RouteNavigationPage({
    super.key,
    required this.user,
    required this.destinationName,
    required this.destinationAddress,
    required this.destinationLat,
    required this.destinationLng,
  });

  @override
  State<RouteNavigationPage> createState() => _RouteNavigationPageState();
}

class _RouteNavigationPageState extends State<RouteNavigationPage> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  List<LatLng> _routePoints = [];
  double? _distance;
  String? _estimatedTime;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeNavigation();
  }

  Future<void> _initializeNavigation() async {
    try {
      // Get current location
      final position = await LocationService.getCurrentLocation();
      final currentLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentLocation = currentLatLng;
      });

      // Calculate distance
      final distance = LocationService.calculateDistance(
        position.latitude,
        position.longitude,
        widget.destinationLat,
        widget.destinationLng,
      );

      // Estimate time
      final time = SimpleRoutingService.estimateTime(distance, 'driving');

      // Get route (using OSRM)
      try {
        final routingService = SimpleRoutingService();
        final routeData = await routingService.getRoute(
          position.longitude,
          position.latitude,
          widget.destinationLng,
          widget.destinationLat,
        );

        // Parse route coordinates
        if (routeData['routes'] != null && routeData['routes'].isNotEmpty) {
          final coordinates =
              routeData['routes'][0]['geometry']['coordinates'] as List;
          _routePoints = coordinates.map((coord) {
            return LatLng(coord[1].toDouble(), coord[0].toDouble());
          }).toList();
        }
      } catch (e) {
        print('Route fetch error: $e');
        // Fallback: draw straight line
        _routePoints = [
          currentLatLng,
          LatLng(widget.destinationLat, widget.destinationLng)
        ];
      }

      setState(() {
        _distance = distance;
        _estimatedTime = time;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openInGoogleMaps() async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${widget.destinationLat},${widget.destinationLng}';

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open Google Maps'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = RoleColors.getPrimaryColor(widget.user.role);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Navigation'),
          backgroundColor: primaryColor,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Navigation'),
          backgroundColor: primaryColor,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.red.shade400),
                const SizedBox(height: 20),
                Text(
                  'Failed to load navigation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _openInGoogleMaps,
                  icon: const Icon(Icons.map),
                  label: const Text('Open in Google Maps'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            onPressed: _openInGoogleMaps,
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Open in Google Maps',
          ),
        ],
      ),
      body: Column(
        children: [
          // Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.destinationName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.destinationAddress,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.straighten,
                              size: 16, color: Colors.blue.shade700),
                          const SizedBox(width: 4),
                          Text(
                            LocationService.formatDistance(_distance ?? 0),
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 16, color: Colors.green.shade700),
                          const SizedBox(width: 4),
                          Text(
                            _estimatedTime ?? 'N/A',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Map
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation ??
                    LatLng(widget.destinationLat, widget.destinationLng),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.annadanam.food_charity',
                ),
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 4.0,
                        color: primaryColor,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (_currentLocation != null)
                      Marker(
                        point: _currentLocation!,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    Marker(
                      point:
                          LatLng(widget.destinationLat, widget.destinationLng),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom Action Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _openInGoogleMaps,
                icon: const Icon(Icons.map),
                label: const Text(
                  'Open in Google Maps',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
