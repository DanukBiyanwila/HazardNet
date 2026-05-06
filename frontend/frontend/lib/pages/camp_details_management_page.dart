import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/service/rescue_camp_service.dart';
import 'package:frontend/constants.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

class CampDetailsManagementPage extends StatefulWidget {
  final int? campId;
  final String campName;
  const CampDetailsManagementPage({super.key, required this.campName, this.campId});

  @override
  State<CampDetailsManagementPage> createState() => _CampDetailsManagementPageState();
}

class _CampDetailsManagementPageState extends State<CampDetailsManagementPage> {
  final RescueCampService _rescueCampService = RescueCampService();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _tpNoController = TextEditingController();
  int _currentPeopleCount = 0;
  double? _lat;
  double? _lon;
  XFile? _selectedImage;
  String? _networkImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;
  List<dynamic> _orphanGroups = [];
  bool _isLoadingGroups = true;
  bool _isInitialLoading = true;
  int _capacity = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (widget.campId != null) {
      final campDetails =
          await _rescueCampService.getRescueCampById(widget.campId!);
      if (campDetails != null && mounted) {
        setState(() {
          _addressController.text = campDetails['address'] ?? '';
          _tpNoController.text = campDetails['tp_no'] ?? '';
          _currentPeopleCount = campDetails['current_people_count'] ?? 0;
          _capacity = campDetails['capacity'] ?? 0;
          _networkImageUrl = campDetails['people_image_url'];
          _lat = campDetails['location_lat'];
          _lon = campDetails['location_lon'];
          _isInitialLoading = false;
        });
      }
      _fetchOrphanGroups();
    } else {
      setState(() => _isInitialLoading = false);
    }
  }

  Future<void> _fetchOrphanGroups() async {
    if (widget.campId == null) return;
    setState(() => _isLoadingGroups = true);
    final groups =
        await _rescueCampService.getOrphanGroupsByCampId(widget.campId!);
    if (mounted) {
      setState(() {
        _orphanGroups = groups;
        _isLoadingGroups = false;
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _tpNoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Compresses image to 70% quality
    );
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _isSaving = true;
      });

      try {
        final count = await _rescueCampService.countPeopleFromImage(File(image.path));
        if (mounted) {
          setState(() {
            _currentPeopleCount = count;
            _isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('AI detected $count people in the image')),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('AI failed to process image. Please update manually.')),
          );
        }
      }
    }
  }

  void _incrementPeople() {
    setState(() {
      _currentPeopleCount++;
    });
  }

  void _decrementPeople() {
    if (_currentPeopleCount > 0) {
      setState(() {
        _currentPeopleCount--;
      });
    }
  }

  void _showAddOrphanGroupDialog() {
    final nameController = TextEditingController();
    final countController =
        TextEditingController(text: _currentPeopleCount.toString());
    final latController = TextEditingController(text: _lat?.toString() ?? '');
    final lonController = TextEditingController(text: _lon?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) =>
          StatefulBuilder(builder: (context, setStateInDialog) {
        return AlertDialog(
          title: const Text('Add New Orphan Group'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Group Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: countController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Number of People',
                    hintText: 'Max: $_currentPeopleCount',
                    border: const OutlineInputBorder(),
                    helperText: 'You can only assign up to current camp occupancy',
                  ),
                  onChanged: (value) {
                    int? val = int.tryParse(value);
                    if (val != null && val > _currentPeopleCount) {
                      // Reset to max if they try to increase
                      countController.text = _currentPeopleCount.toString();
                      // Move cursor to end
                      countController.selection = TextSelection.fromPosition(
                          TextPosition(offset: countController.text.length));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Cannot exceed current occupancy ($_currentPeopleCount)')),
                      );
                    }
                  },
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: latController,
                  readOnly: true,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Latitude',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: lonController,
                  readOnly: true,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Longitude',
                    border: OutlineInputBorder(),
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
              onPressed: () async {
                int? count = int.tryParse(countController.text);
                if (nameController.text.isEmpty ||
                    count == null ||
                    widget.campId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                if (count > _currentPeopleCount) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Group members cannot exceed current camp occupancy ($_currentPeopleCount)')),
                  );
                  return;
                }

                final success = await _rescueCampService.createOrphanGroup(
                  name: nameController.text,
                  numOfKids: count,
                  lat: _lat ?? 0.0,
                  lon: _lon ?? 0.0,
                  rescueCampId: widget.campId!,
                );

                if (!context.mounted) return;

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(success
                          ? 'Orphan Group Added Successfully!'
                          : 'Failed to add group')),
                );
                if (success) {
                  _loadInitialData(); // Refresh page data
                }
              },
              child: const Text('ADD GROUP'),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return Scaffold(
        appBar: AppBar(
            title: Text(widget.campName), backgroundColor: Colors.orangeAccent),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.campName),
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPeopleCounter(),
                _buildCampDetailsForm(),
                _buildRescueGroupPhotoSection(),
                _buildSaveButtonSection(), // Move save button here
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Registered Orphan Groups',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                _isLoadingGroups
                    ? const Center(
                        child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ))
                    : _buildOrphanGroupsList(),
                const SizedBox(height: 80), // Space for FAB
              ],
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.orangeAccent),
                    SizedBox(height: 20),
                    Text(
                      'Processing...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _showAddOrphanGroupDialog,
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.group_add),
        label: const Text('Add Orphan Group'),
      ),
    );
  }

  Widget _buildOrphanGroupsList() {
    if (_orphanGroups.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('No orphan groups found')),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _orphanGroups.length,
      itemBuilder: (context, index) {
        final group = _orphanGroups[index];
        DateTime createdAt;
        try {
          createdAt = DateTime.parse(group['created_at']);
        } catch (e) {
          createdAt = DateTime.now();
        }
        final String formattedDate =
            DateFormat('yyyy-MM-dd HH:mm').format(createdAt);

        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
              child: const Icon(Icons.child_care, color: Colors.redAccent),
            ),
            title: Text(group['name'] ?? 'Unnamed Group',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<String>(
                  future: _getAddressFromLatLng(
                      group['location_lat'], group['location_lon']),
                  builder: (context, snapshot) {
                    return Text(
                        'Location: ${snapshot.data ?? "Loading address..."}');
                  },
                ),
                Text('Created: $formattedDate',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            isThreeLine: true,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${group['num_of_kids']} people',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String> _getAddressFromLatLng(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return "${place.street}, ${place.locality}";
      }
    } catch (e) {
      return "$lat, $lon";
    }
    return "$lat, $lon";
  }

  Widget _buildPeopleCounter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withValues(alpha: 0.1),
        border: Border(bottom: BorderSide(color: Colors.orangeAccent.withValues(alpha: 0.3))),
      ),
      child: Column(
        children: [
          const Text(
            'Current People in Camp',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _counterButton(Icons.remove, _decrementPeople, Colors.redAccent),
              const SizedBox(width: 30),
              Text(
                '$_currentPeopleCount',
                style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 30),
              _counterButton(Icons.add, _incrementPeople, Colors.green),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Total Occupancy', style: TextStyle(color: Colors.orangeAccent)),
        ],
      ),
    );
  }

  Widget _buildCampDetailsForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Camp Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Camp Address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _tpNoController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Telephone Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRescueGroupPhotoSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rescue Group Photo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: _selectedImage == null
                ? (_networkImageUrl == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library, size: 50, color: Colors.grey),
                          SizedBox(height: 10),
                          Text('No photo selected',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          '${AppConstants.baseUrl}/uploads/camp/$_networkImageUrl',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.error)),
                        ),
                      ))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      File(_selectedImage!.path),
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _pickImage,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black),
                    )
                  : const Icon(Icons.add_a_photo),
              label: Text(_isSaving ? 'AI processing...' : 'Add Group Photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButtonSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveDetails,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('SAVE DETAILS',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Future<void> _saveDetails() async {
    setState(() {
      _isSaving = true;
    });

    bool success;
    if (widget.campId != null) {
      success = await _rescueCampService.updateRescueCamp(
        id: widget.campId!,
        name: widget.campName,
        lat: _lat ?? 0.0,
        lon: _lon ?? 0.0,
        capacity: _capacity,
        currentPeopleCount: _currentPeopleCount,
        address: _addressController.text,
        phone: _tpNoController.text,
        existingImageUrl: _networkImageUrl,
        imageFile: _selectedImage != null ? File(_selectedImage!.path) : null,
      );
    } else {
      success = await _rescueCampService.createRescueCamp(
        name: widget.campName,
        lat: 6.6496,
        lon: 80.1780,
        capacity: 200,
        address: _addressController.text,
        phone: _tpNoController.text,
        imageFile: _selectedImage != null ? File(_selectedImage!.path) : null,
      );
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(success
                ? 'Camp Details Saved Successfully!'
                : 'Failed to save details')),
      );
    }
  }

  Widget _counterButton(IconData icon, VoidCallback onPressed, Color color) {
    return Material(
      color: color.withValues(alpha: 0.1),
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: color, size: 30),
        onPressed: onPressed,
      ),
    );
  }
}
