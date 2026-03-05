import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapViewPage extends StatefulWidget {
  final List<Map<String, dynamic>> tasks;

  const MapViewPage({super.key, required this.tasks});

  @override
  _MapViewPageState createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  LatLng? _currentLocation;
  List<Polyline> _polylines = [];
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _disableSecureMode();
    _setupMap();
  }

  Future<void> _disableSecureMode() async {
    try {
      const channel = MethodChannel('com.annadanam.app/security');
      await channel.invokeMethod('disableSecure');
      debugPrint('MapView: Requested screen security disable');
    } catch (e) {
      debugPrint('MapView: Error disabling screen security: $e');
    }
  }

  void _setupMap() {
    // Simulate current location (Delhi)
    _currentLocation = const LatLng(28.6139, 77.2090);

    // Add markers
    _markers = [
      Marker(
        point: _currentLocation!,
        width: 40,
        height: 40,
        child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
      ),
    ];

    // Add task markers
    for (int i = 0; i < widget.tasks.length; i++) {
      final task = widget.tasks[i];
      _markers.add(
        Marker(
          point: LatLng(
            task['latitude'] ?? 28.6 + (i * 0.01),
            task['longitude'] ?? 77.2 + (i * 0.01),
          ),
          width: 40,
          height: 40,
          child: Icon(
            task['type'] == 'Pickup' ? Icons.upload : Icons.download,
            color: task['type'] == 'Pickup' ? Colors.green : Colors.orange,
            size: 30,
          ),
        ),
      );
    }
  }

  void _calculateRoute() async {
    if (_currentLocation == null || widget.tasks.isEmpty) return;

    // Create list of all points
    List<List<double>> allPoints = [
      [_currentLocation!.latitude, _currentLocation!.longitude]
    ];

    for (final task in widget.tasks) {
      allPoints.add([
        task['latitude'] ?? 28.6,
        task['longitude'] ?? 77.2,
      ]);
    }

    // Calculate optimal route (simplified version)
    List<LatLng> routePoints = [];

    // Start from current location
    routePoints.add(_currentLocation!);

    // Add all task points in order
    for (final task in widget.tasks) {
      routePoints.add(LatLng(
        task['latitude'] ?? 28.6,
        task['longitude'] ?? 77.2,
      ));
    }

    setState(() {
      _polylines = [
        Polyline(
          points: routePoints,
          strokeWidth: 4,
          color: Colors.blue,
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
      ),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
        options: MapOptions(
          initialCenter: _currentLocation!, // Changed from 'center' to 'initialCenter'
          initialZoom: 13.0, // Changed from 'zoom' to 'initialZoom'
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.annadanam.app',
          ),
          PolylineLayer(polylines: _polylines),
          MarkerLayer(markers: _markers),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _calculateRoute,
        child: const Icon(Icons.route),
      ),
    );
  }
}