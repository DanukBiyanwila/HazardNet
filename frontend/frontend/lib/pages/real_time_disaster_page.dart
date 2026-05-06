import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:frontend/service/weather_service.dart';
import 'package:intl/intl.dart';

class RealTimeDisasterPage extends StatefulWidget {
  const RealTimeDisasterPage({super.key});

  @override
  State<RealTimeDisasterPage> createState() => _RealTimeDisasterPageState();
}

class _RealTimeDisasterPageState extends State<RealTimeDisasterPage> {
  final WeatherService _weatherService = WeatherService();
  String _currentAddress = 'Fetching location...';
  Position? _currentPosition;
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;
  bool _isWeatherLoading = false;
  String? _weatherError;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _weatherError = null;
    });

    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentAddress = 'Location services are disabled.';
          _isLoading = false;
        });
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentAddress = 'Location permissions are denied';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentAddress = 'Location permissions are permanently denied.';
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      
      setState(() {
        _currentPosition = position;
      });

      _getAddressFromLatLng(position);
      _fetchWeather(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        _currentAddress = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    setState(() {
      _isWeatherLoading = true;
      _weatherError = null;
    });

    try {
      final data = await _weatherService.getWeather(lat, lon);
      setState(() {
        _weatherData = data;
        _isWeatherLoading = false;
      });
    } catch (e) {
      setState(() {
        _isWeatherLoading = false;
        _weatherError = e.toString().replaceFirst('Exception: ', '');
      });
      print('Error fetching weather: $e');
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      Placemark place = placemarks[0];

      setState(() {
        _currentAddress = "${place.locality}, ${place.country}";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _currentAddress = 'Lat: ${position.latitude}, Long: ${position.longitude}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real Time Disaster'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationInfo(),
            const SizedBox(height: 16),
            _buildWeatherDashboard(),
            const SizedBox(height: 24),
            _buildRiskStatus(),
            const SizedBox(height: 24),
            _buildNearestDisasters(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDashboard() {
    if (_isWeatherLoading) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.blueAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_weatherError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade900.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.shade900.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
            const SizedBox(height: 10),
            const Text(
              'Weather Unavailable',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 5),
            Text(
              _weatherError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {
                if (_currentPosition != null) {
                  _fetchWeather(_currentPosition!.latitude, _currentPosition!.longitude);
                } else {
                  _getCurrentLocation();
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_weatherData == null) return const SizedBox.shrink();

    final main = _weatherData!['main'];
    final temp = main['temp'];
    final feelsLike = main['feels_like'];
    final humidity = main['humidity'];
    final pressure = main['pressure'];
    final wind = _weatherData!['wind']['speed'];
    final weather = _weatherData!['weather'][0];
    final description = weather['description'];
    final iconCode = weather['icon'];
    final city = _weatherData!['name'];
    final now = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade800,
            Colors.blue.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      now,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Image.network(
                  'https://openweathermap.org/img/wn/$iconCode@2x.png',
                  width: 70,
                  height: 70,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${temp.round()}°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 70,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description.toString().capitalize(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Feels like ${feelsLike.round()}°',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildWeatherMetric(Icons.water_drop_outlined, 'Humidity', '$humidity%'),
                  _buildWeatherMetric(Icons.air, 'Wind', '${wind}m/s'),
                  _buildWeatherMetric(Icons.speed, 'Pressure', '${pressure}hPa'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherMetric(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.blueAccent, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Location',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  _isLoading 
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(strokeWidth: 2)
                      )
                    : Text(_currentAddress),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskStatus() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: You are safe',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Risk Percentage: 5%',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const CircularProgressIndicator(
                        value: 0.05,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                      Text(
                        '5%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNearestDisasters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nearest Disaster Locations',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildDisasterCard(
          disaster: 'Flood',
          location: 'Kaduwela',
          riskLevel: 'High',
          color: Colors.red,
        ),
        _buildDisasterCard(
          disaster: 'Landslide',
          location: 'Ratnapura',
          riskLevel: 'Medium',
          color: Colors.orange,
        ),
        _buildDisasterCard(
          disaster: 'Tsunami',
          location: 'Galle',
          riskLevel: 'Low',
          color: Colors.yellow[700]!,
        ),
      ],
    );
  }

  Widget _buildDisasterCard({
    required String disaster,
    required String location,
    required String riskLevel,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(_getDisasterIcon(disaster), color: color, size: 36),
        title: Text(
          '$disaster in $location',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Risk Level: $riskLevel'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            riskLevel,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getDisasterIcon(String disaster) {
    switch (disaster) {
      case 'Flood':
        return Icons.water_drop;
      case 'Landslide':
        return Icons.landscape;
      case 'Tsunami':
        return Icons.waves;
      default:
        return Icons.warning;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
