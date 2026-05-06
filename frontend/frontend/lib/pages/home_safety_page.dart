import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/constants.dart';

class HomeSafetyPage extends StatefulWidget {
  final Map<String, dynamic> home;
  const HomeSafetyPage({super.key, required this.home});

  @override
  State<HomeSafetyPage> createState() => _HomeSafetyPageState();
}

class _HomeSafetyPageState extends State<HomeSafetyPage> {
  final _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  String? _error;
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
    _fetchSafetyData();
  }

  Future<void> _fetchSafetyData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final String? token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        setState(() {
          _error = 'User not authenticated. Please login again.';
          _isLoading = false;
        });
        return;
      }

      final double lat = (widget.home['location_lat'] as num?)?.toDouble() ?? 0.0;
      final double lon = (widget.home['location_lon'] as num?)?.toDouble() ?? 0.0;

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
          
          if (rainList != null && rainList.isNotEmpty) {
            _rainfall = (rainList[0] as num?)?.toDouble() ?? 0.0;
          }
          if (soilList != null && soilList.isNotEmpty) {
            _soilMoisture = (soilList[0] as num?)?.toDouble() ?? 0.0;
          }
        }
      }

      // 2. Fetch Elevation from Google and calculate Slope
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
        } else if (results != null && results.isNotEmpty) {
          _elevation = (results[0]['elevation'] as num?)?.toDouble() ?? 0.0;
        }
      }

      // 3. Call Landslide Hazard Prediction API
      final landslideUrl = Uri.parse('${AppConstants.baseUrl}/api/hazard_prediction/create/landslide/auto');
      final landslideBody = {
        "rainfall_mm": _rainfall.toStringAsFixed(1),
        "location_lat": lat,
        "location_lon": lon,
        "river_level": "5",
        "soil_moisture": (_soilMoisture * 100).toStringAsFixed(0),
      };

      final landslideResponse = await http.post(
        landslideUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(landslideBody),
      );

      // 4. Call Flood Hazard Prediction API
      final floodUrl = Uri.parse('${AppConstants.baseUrl}/api/hazard_prediction/create/flood/auto');
      final floodBody = {
        "rainfall_mm": _rainfall.toStringAsFixed(1),
        "river_level": "5",
        "soil_moisture": (_soilMoisture * 100).toStringAsFixed(0),
        "location_lat": lat,
        "location_lon": lon,
      };

      final floodResponse = await http.post(
        floodUrl,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(floodBody),
      );

      if (landslideResponse.statusCode == 200 || landslideResponse.statusCode == 201) {
        _landslidePredictionData = jsonDecode(landslideResponse.body);
      }

      if (floodResponse.statusCode == 200 || floodResponse.statusCode == 201) {
        _floodPredictionData = jsonDecode(floodResponse.body);
      }

      setState(() {
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _error = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String address = widget.home['address'] ?? 'Home Details';
    final String? imageUrl = widget.home['imageUrl'] != null && widget.home['imageUrl'] != ""
        ? '${AppConstants.baseUrl}/uploads/homes/${widget.home['imageUrl']}'
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(address),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSafetyData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _fetchSafetyData,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHomeImage(imageUrl),
                          const SizedBox(height: 24),
                          _buildDisasterAlert(),
                          const SizedBox(height: 24),
                          _buildRiskPercentages(),
                          const SizedBox(height: 32),
                          const Text(
                            'AI Prediction Details',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _buildFloodPredictionTable(),
                          const SizedBox(height: 24),
                          _buildLandslidePredictionTable(),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildHomeImage(String? imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        imageUrl ?? 'https://picsum.photos/seed/home/800/600',
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey[300],
            child: const Icon(Icons.home_work, size: 64, color: Colors.grey),
          );
        },
      ),
    );
  }

  Widget _buildDisasterAlert() {
    final landslideRisk = _landslidePredictionData?['predicted_risk_level'] ?? 'LOW';
    final floodRisk = _floodPredictionData?['predicted_risk_level'] ?? 'LOW';
    
    final bool isHighRisk = landslideRisk == 'HIGH' || landslideRisk == 'CRITICAL' || 
                            floodRisk == 'HIGH' || floodRisk == 'CRITICAL';

    String message = 'Both risk levels are LOW. Your area is currently safe.';
    if (isHighRisk) {
      message = 'High risk detected! Landslide: $landslideRisk, Flood: $floodRisk. Please take precautions.';
    }

    return Card(
      color: isHighRisk ? Colors.red.shade900 : Colors.green.shade800,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              isHighRisk ? Icons.warning_amber_rounded : Icons.check_circle_outline,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskPercentages() {
    double landslideValue = 0.0;
    String landslideRisk = 'LOW';
    if (_landslidePredictionData != null) {
      final score = _landslidePredictionData!['confidence_score'];
      landslideValue = double.tryParse(score.toString()) ?? 0.0;
      landslideRisk = _landslidePredictionData!['predicted_risk_level'] ?? 'LOW';
    }

    double floodValue = 0.0;
    String floodRisk = 'LOW';
    if (_floodPredictionData != null) {
      final score = _floodPredictionData!['confidence_score'];
      floodValue = double.tryParse(score.toString()) ?? 0.0;
      floodRisk = _floodPredictionData!['predicted_risk_level'] ?? 'LOW';
    }

    return Row(
      children: [
        Expanded(
          child: _riskCard(
            title: 'Landslide Risk', 
            value: landslideValue, 
            riskLevel: landslideRisk,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _riskCard(
            title: 'Flood Risk', 
            value: floodValue, 
            riskLevel: floodRisk,
          ),
        ),
      ],
    );
  }

  Widget _riskCard({required String title, required double value, required String riskLevel}) {
    Color color = _getRiskColor(riskLevel);
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 100,
              width: 100,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: value,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(value * 100).toInt()}%',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          riskLevel,
                          style: TextStyle(
                            fontSize: 10, 
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
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
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            child: DataTable(
              columnSpacing: 20,
              columns: const [
                DataColumn(label: Text('Parameter', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Value', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Risk', style: TextStyle(fontWeight: FontWeight.bold))),
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
                        style: TextStyle(
                          color: _getRiskColor(rowData[2]),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
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
