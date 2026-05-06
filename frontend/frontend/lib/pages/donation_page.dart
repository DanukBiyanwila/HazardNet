import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/pages/add_donation_page.dart';
import 'package:frontend/pages/camp_details_page.dart';
import 'package:frontend/service/rescue_camp_service.dart';
import 'package:intl/intl.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final _storage = const FlutterSecureStorage();
  final RescueCampService _rescueCampService = RescueCampService();
  
  String _name = 'Loading...';
  String _email = 'Loading...';
  String? _imageUrl;
  List<dynamic> _rescueCamps = [];
  List<dynamic> _userDonations = [];
  bool _isLoadingCamps = true;
  bool _isLoadingDonations = true;
  bool _showUserDonations = false;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _fetchCamps();
    _fetchUserDonations();
  }

  Future<void> _fetchCamps() async {
    setState(() => _isLoadingCamps = true);
    final camps = await _rescueCampService.getAllRescueCamps();
    if (mounted) {
      setState(() {
        _rescueCamps = camps;
        _isLoadingCamps = false;
      });
    }
  }

  Future<void> _fetchUserDonations() async {
    try {
      setState(() => _isLoadingDonations = true);
      final String? token = await _storage.read(key: 'jwt_token');
      final String? userId = await _storage.read(key: 'user_id');

      if (token == null || userId == null) return;

      final url = Uri.parse('${AppConstants.baseUrl}/api/donation/by_user/$userId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> donations = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _userDonations = donations;
            _isLoadingDonations = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingDonations = false);
      }
    }
  }

  Future<void> _fetchUserDetails() async {
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      final String? userId = await _storage.read(key: 'user_id');

      if (token == null || userId == null) {
        setState(() {
          _name = 'User Not Logged In';
          _email = '';
        });
        return;
      }

      final url = Uri.parse('${AppConstants.baseUrl}/api/user/$userId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = jsonDecode(response.body);
        setState(() {
          _name = userData['name'] ?? 'No Name';
          _email = userData['email'] ?? 'No Email';
          _imageUrl = userData['imageUrl'];
        });
      } else {
        setState(() {
          _name = 'Error Loading User';
          _email = '';
        });
      }
    } catch (e) {
      setState(() {
        _name = 'Error';
        _email = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donations'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchUserDetails();
          await _fetchCamps();
          await _fetchUserDonations();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserDetails(),
                const SizedBox(height: 24),
                _buildDonationTotals(),
                const SizedBox(height: 24),
                _buildActionButtons(context),
                const SizedBox(height: 24),
                if (_showUserDonations) _buildUserDonationsSection(),
                if (!_showUserDonations) _buildCampsSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddDonationPage()),
              ).then((_) => _fetchUserDonations());
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Donation'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _showUserDonations = !_showUserDonations;
              });
            },
            icon: Icon(_showUserDonations ? Icons.home_work : Icons.list),
            label: Text(_showUserDonations ? 'View Camps' : 'My Donations'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserDonationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Donations',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _isLoadingDonations
            ? const Center(child: CircularProgressIndicator())
            : _userDonations.isEmpty
                ? const Center(child: Text('You haven\'t made any donations yet.'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _userDonations.length,
                    itemBuilder: (context, index) {
                      final donation = _userDonations[index];
                      return _buildDonationCard(donation);
                    },
                  ),
      ],
    );
  }

  Widget _buildDonationCard(dynamic donation) {
    String dateStr = donation['created_at'] ?? '';
    String formattedDate = 'N/A';
    if (dateStr.isNotEmpty) {
      try {
        DateTime dt = DateTime.parse(dateStr);
        formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(dt);
      } catch (e) {
        formattedDate = dateStr;
      }
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(donation['status']),
          child: Icon(
            _getItemIcon(donation['item_type']),
            color: Colors.white,
          ),
        ),
        title: Text(
          donation['name'] ?? donation['item_type'] ?? 'Unnamed Item',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${donation['item_type']}'),
            Text('Quantity: ${donation['quantity']}'),
            Text('Date: $formattedDate', style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(donation['status']).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _getStatusColor(donation['status'])),
          ),
          child: Text(
            donation['status'] ?? 'PENDING',
            style: TextStyle(
              color: _getStatusColor(donation['status']),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getItemIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'food': return Icons.fastfood;
      case 'medicine': return Icons.medical_services;
      case 'clothes': return Icons.checkroom;
      case 'price': return Icons.attach_money;
      default: return Icons.inventory;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING': return Colors.orange;
      case 'COMPLETED': return Colors.green;
      case 'CANCELLED': return Colors.red;
      default: return Colors.blue;
    }
  }

  Widget _buildUserDetails() {
    final String? profileImageUrl = (_imageUrl != null && _imageUrl!.isNotEmpty)
        ? '${AppConstants.baseUrl}/uploads/users/$_imageUrl'
        : null;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[200],
          backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl) : null,
          child: profileImageUrl == null
              ? const Icon(Icons.person, color: Colors.grey)
              : null,
        ),
        title: Text(
          _name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_email),
      ),
    );
  }

  Widget _buildDonationTotals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Donation Summary',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTotalCard(
                'Your Donations',
                '${_userDonations.length}',
                Colors.blueAccent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTotalCard(
                'Active Camps',
                '${_rescueCamps.length}',
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalCard(String title, String amount, Color color) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Camps',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchCamps,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _isLoadingCamps 
          ? const Center(child: CircularProgressIndicator())
          : _rescueCamps.isEmpty 
            ? const Center(child: Text('No camps available'))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _rescueCamps.length,
                itemBuilder: (context, index) {
                  final camp = _rescueCamps[index];
                  return _buildCampCard(context, camp);
                },
              ),
      ],
    );
  }

  Widget _buildCampCard(BuildContext context, dynamic camp) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: const Icon(Icons.home_work, size: 40, color: Colors.teal),
        title: Text(
          camp['name'] ?? 'Unnamed Camp', 
          style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(camp['address'] ?? 'No address'),
            Text(
              'Loc: ${camp['location_lat']?.toStringAsFixed(4)}, ${camp['location_lon']?.toStringAsFixed(4)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CampDetailsPage(campData: camp),
            ),
          );
        },
      ),
    );
  }
}
