import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';

class CampDetailsPage extends StatelessWidget {
  final dynamic campData;

  const CampDetailsPage({super.key, required this.campData});

  String _resolveImageUrl(String? rawPath) {
    if (rawPath == null || rawPath.isEmpty) return '';
    
    // Extract filename if it's a full path
    String filename = rawPath;
    if (rawPath.contains('\\')) {
      filename = rawPath.split('\\').last;
    } else if (rawPath.contains('/')) {
      filename = rawPath.split('/').last;
    }
    
    // Industrial way: Construct the URL pointing to the backend's static uploads directory
    return '${AppConstants.baseUrl}/uploads/camp/$filename';
  }

  @override
  Widget build(BuildContext context) {
    final String campName = campData['name'] ?? 'Camp Details';
    final String? imageUrl = campData['people_image_url'];
    
    // Calculate total orphan groups
    final List<dynamic> orphanGroups = campData['orphanGroups'] ?? [];
    final int orphanGroupsCount = orphanGroups.length;

    // Calculate total people (Current people in camp + total kids in orphan groups)
    final int currentPeople = campData['current_people_count'] ?? 0;
    int totalKids = 0;
    for (var group in orphanGroups) {
      totalKids += (group['num_of_kids'] as num? ?? 0).toInt();
    }
    final int totalPeople = currentPeople + totalKids;

    // Summarize donation needs
    final List<dynamic> resourceNeeds = campData['resourceNeeds'] ?? [];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(campName),
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // People in this camp photo section
            if (imageUrl != null && imageUrl.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'People in this camp photo',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        _resolveImageUrl(imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Image not available', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Camp Statistics',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailCard('Orphan Groups', '$orphanGroupsCount Groups', Icons.child_care, Colors.orange),
                  _buildDetailCard('Total People', '$totalPeople People', Icons.groups, Colors.blue),
                  _buildDetailCard('People in Camp', '$currentPeople People', Icons.person, Colors.teal),
                  _buildDetailCard('Kids in Orphanage', '$totalKids Kids', Icons.child_friendly, Colors.purple),
                  
                  const SizedBox(height: 24),
                  const Text(
                    'Donation Goals & Needs',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  
                  if (resourceNeeds.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No specific resource needs listed for this camp.'),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: resourceNeeds.length,
                      itemBuilder: (context, index) {
                        final need = resourceNeeds[index];
                        return _buildNeedItem(need);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildNeedItem(dynamic need) {
    String type = 'General';
    String qty = '0';
    IconData icon = Icons.inventory;
    Color color = Colors.grey;

    if (need['food_qty'] != null && need['food_qty'] != 0 && need['food_qty'] != "0") {
      type = 'Food';
      qty = need['food_qty'].toString();
      icon = Icons.restaurant;
      color = Colors.orange;
    } else if (need['medicine_qty'] != null && need['medicine_qty'] != "0") {
      type = 'Medicine';
      qty = need['medicine_qty'].toString();
      icon = Icons.medical_services;
      color = Colors.blue;
    } else if (need['clothes_qty'] != null && need['clothes_qty'] != "0") {
      type = 'Clothes';
      qty = need['clothes_qty'].toString();
      icon = Icons.checkroom;
      color = Colors.purple;
    } else if (need['price_qty'] != null && need['price_qty'] != "0") {
      type = 'Money/Price';
      qty = need['price_qty'].toString();
      icon = Icons.attach_money;
      color = Colors.green;
    }

    final String urgency = need['urgency_level'] ?? 'Normal';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text('$type Need', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Quantity: $qty'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: urgency == 'High' ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: urgency == 'High' ? Colors.red : Colors.orange),
          ),
          child: Text(
            urgency,
            style: TextStyle(
              color: urgency == 'High' ? Colors.red : Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
