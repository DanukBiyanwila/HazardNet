import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';

class HiddenCalculator extends StatefulWidget {
  const HiddenCalculator({super.key});

  @override
  State<HiddenCalculator> createState() => _HiddenCalculatorState();
}

class _HiddenCalculatorState extends State<HiddenCalculator> {
  String _display = '0';
  double? _firstOperand;
  String? _operator;
  bool _shouldResetDisplay = false;

  Future<void> _handleEmergency(String serviceType) async {
    try {
      // Get current location
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition();

      // Fetch emergency services
      final response = await http.get(Uri.parse('${AppConstants.baseUrl}/api/emergency_service/'));
      
      if (response.statusCode == 200) {
        List<dynamic> services = json.decode(response.body);
        
        var filteredServices = services.where((s) => s['service_type'] == serviceType).toList();
        
        if (filteredServices.isEmpty) return;

        dynamic nearestService;
        double minDistance = double.infinity;

        for (var service in filteredServices) {
          double distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            service['location_lat'],
            service['location_lon'],
          );

          if (distance < minDistance) {
            minDistance = distance;
            nearestService = service;
          }
        }

        if (nearestService != null) {
          final Uri launchUri = Uri(
            scheme: 'tel',
            path: nearestService['phone'],
          );
          await launchUrl(launchUri);
        }
      }
    } catch (e) {
      debugPrint('Error handling emergency: $e');
    }
  }

  void _onPressed(String text) {
    setState(() {
      if (text == 'C') {
        _display = '0';
        _firstOperand = null;
        _operator = null;
      } else if (text == '+' || text == '-' || text == '*' || text == '/') {
        _firstOperand = double.tryParse(_display);
        _operator = text;
        _shouldResetDisplay = true;
      } else if (text == '=') {
        if (_firstOperand != null && _operator != null) {
          double secondOperand = double.tryParse(_display) ?? 0;
          double result = 0;
          switch (_operator) {
            case '+': result = _firstOperand! + secondOperand; break;
            case '-': result = _firstOperand! - secondOperand; break;
            case '*': result = _firstOperand! * secondOperand; break;
            case '/': result = secondOperand != 0 ? _firstOperand! / secondOperand : 0; break;
          }
          _display = result.toString().replaceAll(RegExp(r'\.0$'), '');
          _firstOperand = null;
          _operator = null;
        }
      } else {
        if (_display == '0' || _shouldResetDisplay) {
          _display = text;
          _shouldResetDisplay = false;
        } else {
          _display += text;
        }
      }

      // Check for hidden codes
      if (_display == '111') {
        _handleEmergency('POLICE');
        _display = '0'; // Reset display after action
      } else if (_display == '222') {
        _handleEmergency('HOSPITAL');
        _display = '0'; // Reset display after action
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculator')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24),
              child: Text(
                _display,
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        ['7', '8', '9', '/'],
        ['4', '5', '6', '*'],
        ['1', '2', '3', '-'],
        ['C', '0', '=', '+'],
      ].map((row) {
        return Row(
          children: row.map((text) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () => _onPressed(text),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: (text == '=' || text == 'C' || '+-*/'.contains(text)) 
                        ? Colors.orangeAccent 
                        : Colors.grey[800],
                  ),
                  child: Text(text, style: const TextStyle(fontSize: 24)),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
