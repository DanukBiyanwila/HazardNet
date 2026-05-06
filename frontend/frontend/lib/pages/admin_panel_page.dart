import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/pages/camp_details_management_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:frontend/pages/map_selection_page.dart';
import 'package:frontend/service/rescue_camp_service.dart';
import 'package:image_picker/image_picker.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final RescueCampService _rescueCampService = RescueCampService();
  final ImagePicker _picker = ImagePicker();
  bool _isCreating = false;
  bool _isLoading = true;

  // Dynamic list of rescue camps
  List<dynamic> _rescueCamps = [];

  @override
  void initState() {
    super.initState();
    _fetchCamps();
  }

  Future<void> _fetchCamps() async {
    setState(() => _isLoading = true);
    final camps = await _rescueCampService.getAllRescueCamps();
    if (mounted) {
      setState(() {
        _rescueCamps = camps;
        _isLoading = false;
      });
    }
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    _contactController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  void _showAddCampDialog() {
    _nameController.clear();
    _locationController.clear();
    _capacityController.clear();
    _contactController.clear();
    _latController.clear();
    _lngController.clear();
    XFile? selectedImage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateInDialog) {
          Future<void> pickImage() async {
            final XFile? image = await _picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 70, // Compresses the image to 70% quality
            );
            if (image != null) {
              setStateInDialog(() {
                selectedImage = image;
              });
            }
          }

          return AlertDialog(
            title: const Text('Register New Rescue Camp'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Camp Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location / Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _capacityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Capacity',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _contactController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Contact',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  const Text('Location Coordinates',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _latController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Latitude',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _lngController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final LatLng? result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MapSelectionPage(),
                        ),
                      );
                      if (result != null) {
                        setStateInDialog(() {
                          _latController.text = result.latitude.toString();
                          _lngController.text = result.longitude.toString();
                        });
                      }
                    },
                    icon: const Icon(Icons.map),
                    label: const Text('Select on Map'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent.withValues(alpha: 0.2),
                      foregroundColor: Colors.orange[900],
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  const Text('Camp Photo',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: selectedImage == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, color: Colors.grey),
                                Text('Add Photo',
                                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(selectedImage!.path),
                                fit: BoxFit.cover,
                              ),
                            ),
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
                onPressed: _isCreating
                    ? null
                    : () async {
                        if (_nameController.text.isEmpty ||
                            _latController.text.isEmpty ||
                            _lngController.text.isEmpty ||
                            _capacityController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill all required fields')),
                          );
                          return;
                        }

                        setStateInDialog(() {
                          _isCreating = true;
                        });

                        final success = await _rescueCampService.createRescueCamp(
                          name: _nameController.text,
                          lat: double.parse(_latController.text),
                          lon: double.parse(_lngController.text),
                          capacity: int.parse(_capacityController.text),
                          address: _locationController.text,
                          phone: _contactController.text,
                          imageFile: selectedImage != null ? File(selectedImage!.path) : null,
                        );

                        setStateInDialog(() {
                          _isCreating = false;
                        });

                        if (success) {
                          if (!context.mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('New Camp Registered Successfully!')),
                          );
                          // Navigate to management page for the new camp
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CampDetailsManagementPage(campName: _nameController.text),
                            ),
                          );
                        } else {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to register camp')),
                          );
                        }
                      },
                child: _isCreating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('SAVE CAMP'),
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
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCamps,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCampDialog,
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_home_work),
        label: const Text('Add New Camp'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsRow(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Text(
              'Manage Rescue Camps',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchCamps,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _rescueCamps.length,
                      itemBuilder: (context, index) {
                        final camp = _rescueCamps[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CampDetailsManagementPage(
                                  campName: camp['name']!,
                                  campId: camp['id'],
                                ),
                              ),
                            ).then((_) => _fetchCamps());
                          },                          child: _buildCampCard(camp),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    int totalCapacity = 0;
    for (var camp in _rescueCamps) {
      totalCapacity += (camp['capacity'] as int? ?? 0);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.orangeAccent.withValues(alpha: 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total Camps', '${_rescueCamps.length}', Icons.home_work),
          _buildStatItem('Active', '${_rescueCamps.length}', Icons.check_circle, Colors.green),
          _buildStatItem('Capacity', '$totalCapacity', Icons.people),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, [Color? color]) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.orangeAccent, size: 30),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildCampCard(dynamic camp) {
    // Determine status based on capacity
    int capacity = camp['capacity'] ?? 0;
    int current = camp['current_people_count'] ?? 0;
    String status = current >= capacity && capacity > 0 ? 'Full' : 'Active';
    Color statusColor = status == 'Active' ? Colors.green : Colors.red;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
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
                    camp['name'] ?? 'Unnamed Camp',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                        color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.location_on, camp['address'] ?? 'No address provided'),
            _buildDetailRow(Icons.groups, 'Capacity: ${camp['capacity']} Persons'),
            _buildDetailRow(Icons.phone, camp['tp_no'] ?? 'No contact info'),
            const Divider(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    // Show confirmation dialog
                    bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: const Text('Are you sure you want to delete this rescue camp?'),
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

                    if (confirm == true) {
                      setState(() => _isLoading = true);
                      final success = await _rescueCampService.deleteRescueCamp(camp['id']);
                      if (success) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Camp deleted successfully')),
                          );
                          _fetchCamps(); // Refresh the list
                        }
                      } else {
                        if (mounted) {
                          setState(() => _isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to delete camp')),
                          );
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                  label: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }
}
