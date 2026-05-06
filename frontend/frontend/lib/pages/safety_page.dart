import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:frontend/pages/home_list_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:frontend/service/weather_service.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/constants.dart';

class SafetyPage extends StatefulWidget {
  const SafetyPage({super.key});

  @override
  State<SafetyPage> createState() => _SafetyPageState();
}

class _SafetyPageState extends State<SafetyPage> {
  final WeatherService _weatherService = WeatherService();
  final _storage = const FlutterSecureStorage();

  String _currentAddress = 'Fetching location...';
  Map<String, dynamic>? _weatherData;
  
  bool _isLoading = true;
  bool _isHazardLoading = false;
  String? _hazardError;

  // Prediction Data
  Map<String, dynamic>? _landslidePredictionData;
  Map<String, dynamic>? _floodPredictionData;
  double _soilMoisture = 0.0;
  double _rainfall = 0.0;
  double _elevation = 0.0;
  double _slopePercent = 0.0;
  double _slopeDegrees = 0.0;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _landslidePredictionData = null;
      _floodPredictionData = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentAddress = 'Location services are disabled.';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
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

      Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      
      _getAddressFromLatLng(position);
      _fetchWeather(position.latitude, position.longitude);
      _fetchHazardPredictions(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        _currentAddress = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    try {
      final data = await _weatherService.getWeather(lat, lon);
      setState(() {
        _weatherData = data;
      });
    } catch (e) {
      debugPrint('Weather Error: $e');
    }
  }

  Future<void> _fetchHazardPredictions(double lat, double lon) async {
    setState(() {
      _isHazardLoading = true;
      _hazardError = null;
    });

    try {
      final String? token = await _storage.read(key: 'jwt_token');
      
      // 1. Fetch Weather & Soil Moisture from Open-Meteo
      final weatherUrl = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&hourly=rain,soil_moisture_0_to_7cm&forecast_days=1');
      final weatherResponse = await http.get(weatherUrl);

      if (weatherResponse.statusCode == 200) {
        final data = jsonDecode(weatherResponse.body);
        final hourly = data['hourly'];
        if (hourly != null) {
          final List? rainList = hourly['rain'];
          final List? soilList = hourly['soil_moisture_0_to_7cm'];
          if (rainList != null && rainList.isNotEmpty) _rainfall = (rainList[0] as num?)?.toDouble() ?? 0.0;
          if (soilList != null && soilList.isNotEmpty) _soilMoisture = (soilList[0] as num?)?.toDouble() ?? 0.0;
        }
      }

      // 2. Fetch Elevation and calculate Slope
      const String googleApiKey = "AIzaSyCs1dEUOfpICKD4prF89cSZs1tjOceC190";
      final String locations = "$lat,$lon|${lat + 0.001},$lon";
      final elevationUrl = Uri.parse(
          'https://maps.googleapis.com/maps/api/elevation/json?locations=$locations&key=$googleApiKey');
      
      final elevationResponse = await http.get(elevationUrl);
      if (elevationResponse.statusCode == 200) {
        final data = jsonDecode(elevationResponse.body);
        final List? results = data['results'];
        if (results != null && results.length >= 2) {
          final double e1 = (results[0]['elevation'] as num?)?.toDouble() ?? 0.0;
          final double e2 = (results[1]['elevation'] as num?)?.toDouble() ?? 0.0;
          _elevation = e1;
          final double rise = (e2 - e1).abs();
          const double run = 111.0;
          _slopePercent = (rise / run) * 100;
          _slopeDegrees = atan(rise / run) * (180 / pi);
        }
      }

      // 3. Call Hazard Prediction APIs
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      
      final commonBody = {
        "rainfall_mm": _rainfall.toStringAsFixed(1),
        "river_level": "5",
        "soil_moisture": (_soilMoisture * 100).toStringAsFixed(0),
        "location_lat": lat,
        "location_lon": lon,
      };

      final landslideResponse = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/hazard_prediction/create/landslide/auto'),
        headers: headers,
        body: jsonEncode(commonBody),
      );

      final floodResponse = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/hazard_prediction/create/flood/auto'),
        headers: headers,
        body: jsonEncode(commonBody),
      );

      if (landslideResponse.statusCode == 200 || landslideResponse.statusCode == 201) {
        _landslidePredictionData = jsonDecode(landslideResponse.body);
      }
      if (floodResponse.statusCode == 200 || floodResponse.statusCode == 201) {
        _floodPredictionData = jsonDecode(floodResponse.body);
      }

      setState(() {
        _isHazardLoading = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hazardError = 'Hazard Error: $e';
        _isHazardLoading = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress = "${place.locality}, ${place.country}";
      });
    } catch (e) {
      setState(() {
        _currentAddress = 'Lat: ${position.latitude.toStringAsFixed(4)}, Lon: ${position.longitude.toStringAsFixed(4)}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double landslideValue = 0.0;
    String landslideRisk = 'LOW';
    if (_landslidePredictionData != null) {
      landslideValue = double.tryParse(_landslidePredictionData!['confidence_score'].toString()) ?? 0.0;
      landslideRisk = _landslidePredictionData!['predicted_risk_level'] ?? 'LOW';
    }

    double floodValue = 0.0;
    String floodRisk = 'LOW';
    if (_floodPredictionData != null) {
      floodValue = double.tryParse(_floodPredictionData!['confidence_score'].toString()) ?? 0.0;
      floodRisk = _floodPredictionData!['predicted_risk_level'] ?? 'LOW';
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.black),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _getCurrentLocation,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      title: const Text('Disaster Safety', style: TextStyle(color: Colors.white)),
                      centerTitle: true,
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          onPressed: _getCurrentLocation,
                        ),
                      ],
                    ),

                    _buildWeatherSection(),

                    const SizedBox(height: 20),

                    const Text(
                      'Real-time Safety Level',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                    ),

                    const SizedBox(height: 10),
                    Text(
                      'Monitoring your current location',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
                    ),

                    const SizedBox(height: 20),

                    if (_isHazardLoading)
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      )
                    else if (_hazardError != null)
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(_hazardError!, style: const TextStyle(color: Colors.redAccent)),
                      )
                    else ...[
                      _riskCard(
                        title: 'Flood Risk',
                        value: floodValue,
                        riskLevel: floodRisk,
                      ),
                      _riskCard(
                        title: 'Landslide Risk',
                        value: landslideValue,
                        riskLevel: landslideRisk,
                      ),
                    ],

                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeListPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('View My Home Safety'),
                    ),

                    const SizedBox(height: 40),
                    
                    if (!_isHazardLoading && (_landslidePredictionData != null || _floodPredictionData != null)) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'AI Prediction Details',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildFloodPredictionTable(),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildLandslidePredictionTable(),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherSection() {
    if (_isLoading) {
      return Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_weatherData == null) return const SizedBox.shrink();

    final main = _weatherData!['main'];
    final temp = main['temp'];
    final weather = _weatherData!['weather'][0];
    final description = weather['description'];
    final iconCode = weather['icon'];

    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900.withValues(alpha: 0.8), Colors.blue.shade600.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white, size: 18),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        _currentAddress,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                DateFormat('MMM d, h:mm a').format(DateTime.now()),
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
              ),
            ],
          ),
          const Divider(color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image.network(
                'https://openweathermap.org/img/wn/$iconCode@2x.png',
                width: 50,
                height: 50,
              ),
              Text(
                '${temp.round()}°C',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                description.toString().toUpperCase(),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _riskCard({required String title, required double value, required String riskLevel}) {
    Color color = _getRiskColor(riskLevel);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              width: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: value,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${(value * 100).toInt()}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Text(riskLevel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloodPredictionTable() {
    final riskLevel = _floodPredictionData?['predicted_risk_level'] ?? 'LOW';
    final rain = _floodPredictionData?['rainfall_mm'] ?? _rainfall.toStringAsFixed(1);
    final river = _floodPredictionData?['river_level'] ?? '5';
    final soil = _floodPredictionData?['soil_moisture'] ?? (_soilMoisture * 100).toStringAsFixed(0);

    return _buildTableContainer(
      title: 'Flood Analysis',
      icon: Icons.water_drop,
      color: Colors.blueAccent,
      rows: [
        ['Rainfall (mm)', rain, (double.tryParse(rain.toString()) ?? 0) > 50 ? 'High' : 'Low'],
        ['River Level (m)', river, (double.tryParse(river.toString()) ?? 0) > 4 ? 'High' : 'Normal'],
        ['Soil Moisture', '$soil%', (double.tryParse(soil.toString()) ?? 0) > 70 ? 'High' : 'Medium'],
        ['Risk Level', riskLevel, riskLevel],
      ],
    );
  }

  Widget _buildLandslidePredictionTable() {
    final riskLevel = _landslidePredictionData?['predicted_risk_level'] ?? 'LOW';
    final rain = _landslidePredictionData?['rainfall_mm'] ?? _rainfall.toStringAsFixed(1);
    final soil = _landslidePredictionData?['soil_moisture'] ?? (_soilMoisture * 100).toStringAsFixed(0);

    return _buildTableContainer(
      title: 'Landslide Analysis',
      icon: Icons.landscape,
      color: Colors.orangeAccent,
      rows: [
        ['Soil Moisture', '$soil%', (double.tryParse(soil) ?? 0) > 70 ? 'High' : 'Medium'],
        ['Rainfall', '${rain}mm', (double.tryParse(rain) ?? 0) > 100 ? 'High' : 'Low'],
        ['Slope Percent', '${_slopePercent.toStringAsFixed(1)}%', _slopePercent > 15 ? 'High' : 'Low'],
        ['Slope Degrees', '${_slopeDegrees.toStringAsFixed(1)}°', _slopeDegrees > 10 ? 'High' : 'Low'],
        ['Elevation', '${_elevation.toStringAsFixed(1)}m', 'Info'],
        ['Risk Level', riskLevel, riskLevel],
      ],
    );
  }

  Widget _buildTableContainer({
    required String title,
    required IconData icon,
    required Color color,
    required List<List<String>> rows,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 4,
          color: Colors.grey.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white12, width: 1),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            child: DataTable(
              columnSpacing: 15,
              headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              dataTextStyle: const TextStyle(color: Colors.white70),
              border: TableBorder.all(color: Colors.white12, width: 0.5, borderRadius: BorderRadius.circular(12)),
              columns: const [
                DataColumn(label: Text('Parameter')),
                DataColumn(label: Text('Value')),
                DataColumn(label: Text('Risk')),
              ],
              rows: rows.map((rowData) {
                return DataRow(cells: [
                  DataCell(Text(rowData[0])),
                  DataCell(Text(rowData[1])),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRiskColor(rowData[2]).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        rowData[2],
                        style: TextStyle(color: _getRiskColor(rowData[2]), fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'critical':
      case 'high risk':
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
      case 'safe':
      case 'normal':
        return Colors.green;
      case 'info':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
