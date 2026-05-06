import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/pages/map_selection_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class NewHomeRegisterPage extends StatefulWidget {
  const NewHomeRegisterPage({super.key});

  @override
  State<NewHomeRegisterPage> createState() => _NewHomeRegisterPageState();
}

class _NewHomeRegisterPageState extends State<NewHomeRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _streetController = TextEditingController();
  final _familyCountController = TextEditingController();
  final _riverDistanceController = TextEditingController();
  final _elevationController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  
  String? _selectedDistrict;
  bool _isLoading = false;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final _storage = const FlutterSecureStorage();

  final List<String> _districts = [
    'Ampara', 'Anuradhapura', 'Badulla', 'Batticaloa', 'Colombo',
    'Galle', 'Gampaha', 'Hambantota', 'Jaffna', 'Kalutara',
    'Kandy', 'Kegalle', 'Kilinochchi', 'Kurunegala', 'Mannar',
    'Matale', 'Matara', 'Moneragala', 'Mullaitivu', 'Nuwara Eliya',
    'Polonnaruwa', 'Puttalam', 'Ratnapura', 'Trincomalee', 'Vavuniya'
  ];

  @override
  void dispose() {
    _streetController.dispose();
    _familyCountController.dispose();
    _riverDistanceController.dispose();
    _elevationController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080, // Compressing to 1080p max width
      maxHeight: 1080, // Compressing to 1080p max height
      imageQuality: 80, // Compressing quality to 80%
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get token and userId from secure storage
      final String? token = await _storage.read(key: 'jwt_token');
      final String? userIdStr = await _storage.read(key: 'user_id');
      final int userId = userIdStr != null ? int.parse(userIdStr) : 1;

      if (token == null) {
        _showSnackBar('Authentication token not found. Please login again.');
        return;
      }

      final url = Uri.parse('${AppConstants.baseUrl}/api/home/create');
      
      // Combine Street and District for address
      final String fullAddress = '${_streetController.text}, $_selectedDistrict';
      
      // Current date in YYYY-MM-DD HH:mm:ss format
      final String createdAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      final Map<String, dynamic> homeData = {
        "address": fullAddress,
        "location_lat": double.parse(_latitudeController.text),
        "location_lon": double.parse(_longitudeController.text),
        "family_count": int.parse(_familyCountController.text),
        "near_river_km": double.parse(_riverDistanceController.text) / 1000.0, // Converting meters to km as per API requirement
        "elevation": double.parse(_elevationController.text),
        "created_at": createdAt,
        "imageUrl": "", // Backend will update this with the saved file name
        "userIds": [userId] // Using the retrieved userId
      };

      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        "Authorization": "Bearer $token",
      });

      // Add home data as a JSON part
      request.files.add(http.MultipartFile.fromString(
        'home',
        jsonEncode(homeData),
        contentType: http.MediaType('application', 'json'),
      ));

      // Add image file if selected
      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image!.path,
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('Home registered successfully!');
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        _showSnackBar('Failed to register home: ${response.body}');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickLocation() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapSelectionPage()),
    );

    if (result != null) {
      if (!mounted) return;
      setState(() {
        _latitudeController.text = result.latitude.toString();
        _longitudeController.text = result.longitude.toString();
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Location Selected'),
          content: Text(
            'Latitude: ${result.latitude}\nLongitude: ${result.longitude}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register New Home'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Home Details',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                
                TextFormField(
                  controller: _streetController,
                  decoration: const InputDecoration(
                    labelText: 'Street Address',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter street' : null,
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  value: _selectedDistrict,
                  decoration: const InputDecoration(
                    labelText: 'District',
                    prefixIcon: Icon(Icons.map),
                    border: OutlineInputBorder(),
                  ),
                  items: _districts.map((String district) {
                    return DropdownMenuItem<String>(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedDistrict = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Please select a district' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latitudeController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Latitude',
                          prefixIcon: Icon(Icons.north),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Pick location' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _longitudeController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Longitude',
                          prefixIcon: Icon(Icons.east),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Pick location' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _pickLocation,
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Select Home Location on Map'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _familyCountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Family Count',
                    prefixIcon: Icon(Icons.people),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter family count' : null,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _riverDistanceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nearest River Distance (meters)',
                    prefixIcon: Icon(Icons.waves),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter distance' : null,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _elevationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Elevation (meters above sea level)',
                    prefixIcon: Icon(Icons.terrain),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter elevation' : null,
                ),
                const SizedBox(height: 24),
                
                const Text(
                  'Home Image',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _image!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Tap to select home image', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Home Details', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
