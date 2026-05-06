import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/constants.dart';

class DisasterZonePage extends StatefulWidget {
  const DisasterZonePage({super.key});

  @override
  State<DisasterZonePage> createState() => _DisasterZonePageState();
}

class _DisasterZonePageState extends State<DisasterZonePage> {
  final _storage = const FlutterSecureStorage();
  final LatLng _sriLankaCenter = const LatLng(7.8731, 80.7718); // Center of Sri Lanka
  
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  bool _isLoading = true;
  String? _error;

  late BitmapDescriptor _floodIcon;
  late BitmapDescriptor _landslideIcon;

  @override
  void initState() {
    super.initState();
    _loadCustomIcons().then((_) {
      _fetchHazardAreas();
    });
  }

  Future<void> _loadCustomIcons() async {
    _floodIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/flood.png',
    );
    _landslideIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/landslide.png',
    );
  }

  Future<void> _fetchHazardAreas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final String? token = await _storage.read(key: 'jwt_token');
      
      final url = Uri.parse('${AppConstants.baseUrl}/api/hazard_area/');
      final response = await http.get(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _processHazardData(data);
      } else {
        setState(() {
          _error = 'Failed to load hazard areas: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  void _processHazardData(List<dynamic> data) {
    Set<Marker> newMarkers = {};
    Set<Circle> newCircles = {};

    for (var area in data) {
      final String name = area['name'] ?? 'Hazard Area';
      final double lat = (area['location_lat'] as num?)?.toDouble() ?? 0.0;
      final double lon = (area['location_lon'] as num?)?.toDouble() ?? 0.0;
      final String severity = area['severity_level'] ?? 'LOW';
      final double radius = double.tryParse(area['radius_meters']?.toString() ?? '0') ?? 0.0;
      final String city = area['city'] ?? '';
      
      bool isFlood = name.toUpperCase().contains('FLOOD');
      bool isLandslide = name.toUpperCase().contains('LANDSLIDE');

      BitmapDescriptor icon = BitmapDescriptor.defaultMarker;
      Color circleColor = Colors.blue.withValues(alpha: 0.3);

      if (isFlood) {
        icon = _floodIcon;
        circleColor = Colors.blue.withValues(alpha: 0.3);
      } else if (isLandslide) {
        icon = _landslideIcon;
        circleColor = Colors.orange.withValues(alpha: 0.3);
      }

      if (severity == 'HIGH') {
        circleColor = Colors.red.withValues(alpha: 0.4);
      }

      final markerId = MarkerId('hazard_${area['id']}');
      newMarkers.add(
        Marker(
          markerId: markerId,
          position: LatLng(lat, lon),
          icon: icon,
          infoWindow: InfoWindow(
            title: name,
            snippet: 'Severity: $severity | City: $city',
          ),
        ),
      );

      if (radius > 0) {
        newCircles.add(
          Circle(
            circleId: CircleId('circle_${area['id']}'),
            center: LatLng(lat, lon),
            radius: radius,
            fillColor: circleColor,
            strokeWidth: 2,
            strokeColor: circleColor.withValues(alpha: 0.8),
          ),
        );
      }
    }

    setState(() {
      _markers = newMarkers;
      _circles = newCircles;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disaster Zones'),
        backgroundColor: Colors.black.withValues(alpha: 0.7),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchHazardAreas,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.red),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      ElevatedButton(
                        onPressed: _fetchHazardAreas,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _sriLankaCenter,
                    zoom: 7.5,
                  ),
                  markers: _markers,
                  circles: _circles,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapType: MapType.normal,
                ),
      extendBodyBehindAppBar: true,
    );
  }
}
