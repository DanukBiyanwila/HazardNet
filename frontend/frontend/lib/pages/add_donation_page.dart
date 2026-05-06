import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/constants.dart';

class AddDonationPage extends StatefulWidget {
  const AddDonationPage({super.key});

  @override
  State<AddDonationPage> createState() => _AddDonationPageState();
}

class _AddDonationPageState extends State<AddDonationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  
  String _selectedItemType = 'food';
  final List<String> _itemTypes = ['food', 'medicine', 'price', 'clothes'];

  Future<void> _submitDonation() async {
    if (!_formKey.currentState!.validate()) return;

    // Get token and userId from secure storage
    final String? token = await _storage.read(key: 'jwt_token');
    final String? userIdStr = await _storage.read(key: 'user_id');
    final int userId = userIdStr != null ? int.parse(userIdStr) : 1;

    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication error. Please login again.')),
        );
      }
      return;
    }

    final url = Uri.parse('${AppConstants.baseUrl}/api/donation/create');
    
    // Format date as YYYY-MM-DDTHH:MM:SS
    String createdAt = DateTime.now().toIso8601String().split('.').first;

    final body = jsonEncode({
      "item_type": _selectedItemType,
      "quantity": int.tryParse(_quantityController.text) ?? 0,
      "status": "PENDING",
      "created_at": createdAt,
      "name": _nameController.text,
      "userId": userId,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Donation added successfully!')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add donation: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Donation'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Item Type',
                  border: OutlineInputBorder(),
                ),
                value: _selectedItemType,
                items: _itemTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type[0].toUpperCase() + type.substring(1)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedItemType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: _selectedItemType == 'price' ? 'LKR Amount' : 'Quantity',
                  hintText: _selectedItemType == 'price' ? 'Enter LKR amount' : 'Enter quantity',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _selectedItemType == 'price' ? 'Please enter an amount' : 'Please enter a quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _submitDonation,
                  child: const Text('Submit Donation'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
