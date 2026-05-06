import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:frontend/constants.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class SOSPage extends StatefulWidget {
  const SOSPage({super.key});

  @override
  State<SOSPage> createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> {
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;
  Map<String, dynamic>? _reportResult;

  Future<void> _reportEmergency(String type) async {
    setState(() => _isLoading = true);

    try {
      // Get location
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      
      final String? token = await _storage.read(key: 'jwt_token');
      final String? userId = await _storage.read(key: 'user_id');

      if (token == null || userId == null) {
        throw 'User not authenticated';
      }

      final url = Uri.parse('${AppConstants.baseUrl}/api/emergency_reports/create');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "emergency_type": type.toUpperCase(),
          "location_lat": position.latitude,
          "location_lon": position.longitude,
          "status": "REPORTED",
          "created_at": DateTime.now().toIso8601String(),
          "userId": int.tryParse(userId) ?? userId,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        setState(() {
          _reportResult = jsonDecode(response.body);
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('SOS for $type reported successfully!')),
          );
        }
      } else {
        throw 'Failed to report emergency: ${response.statusCode}';
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri.parse('tel:${phoneNumber.trim()}');
    try {
      await launchUrl(url);
    } catch (e) {
      debugPrint('Call Error: $e');
    }
  }

  Future<String> _getAddressFromLatLng(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return "${place.name}, ${place.locality}, ${place.country}";
      }
    } catch (e) {
      debugPrint("Geocoding error: $e");
    }
    return "Lat: $lat, Lon: $lon";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  if (_reportResult == null) ...[
                    Image.asset(
                      'assets/images/home_safty_main_background.jpg',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSOSCategory(title: 'Accident', icon: Icons.car_crash, color: Colors.orange),
                          _buildSOSCategory(title: 'Robbery', icon: Icons.masks, color: Colors.redAccent),
                          _buildSOSCategory(title: 'Flood', icon: Icons.water_drop, color: Colors.blue),
                          _buildSOSCategory(title: 'Landslide', icon: Icons.landscape, color: Colors.brown),
                        ],
                      ),
                    ),
                  ] else ...[
                    _buildReportResultUI(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSOSCategory({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: () => _reportEmergency(title),
        icon: Icon(icon, size: 28),
        label: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildReportResultUI() {
    final services = _reportResult!['nearestServices'] as List<dynamic>? ?? [];
    final contacts = _reportResult!['trustedContacts'] as List<dynamic>? ?? [];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.redAccent),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      "Emergency Reported: ${_reportResult!['emergency_type']}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Status: ${_reportResult!['status']}"),
                Text("Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(_reportResult!['created_at']))}"),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Nearest Services",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...services.map((s) => _buildServiceCard(s)),
          const SizedBox(height: 24),
          const Text(
            "Trusted Contacts Notified",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...contacts.map((c) => _buildContactCard(c)),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _reportResult = null),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Report Another Emergency", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(dynamic service) {
    return FutureBuilder<String>(
      future: _getAddressFromLatLng(service['location_lat'], service['location_lon']),
      builder: (context, snapshot) {
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.local_hospital, color: Colors.white),
            ),
            title: Text(service['name'] ?? 'Service', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service['service_type'] ?? ''),
                Text(snapshot.data ?? 'Loading address...'),
                Text(service['phone'] ?? ''),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () => _makePhoneCall(service['phone']),
            ),
          ),
        );
      }
    );
  }

  Widget _buildContactCard(dynamic contact) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.redAccent,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(contact['name'] ?? 'Contact', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(contact['contact_email'] ?? ''),
            Text(contact['contact_phone'] ?? ''),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.call, color: Colors.green),
          onPressed: () => _makePhoneCall(contact['contact_phone']),
        ),
      ),
    );
  }
}
