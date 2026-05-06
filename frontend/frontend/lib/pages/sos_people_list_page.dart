import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:frontend/constants.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class SosPeopleListPage extends StatefulWidget {
  const SosPeopleListPage({super.key});

  @override
  State<SosPeopleListPage> createState() => _SosPeopleListPageState();
}

class _SosPeopleListPageState extends State<SosPeopleListPage> {
  final _storage = const FlutterSecureStorage();
  List<dynamic> _reports = [];
  bool _isLoading = true;
  final Map<int, String> _readableAddresses = {};
  final Map<int, String> _userNames = {};

  @override
  void initState() {
    super.initState();
    _fetchEmergencyReports();
  }

  Future<void> _fetchEmergencyReports() async {
    setState(() => _isLoading = true);
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      final url = Uri.parse('${AppConstants.baseUrl}/api/emergency_reports/');
      
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
          _reports = data;
          _isLoading = false;
        });
        _convertToReadableAddresses(data);
        _fetchUserNames(data);
      }
    } catch (e) {
      debugPrint('Error fetching emergency reports: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchUserNames(List<dynamic> reports) async {
    final String? token = await _storage.read(key: 'jwt_token');
    if (token == null) return;

    final userIds = reports.map((r) => r['userId'] as int).toSet();

    for (var userId in userIds) {
      try {
        final url = Uri.parse('${AppConstants.baseUrl}/api/user/$userId');
        final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final userData = jsonDecode(response.body);
          if (mounted) {
            setState(() {
              _userNames[userId] = userData['name'] ?? 'Unknown User';
            });
          }
        }
      } catch (e) {
        debugPrint('Error fetching user $userId: $e');
      }
    }
  }

  Future<void> _convertToReadableAddresses(List<dynamic> reports) async {
    for (var report in reports) {
      final double lat = report['location_lat'];
      final double lon = report['location_lon'];
      final int id = report['id'];

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
        debugPrint('Geocoding error for report $id: $e');
      }
    }
  }

  Future<void> _showContacts(int userId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final String? token = await _storage.read(key: 'jwt_token');
      final url = Uri.parse('${AppConstants.baseUrl}/api/trusted_contacts/by_user/$userId');
      
      final response = await http.get(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      Navigator.pop(context); // Close loader

      if (response.statusCode == 200) {
        final List<dynamic> contacts = jsonDecode(response.body);
        _showContactsPopup(contacts);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      debugPrint('Error fetching contacts: $e');
    }
  }

  void _showContactsPopup(List<dynamic> contacts) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trusted Contacts'),
        content: SizedBox(
          width: double.maxFinite,
          child: contacts.isEmpty 
            ? const Text('No trusted contacts found.')
            : ListView.builder(
                shrinkWrap: true,
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return ListTile(
                    title: Text(contact['name'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => _makePhoneCall(contact['contact_phone']),
                          child: Text(contact['contact_phone'] ?? '', style: const TextStyle(color: Colors.blue)),
                        ),
                        InkWell(
                          onTap: () => _sendEmail(contact['contact_email']),
                          child: Text(contact['contact_email'] ?? '', style: const TextStyle(color: Colors.blue)),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  );
                },
              ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) return;
    final Uri url = Uri.parse('tel:${phoneNumber.trim()}');
    try {
      await launchUrl(url);
    } catch (e) {
      debugPrint('Launch Error: $e');
    }
  }

  Future<void> _sendEmail(String? email) async {
    if (email == null || email.trim().isEmpty) return;
    final Uri url = Uri.parse('mailto:${email.trim()}?subject=Emergency%20Alert%20Person');
    try {
      await launchUrl(url);
    } catch (e) {
      debugPrint('Launch Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS People List'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchEmergencyReports,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _reports.isEmpty
                ? const Center(child: Text('No emergency reports found'))
                : ListView.builder(
                    itemCount: _reports.length,
                    itemBuilder: (context, index) {
                      final report = _reports[index];
                      final int id = report['id'];
                      final int userId = report['userId'];
                      final DateTime time = DateTime.parse(report['created_at']);

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.redAccent,
                            child: Icon(Icons.warning, color: Colors.white),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userNames[userId] ?? "Loading name...",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                report['emergency_type'] ?? 'EMERGENCY',
                                style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.red),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Time: ${DateFormat('yyyy-MM-dd HH:mm').format(time)}'),
                              Text(
                                'Location: ${_readableAddresses[id] ?? "Fetching..."}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                              Text('Status: ${report['status']}', style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                            ],
                          ),
                          trailing: const Icon(Icons.contact_phone, color: Colors.blueAccent),
                          onTap: () => _showContacts(report['userId']),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
