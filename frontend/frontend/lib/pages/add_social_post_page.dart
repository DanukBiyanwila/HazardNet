import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:frontend/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AddSocialPostPage extends StatefulWidget {
  const AddSocialPostPage({super.key});

  @override
  State<AddSocialPostPage> createState() => _AddSocialPostPageState();
}

class _AddSocialPostPageState extends State<AddSocialPostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  
  String _selectedHazardType = 'FLOOD';
  final List<String> _hazardTypes = ['LANDSLIDE', 'FLOOD'];
  
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,     // Compress by limiting width
      maxHeight: 1200,    // Compress by limiting height
      imageQuality: 80,   // Compress by reducing JPEG quality
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      
      // Optional: Log size for verification
      final bytes = await _image!.length();
      debugPrint('Compressed social post image size: ${bytes / 1024} KB');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a photo')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get token and userId from secure storage
      final String? token = await _storage.read(key: 'jwt_token');
      final String? userIdStr = await _storage.read(key: 'user_id');
      final int userId = userIdStr != null ? int.parse(userIdStr) : 2;

      if (token == null) {
        throw Exception('Authentication token not found. Please login again.');
      }

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final url = Uri.parse('${AppConstants.baseUrl}/api/media_report/create');
      
      final String uploadTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateTime.now());

      final Map<String, dynamic> postData = {
        "title": _titleController.text,
        "dis": _descriptionController.text,
        "media_url": "", 
        "location_lon": position.longitude,
        "location_lat": position.latitude,
        "upload_time": uploadTime,
        "hazard_type": _selectedHazardType,
        "status": "PENDING",
        "userId": userId
      };

      var request = http.MultipartRequest('POST', url);
      
      // Add Authorization Header
      request.headers.addAll({
        "Authorization": "Bearer $token",
      });
      
      // Add the JSON data as a part
      request.files.add(http.MultipartFile.fromString(
        'report',
        jsonEncode(postData),
        contentType: MediaType('application', 'json'),
      ));

      // Add the image file
      request.files.add(await http.MultipartFile.fromPath(
        'file', 
        _image!.path,
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post created successfully!')),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Failed to create post: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Social Post'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.orangeAccent.withOpacity(0.5)),
                  ),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 50, color: Colors.orangeAccent),
                            SizedBox(height: 10),
                            Text('Tap to upload photo', style: TextStyle(color: Colors.orangeAccent)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedHazardType,
                decoration: const InputDecoration(
                  labelText: 'Hazard Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.warning),
                ),
                items: _hazardTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedHazardType = value);
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Post', style: TextStyle(fontSize: 18, color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add this extension to help with http.MediaType if not already available elsewhere
// In standard http package you might need to import http_parser
extension on http.MultipartFile {
  // Simple helper if needed, but usually we use http_parser
}
