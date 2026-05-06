import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/pages/view_donation_needs_page.dart';

class DonationManagementPage extends StatefulWidget {
  const DonationManagementPage({super.key});

  @override
  State<DonationManagementPage> createState() => _DonationManagementPageState();
}

class _DonationManagementPageState extends State<DonationManagementPage> {
  final _storage = const FlutterSecureStorage();
  List<dynamic> _donations = [];
  bool _isLoading = true;
  final Map<int, String> _userNames = {};

  // Summary counts
  double _foodTotal = 0;
  double _clothesTotal = 0;
  double _medicTotal = 0;
  double _priceTotal = 0;

  @override
  void initState() {
    super.initState();
    _fetchDonations();
  }

  Future<void> _fetchDonations() async {
    setState(() => _isLoading = true);
    try {
      final token = await _storage.read(key: 'jwt_token');
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/donation/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        
        // Reset totals
        _foodTotal = 0;
        _clothesTotal = 0;
        _medicTotal = 0;
        _priceTotal = 0;

        for (var donation in data) {
          final type = donation['item_type'].toString().toLowerCase();
          final qty = double.tryParse(donation['quantity'].toString()) ?? 0.0;
          
          if (type.contains('food')) _foodTotal += qty;
          else if (type.contains('clothe')) _clothesTotal += qty;
          else if (type.contains('medic')) _medicTotal += qty;
          else if (type.contains('price')) _priceTotal += qty;

          // Fetch user name if not cached
          int userId = donation['userId'];
          if (!_userNames.containsKey(userId)) {
            await _fetchUserName(userId);
          }
        }

        if (mounted) {
          setState(() {
            _donations = data;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching donations: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchUserName(int userId) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/user/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        _userNames[userId] = userData['name'] ?? 'User $userId';
      }
    } catch (e) {
      _userNames[userId] = 'User $userId';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Management'),
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: _fetchDonations,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.8,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSummaryCard('Medicine', '${_medicTotal.toInt()} Units', Icons.medical_services, Colors.blue),
                _buildSummaryCard('Food', '${_foodTotal.toInt()} Units', Icons.restaurant, Colors.orange),
                _buildSummaryCard('Clothes', '${_clothesTotal.toInt()} Items', Icons.checkroom, Colors.purple),
                _buildSummaryCard('Money', 'LKR ${_priceTotal.toInt()}', Icons.money, Colors.green),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Donors',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ViewDonationNeedsPage()),
                    );
                  },
                  icon: const Icon(Icons.list_alt),
                  label: const Text('View Wanted Donations'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: _donations.isEmpty 
              ? const Center(child: Text('No donations found'))
              : ListView.builder(
              itemCount: _donations.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final donation = _donations[index];
                final type = donation['item_type'].toString().toLowerCase();
                final userId = donation['userId'];
                final userName = _userNames[userId] ?? 'Loading...';
                final dateStr = donation['created_at'].toString().split('T').first;

                IconData icon;
                Color color;

                if (type.contains('medic')) {
                  icon = Icons.medical_services;
                  color = Colors.blue;
                } else if (type.contains('food')) {
                  icon = Icons.restaurant;
                  color = Colors.orange;
                } else if (type.contains('clothe')) {
                  icon = Icons.checkroom;
                  color = Colors.purple;
                } else {
                  icon = Icons.money;
                  color = Colors.green;
                }

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.1),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    title: Text(
                      userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${donation['item_type']} • Status: ${donation['status']}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Qty: ${donation['quantity']}',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          dateStr,
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
