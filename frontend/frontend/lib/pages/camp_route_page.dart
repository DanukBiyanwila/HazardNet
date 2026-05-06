import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../constants.dart';
import 'go_safe_page.dart';

class CampRoutePage extends StatefulWidget {
  const CampRoutePage({super.key});

  @override
  State<CampRoutePage> createState() => _CampRoutePageState();
}

class _CampRoutePageState extends State<CampRoutePage> {
  String _currentAddress = 'Fetching location...';
  List<dynamic> _camps = [];
  bool _isLoading = true;
  Position? _currentPosition;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _getCurrentLocation();
    await _fetchCamps();
  }

  Future<void> _fetchCamps() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _storage.read(key: 'jwt_token');
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/rescue_camp/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> fetchedCamps = json.decode(response.body);
        
        if (_currentPosition != null) {
          for (var camp in fetchedCamps) {
            double distance = Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              camp['location_lat'],
              camp['location_lon'],
            );
            camp['distance'] = distance;
          }
          fetchedCamps.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
        }

        if (mounted) {
          setState(() {
            _camps = fetchedCamps;
            _isLoading = false;
          });
        }
      } else {
        debugPrint('Failed to fetch camps: ${response.statusCode}');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching camps: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          _currentAddress = 'Location services are disabled.';
        });
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _currentAddress = 'Location permissions are denied';
          });
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _currentAddress = 'Location permissions are permanently denied.';
        });
      }
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _currentPosition = position;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];

      if (mounted) {
        setState(() {
          _currentAddress =
              "${place.street}, ${place.locality}, ${place.country}";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentAddress = 'Error fetching location';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camp Route'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _initData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLocationInfo(),
              const SizedBox(height: 24),
              const Text(
                'Nearest Camps',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _camps.isEmpty
                      ? const Center(child: Text('No camps found near you.'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _camps.length,
                          itemBuilder: (context, index) {
                            final camp = _camps[index];
                            return _buildCampCard(
                              context,
                              campName: camp['name']?.toString() ?? 'Unnamed Camp',
                              location: camp['address']?.toString() ?? 'No address provided',
                              people: camp['current_people_count'] ?? 0,
                              distance: camp['distance'],
                              phone: camp['tp_no']?.toString() ?? 'No phone',
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.blueAccent, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Location',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(_currentAddress),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampCard(
    BuildContext context, {
    required String campName,
    required String location,
    required int people,
    double? distance,
    required String phone,
  }) {
    String distanceText = '';
    if (distance != null) {
      if (distance < 1000) {
        distanceText = '${distance.toStringAsFixed(0)} m';
      } else {
        distanceText = '${(distance / 1000).toStringAsFixed(1)} km';
      }
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    campName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                if (distanceText.isNotEmpty)
                  Text(
                    distanceText,
                    style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(location)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.people, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('$people people'),
                const SizedBox(width: 16),
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(phone),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPosition != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GoSafePage(
                          initialOrigin: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                          initialDestination: LatLng(double.parse(_camps.firstWhere((c) => c['name'] == campName)['location_lat'].toString()), double.parse(_camps.firstWhere((c) => c['name'] == campName)['location_lon'].toString())),
                          destinationName: campName,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Wait for location to be fetched...')),
                    );
                  }
                },
                child: const Text('Go to Camp'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

