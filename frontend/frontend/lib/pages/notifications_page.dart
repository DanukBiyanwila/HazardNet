import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/constants.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _storage = const FlutterSecureStorage();
  List<dynamic> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    setState(() => _isLoading = true);
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      final String? userIdStr = await _storage.read(key: 'user_id');

      if (token == null || userIdStr == null) return;

      final url = Uri.parse('${AppConstants.baseUrl}/api/route_alert/by_user/$userIdStr');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _alerts = jsonDecode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching alerts: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(int alertId) async {
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      if (token == null) return;

      final url = Uri.parse('${AppConstants.baseUrl}/api/route_alert/$alertId');
      await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"is_know": true}),
      );
      _fetchAlerts(); // Refresh to update UI
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  Future<void> _deleteAlert(int alertId) async {
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      if (token == null) return;

      final url = Uri.parse('${AppConstants.baseUrl}/api/route_alert/$alertId');
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Alert deleted")),
          );
        }
        _fetchAlerts();
      }
    } catch (e) {
      debugPrint('Error deleting alert: $e');
    }
  }

  Future<void> _showAlertDetails(dynamic alert) async {
    final int? hazardCheckId = alert['routeHazardCheckId'];
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final String? token = await _storage.read(key: 'jwt_token');
      Map<String, dynamic>? hazardData;

      if (hazardCheckId != null) {
        final url = Uri.parse('${AppConstants.baseUrl}/api/route_hazard_check/$hazardCheckId');
        final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          hazardData = jsonDecode(response.body);
        }
      }

      if (mounted) Navigator.pop(context); // Close loading indicator
      _showDetailsPopup(alert, hazardData);
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showDetailsPopup(alert, null);
    }
  }

  void _showDetailsPopup(dynamic alert, Map<String, dynamic>? hazardData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(alert['alert_type'] ?? 'Alert'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(alert['message'] ?? 'No message available', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (hazardData != null) ...[
                const Divider(),
                const Text("Hazard Details:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                const SizedBox(height: 8),
                Text("Risk Level: ${hazardData['risk_level']}"),
                Text("Distance: ${hazardData['distance_to_hazard_m']?.toStringAsFixed(2)} meters"),
              ],
              const SizedBox(height: 16),
              Text("Time: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(alert['alert_time']))}"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (alert['is_know'] == false) {
                _markAsRead(alert['id']);
              }
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAlerts,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _alerts.isEmpty
                ? const Center(child: Text("No notifications found"))
                : ListView.builder(
                    itemCount: _alerts.length,
                    itemBuilder: (context, index) {
                      final alert = _alerts[index];
                      final isKnown = alert['is_know'] == true;
                      final DateTime time = DateTime.parse(alert['alert_time']);

                      return Dismissible(
                        key: Key(alert['id'].toString()),
                        direction: DismissDirection.endToStart,
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
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: const Text('Are you sure you want to delete this notification?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) {
                          _deleteAlert(alert['id']);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isKnown ? Colors.grey : Colors.redAccent,
                              child: const Icon(Icons.warning, color: Colors.white),
                            ),
                            title: Row(
                              children: [
                                Text(alert['alert_type'] ?? 'HAZARD', style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isKnown ? Colors.green : Colors.red,
                                    borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Text(
                                    isKnown ? "Seen" : "Not Seen",
                                    style: const TextStyle(color: Colors.white, fontSize: 10)
                                  ),
                                )
                              ],
                            ),
                            subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(time)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => _showAlertDetails(alert),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
