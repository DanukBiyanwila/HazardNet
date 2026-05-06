import 'package:flutter/material.dart';
import 'package:frontend/pages/add_need_donation_page.dart';
import 'package:frontend/service/rescue_camp_service.dart';

class ViewDonationNeedsPage extends StatefulWidget {
  const ViewDonationNeedsPage({super.key});

  @override
  State<ViewDonationNeedsPage> createState() => _ViewDonationNeedsPageState();
}

class _ViewDonationNeedsPageState extends State<ViewDonationNeedsPage> {
  final RescueCampService _rescueCampService = RescueCampService();
  List<dynamic> _donationNeeds = [];
  Map<int, String> _campNames = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    
    // Fetch all donation needs
    final needs = await _rescueCampService.getAllResourceNeeds();
    
    // Fetch all camps to map IDs to names
    final camps = await _rescueCampService.getAllRescueCamps();
    final Map<int, String> campMap = {};
    for (var camp in camps) {
      if (camp['id'] != null) {
        campMap[camp['id']] = camp['name'] ?? 'Unnamed Camp';
      }
    }

    if (mounted) {
      setState(() {
        _donationNeeds = needs;
        _campNames = campMap;
        _isLoading = false;
      });
    }
  }

  String _getItemType(dynamic need) {
    if (need['food_qty'] != null && need['food_qty'] != 0 && need['food_qty'] != "0") return 'Food';
    if (need['medicine_qty'] != null && need['medicine_qty'] != "0") return 'Medicine';
    if (need['clothes_qty'] != null && need['clothes_qty'] != "0") return 'Clothes';
    if (need['price_qty'] != null && need['price_qty'] != "0") return 'Price';
    return 'Unknown';
  }

  String _getQuantity(dynamic need) {
    if (need['food_qty'] != null && need['food_qty'] != 0 && need['food_qty'] != "0") return need['food_qty'].toString();
    if (need['medicine_qty'] != null && need['medicine_qty'] != "0") return need['medicine_qty'].toString();
    if (need['clothes_qty'] != null && need['clothes_qty'] != "0") return need['clothes_qty'].toString();
    if (need['price_qty'] != null && need['price_qty'] != "0") return need['price_qty'].toString();
    return '0';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Requested Donation Needs'),
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Upper section: Add Need Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddNeedDonationPage()),
                  ).then((_) => _fetchData());
                },
                icon: const Icon(Icons.add_circle_outline, size: 28),
                label: const Text(
                  'Add New Need',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
              ),
            ),
          ),

          const Divider(thickness: 1, indent: 16, endIndent: 16),

          // List of needs
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: _donationNeeds.isEmpty 
                    ? const Center(child: Text('No donation needs found'))
                    : ListView.builder(
                        itemCount: _donationNeeds.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemBuilder: (context, index) {
                          final need = _donationNeeds[index];
                          final itemType = _getItemType(need);
                          final quantity = _getQuantity(need);
                          final urgency = need['urgency_level'] ?? 'Low';
                          final campName = _campNames[need['rescueCampId']] ?? 'Loading...';

                          Color urgencyColor = Colors.green;
                          if (urgency == 'High') urgencyColor = Colors.red;
                          if (urgency == 'Medium') urgencyColor = Colors.orange;

                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        itemType,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: urgencyColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: urgencyColor),
                                        ),
                                        child: Text(
                                          'Urgency: $urgency',
                                          style: TextStyle(
                                            color: urgencyColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(Icons.inventory, 'Quantity: $quantity'),
                                  _buildInfoRow(Icons.home_work, 'Camp: $campName'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
