import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/pages/add_emergency_service_page.dart';
import 'package:frontend/pages/sos_people_list_page.dart';

class SosManagementPage extends StatefulWidget {
  const SosManagementPage({super.key});

  @override
  State<SosManagementPage> createState() => _SosManagementPageState();
}

class _SosManagementPageState extends State<SosManagementPage> {
  final _storage = const FlutterSecureStorage();
  List<dynamic> _emergencyServices = [];
  bool _isLoading = true;
  final Map<int, String> _readableAddresses = {};

  @override
  void initState() {
    super.initState();
    _fetchEmergencyServices();
  }

  Future<void> _fetchEmergencyServices() async {
    setState(() => _isLoading = true);
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      final url = Uri.parse('${AppConstants.baseUrl}/api/emergency_service/');
      
      final response = await http.get(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _emergencyServices = data;
          _isLoading = false;
        });
        _convertToReadableAddresses(data);
      }
    } catch (e) {
      debugPrint('Error fetching emergency services: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _convertToReadableAddresses(List<dynamic> services) async {
    for (var service in services) {
      final double lat = service['location_lat'];
      final double lon = service['location_lon'];
      final int id = service['id'];

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String address = [place.name, place.subLocality, place.locality]
              .where((e) => e != null && e.isNotEmpty)
              .join(", ");
          if (mounted) {
            setState(() {
              _readableAddresses[id] = address;
            });
          }
        }
      } catch (e) {
        debugPrint('Geocoding error for service $id: $e');
      }
    }
  }

  Future<void> _deleteEmergencyService(int id) async {
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      final url = Uri.parse('${AppConstants.baseUrl}/api/emergency_service/$id');

      final response = await http.delete(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) {
          setState(() {
            _emergencyServices.removeWhere((service) => service['id'] == id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Emergency service deleted')),
          );
        }
      } else {
        throw Exception('Failed to delete: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error deleting service: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete emergency service')),
        );
        _fetchEmergencyServices(); // Refresh on error to restore state
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Management'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SosPeopleListPage()),
                  );
                },
                icon: const Icon(Icons.people),
                label: const Text('SHOW SOS PEOPLE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchEmergencyServices,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _emergencyServices.isEmpty
                      ? const Center(child: Text('No emergency services found'))
                      : ListView.builder(
                          itemCount: _emergencyServices.length,
                          itemBuilder: (context, index) {
                            final service = _emergencyServices[index];
                            final int id = service['id'];
                            return Dismissible(
                              key: Key(id.toString()),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (direction) async {
                                return await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirm Delete'),
                                    content: const Text('Are you sure you want to delete this emergency service?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('CANCEL'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('DELETE', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (direction) {
                                _deleteEmergencyService(id);
                              },
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              child: Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                elevation: 3,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.purple.withValues(alpha: 0.1),
                                    child: Icon(_getServiceIcon(service['service_type']), color: Colors.purple),
                                  ),
                                  title: Text(service['name'] ?? 'Unknown Service', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Type: ${service['service_type']}'),
                                      Text('Address: ${service['address']}'),
                                      Text(
                                        'Real Loc: ${_readableAddresses[id] ?? "Fetching address..."}',
                                        style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                                      ),
                                      Text('Phone: ${service['phone']}'),
                                    ],
                                  ),
                                  isThreeLine: true,
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddEmergencyServicePage()),
                  );
                  if (result == true) {
                    _fetchEmergencyServices();
                  }
                },
                icon: const Icon(Icons.add_location_alt),
                label: const Text('ADD SERVICE CENTER'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getServiceIcon(String? type) {
    switch (type?.toUpperCase()) {
      case 'HOSPITAL': return Icons.local_hospital;
      case 'POLICE': return Icons.local_police;
      case 'FIRE': return Icons.fire_truck;
      default: return Icons.emergency;
    }
  }
}
