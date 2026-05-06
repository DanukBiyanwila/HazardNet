import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/constants.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:frontend/pages/map_selection_page.dart';

class DisasterManagementPage extends StatefulWidget {
  const DisasterManagementPage({super.key});

  @override
  State<DisasterManagementPage> createState() => _DisasterManagementPageState();
}

class _DisasterManagementPageState extends State<DisasterManagementPage> {
  final _storage = const FlutterSecureStorage();
  List<dynamic> _hazardAreas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchHazardAreas();
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
        setState(() {
          _hazardAreas = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load hazard areas: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteHazardArea(int id) async {
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      final url = Uri.parse('${AppConstants.baseUrl}/api/hazard_area/$id');
      final response = await http.delete(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hazard area deleted successfully')),
          );
          _fetchHazardAreas(); // Refresh the list
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _confirmDelete(int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteHazardArea(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddHazardDialog() async {
    String selectedHazardName = 'LANDSLIDE Risk Zone';
    final radiusController = TextEditingController();
    String severityLevel = 'LOW';
    LatLng? selectedLocation;
    String? detectedCity;
    String? detectedDistrict;
    bool isProcessing = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateInDialog) {
          return AlertDialog(
            title: const Text('Add New Hazard Area'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedHazardName,
                    decoration: const InputDecoration(
                      labelText: 'Hazard Name',
                      border: OutlineInputBorder(),
                    ),
                    items: ['LANDSLIDE Risk Zone', 'Flood Risk Zone A']
                        .map((name) => DropdownMenuItem(
                              value: name,
                              child: Text(name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setStateInDialog(() => selectedHazardName = value!);
                    },
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: radiusController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Radius (Meters)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: severityLevel,
                    decoration: const InputDecoration(
                      labelText: 'Severity Level',
                      border: OutlineInputBorder(),
                    ),
                    items: ['LOW', 'MEDIUM', 'HIGH']
                        .map((label) => DropdownMenuItem(
                              value: label,
                              child: Text(label),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setStateInDialog(() => severityLevel = value!);
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final LatLng? result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MapSelectionPage(),
                        ),
                      );
                      if (result != null) {
                        selectedLocation = result;
                        // Reverse geocode to get city and district
                        try {
                          List<Placemark> placemarks =
                              await placemarkFromCoordinates(
                                  result.latitude, result.longitude);
                          if (placemarks.isNotEmpty) {
                            Placemark place = placemarks[0];
                            detectedCity = place.locality ??
                                place.subAdministrativeArea ??
                                'Unknown';
                            detectedDistrict = place.subAdministrativeArea ??
                                place.administrativeArea ??
                                'Unknown';

                            if (!context.mounted) return;

                            // Show confirmation popup with details
                            await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: const Text('Location Detected'),
                                      content: Text(
                                          'City: $detectedCity\nDistrict: $detectedDistrict\nLat: ${result.latitude.toStringAsFixed(4)}\nLon: ${result.longitude.toStringAsFixed(4)}'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('OK'))
                                      ],
                                    ));
                          }
                        } catch (e) {
                          debugPrint('Geocoding error: $e');
                        }
                        setStateInDialog(() {});
                      }
                    },
                    icon: const Icon(Icons.map),
                    label: Text(selectedLocation == null
                        ? 'Select Location on Map'
                        : 'Location Selected ✓'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedLocation == null
                          ? Colors.grey[200]
                          : Colors.green[100],
                      foregroundColor: selectedLocation == null
                          ? Colors.black
                          : Colors.green[900],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: isProcessing
                    ? null
                    : () async {
                        if (radiusController.text.isEmpty ||
                            selectedLocation == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Please fill all fields and select a location')),
                          );
                          return;
                        }

                        setStateInDialog(() => isProcessing = true);

                        final String? token = await _storage.read(key: 'jwt_token');
                        final url = Uri.parse(
                            '${AppConstants.baseUrl}/api/hazard_area/create');

                        final Map<String, dynamic> hazardData = {
                          "name": selectedHazardName,
                          "location_lat": selectedLocation!.latitude,
                          "location_lon": selectedLocation!.longitude,
                          "city": detectedCity ?? "Unknown",
                          "district": detectedDistrict ?? "Unknown",
                          "created_at": DateTime.now().toIso8601String(),
                          "severity_level": severityLevel,
                          "radius_meters": radiusController.text,
                        };

                        try {
                          final response = await http.post(
                            url,
                            headers: {
                              'Content-Type': 'application/json',
                              if (token != null) 'Authorization': 'Bearer $token',
                            },
                            body: jsonEncode(hazardData),
                          );

                          if (response.statusCode == 201 ||
                              response.statusCode == 200) {
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Hazard Area Registered Successfully!')),
                            );
                            _fetchHazardAreas(); // Refresh list
                          } else {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Failed to save: ${response.statusCode}')),
                            );
                          }
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        } finally {
                          setStateInDialog(() => isProcessing = false);
                        }
                      },
                child: isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('SAVE HAZARD AREA'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hazard Area in Sri Lanka'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showAddHazardDialog,
            icon: const Icon(Icons.add_location_alt),
            tooltip: 'Add Hazard Area',
          ),
          IconButton(
            onPressed: _fetchHazardAreas,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _hazardAreas.isEmpty
                  ? const Center(child: Text('No hazard areas reported'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _hazardAreas.length,
                      itemBuilder: (context, index) {
                        return _buildHazardCard(_hazardAreas[index]);
                      },
                    ),
    );
  }

  Widget _buildHazardCard(dynamic area) {
    final severity = area['severity_level'] ?? 'LOW';
    Color severityColor = Colors.green;
    if (severity == 'HIGH') severityColor = Colors.red;
    if (severity == 'MEDIUM') severityColor = Colors.orange;

    DateTime createdAt;
    try {
      createdAt = DateTime.parse(area['created_at']);
    } catch (e) {
      createdAt = DateTime.now();
    }
    final String formattedDate =
        DateFormat('yyyy-MM-dd HH:mm').format(createdAt);

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                    area['name'] ?? 'Unnamed Hazard',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () =>
                      _confirmDelete(area['id'], area['name'] ?? 'Hazard Area'),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: severityColor),
                  ),
                  child: Text(
                    severity,
                    style: TextStyle(
                        color: severityColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildInfoRow(Icons.calendar_today, 'Reported At', formattedDate),
            _buildInfoRow(
                Icons.radar, 'Radius', '${area['radius_meters'] ?? 0} meters'),
            _buildInfoRow(Icons.location_city, 'District',
                area['district'] ?? 'Unknown'),
            _buildInfoRow(
                Icons.location_on, 'City', area['city'] ?? 'Unknown'),
            const SizedBox(height: 10),
            _buildUserCountSection(area['users']?.length ?? 0),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Text('$label: ',
              style: TextStyle(
                  color: Colors.grey[600], fontWeight: FontWeight.w500)),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildUserCountSection(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.people, color: Colors.blueAccent),
          const SizedBox(width: 15),
          const Text(
            'Users in this area:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Spacer(),
          Text(
            '$count',
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent),
          ),
        ],
      ),
    );
  }
}
