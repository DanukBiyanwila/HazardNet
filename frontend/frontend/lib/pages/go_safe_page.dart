import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:frontend/constants.dart';

class GoSafePage extends StatefulWidget {
  final LatLng? initialOrigin;
  final LatLng? initialDestination;
  final String? destinationName;

  const GoSafePage({
    super.key,
    this.initialOrigin,
    this.initialDestination,
    this.destinationName,
  });

  @override
  State<GoSafePage> createState() => _GoSafePageState();
}

class _GoSafePageState extends State<GoSafePage> {
  final _storage = const FlutterSecureStorage();
  final String _googleApiKey = "AIzaSyCs1dEUOfpICKD4prF89cSZs1tjOceC190";
  
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(6.93548, 79.84868); // Default Colombo
  
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  TextEditingController? _focusedController;
  
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  final Set<Polyline> _polylines = {};
  bool _isLoading = true;
  bool _directionsFetched = false;
  bool _isNavigating = false;
  bool _isRouteSafe = false;
  
  int _currentModeIndex = 0;
  final List<String> _travelModes = ['bicycling', 'driving', 'walking'];
  
  StreamSubscription<Position>? _positionSubscription;
  
  late BitmapDescriptor _floodIcon;
  late BitmapDescriptor _landslideIcon;

  void _handleMapTap(LatLng position) async {
    if (_isNavigating) return;
    
    // 1. Add markers immediately for "live" feel
    setState(() {
      if (_focusedController == _originController) {
        _markers.removeWhere((m) => m.markerId.value == 'origin');
        _markers.add(Marker(
          markerId: const MarkerId('origin'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Origin'),
        ));
      } else {
        _markers.removeWhere((m) => m.markerId.value == 'destination');
        _markers.add(Marker(
          markerId: const MarkerId('destination'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Destination'),
        ));
      }
    });

    // 2. Perform reverse geocoding in background
    String address = "${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}";
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        address = [place.name, place.subLocality, place.locality]
            .where((e) => e != null && e.isNotEmpty)
            .join(", ");
      }
    } catch (e) {
      debugPrint('Reverse Geocoding Error: $e');
    }

    setState(() {
      (_focusedController ?? _destinationController).text = address;
    });
    
    // 3. Auto-trigger directions if both fields are likely filled
    if (_originController.text.isNotEmpty && _destinationController.text.isNotEmpty) {
      _getDirections();
    }
  }

  void _clearAll() {
    setState(() {
      _originController.clear();
      _destinationController.clear();
      _polylines.clear();
      _markers.removeWhere((m) => m.markerId.value == 'origin' || m.markerId.value == 'destination');
      _directionsFetched = false;
      _isRouteSafe = false;
      _currentModeIndex = 0;
      _focusedController = _destinationController;
    });
    _getCurrentLocation(); // Refill origin with real location
  }

  @override
  void initState() {
    super.initState();
    _focusedController = _destinationController; // Default focus to destination
    _initData();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    await _loadCustomIcons();
    await _fetchHazardAreas();

    if (widget.initialOrigin != null) {
      setState(() {
        _currentPosition = widget.initialOrigin!;
        _originController.text = "My Location";
        _markers.add(Marker(
          markerId: const MarkerId('origin'),
          position: _currentPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'My Location'),
        ));
      });
    } else {
      await _getCurrentLocation();
    }

    if (widget.initialDestination != null) {
      setState(() {
        _destinationController.text = widget.destinationName ?? 
            "${widget.initialDestination!.latitude.toStringAsFixed(6)}, ${widget.initialDestination!.longitude.toStringAsFixed(6)}";
        _markers.add(Marker(
          markerId: const MarkerId('destination'),
          position: widget.initialDestination!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: widget.destinationName ?? 'Destination'),
        ));
      });
      
      // Auto-trigger directions after a short delay to ensure everything is ready
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _getDirections();
      });
    }
  }

  Future<void> _loadCustomIcons() async {
    _floodIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(40, 40)),
      'assets/images/flood.png',
    );
    _landslideIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(40, 40)),
      'assets/images/landslide.png',
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      String address = "My Location";
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        address = [place.name, place.subLocality, place.locality]
            .where((e) => e != null && e.isNotEmpty)
            .join(", ");
      }

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _originController.text = address;
        // Update user marker if it exists
        _markers.add(Marker(
          markerId: const MarkerId('origin'),
          position: _currentPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'My Location'),
        ));
      });
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition, 14));
    } catch (e) {
      debugPrint('Location Error: $e');
    }
  }

  void _startNavigation() {
    setState(() {
      _isNavigating = true;
    });

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      LatLng newPos = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentPosition = newPos;
      });
      
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: newPos,
            zoom: 18,
            tilt: 45,
            bearing: position.heading,
          ),
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Navigation started. Always stay safe!")),
    );
  }

  void _stopNavigation() {
    _positionSubscription?.cancel();
    setState(() {
      _isNavigating = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Navigation stopped.")),
    );
  }

  Future<void> _fetchHazardAreas() async {
    setState(() => _isLoading = true);
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      final url = Uri.parse('${AppConstants.baseUrl}/api/hazard_area/');
      final response = await http.get(
        url,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _processHazardData(data);
      }
    } catch (e) {
      debugPrint('Fetch Hazards Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _processHazardData(List<dynamic> data) {
    Set<Marker> newMarkers = {};
    Set<Circle> newCircles = {};

    for (var area in data) {
      final double lat = (area['location_lat'] as num?)?.toDouble() ?? 0.0;
      final double lon = (area['location_lon'] as num?)?.toDouble() ?? 0.0;
      final String name = area['name'] ?? 'Hazard Area';
      final String severity = area['severity_level'] ?? 'LOW';
      final double radius = double.tryParse(area['radius_meters']?.toString() ?? '0') ?? 0.0;

      bool isFlood = name.toUpperCase().contains('FLOOD');
      bool isLandslide = name.toUpperCase().contains('LANDSLIDE');

      BitmapDescriptor icon = BitmapDescriptor.defaultMarker;
      Color circleColor = Colors.blue.withValues(alpha: 0.3);

      if (isFlood) {
        icon = _floodIcon;
        circleColor = Colors.blue.withValues(alpha: 0.3);
      } else if (isLandslide) {
        icon = _landslideIcon;
        circleColor = Colors.orange.withValues(alpha: 0.3);
      }

      if (severity == 'HIGH') {
        circleColor = Colors.red.withValues(alpha: 0.4);
      }

      newMarkers.add(
        Marker(
          markerId: MarkerId('hazard_${area['id']}'),
          position: LatLng(lat, lon),
          icon: icon,
          infoWindow: InfoWindow(title: name, snippet: 'Severity: $severity'),
        ),
      );

      if (radius > 0) {
        newCircles.add(
          Circle(
            circleId: CircleId('circle_${area['id']}'),
            center: LatLng(lat, lon),
            radius: radius,
            fillColor: circleColor,
            strokeWidth: 1,
            strokeColor: circleColor.withValues(alpha: 0.6),
          ),
        );
      }
    }

    setState(() {
      _markers.addAll(newMarkers);
      _circles.addAll(newCircles);
    });
  }

  Future<String?> _saveRouteRequest(LatLng origin, LatLng destination) async {
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      final String? userIdStr = await _storage.read(key: 'user_id');
      final int userId = userIdStr != null ? int.parse(userIdStr) : 1;

      if (token == null) return null;

      final url = Uri.parse('${AppConstants.baseUrl}/api/route_request/create');
      String requestedTime = DateTime.now().toIso8601String().split('.').first;

      final body = jsonEncode({
        "start_lat": origin.latitude,
        "start_lon": origin.longitude,
        "end_lat": destination.latitude,
        "end_lon": destination.longitude,
        "requested_time": requestedTime,
        "status": "PENDING",
        "userId": userId,
      });

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['status'];
      }
    } catch (e) {
      debugPrint('Error saving route request: $e');
    }
    return null;
  }

  void _showSafetyDialog(String status, LatLng origin, LatLng dest) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          status == 'safe' ? "Route Safe" : "Route Alert",
          style: TextStyle(color: status == 'safe' ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(
          status == 'safe' 
            ? "Your route is safe now. Safe ride!" 
            : "This route is not safe. Please change route."
        ),
        actions: [
          if (status != 'safe')
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (status != 'safe') {
                _changeRoute();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'safe' ? Colors.green : Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(status == 'safe' ? "OK" : "Change Route"),
          ),
        ],
      ),
    );
  }

  void _showManualNavHint() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("No Safe Routes Found"),
        content: const Text("All standard routes appear to be affected by hazards. Please tap a safe location on the map to find a clear path manually."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _changeRoute() async {
    setState(() {
      _isLoading = true;
      _polylines.clear();
      _isRouteSafe = false;
      _currentModeIndex = (_currentModeIndex + 1) % _travelModes.length;
    });

    try {
      LatLng originLatLng;
      LatLng destLatLng;

      if (_originController.text == "My Location" || _originController.text.isEmpty) {
        originLatLng = _currentPosition;
      } else {
        String originText = _originController.text;
        if (!originText.toLowerCase().contains("sri lanka")) originText += ", Sri Lanka";
        List<Location> locations = await locationFromAddress(originText);
        originLatLng = LatLng(locations.first.latitude, locations.first.longitude);
      }

      String destText = _destinationController.text;
      if (destText.isEmpty) return;
      if (!destText.toLowerCase().contains("sri lanka")) destText += ", Sri Lanka";
      List<Location> destLocations = await locationFromAddress(destText);
      destLatLng = LatLng(destLocations.first.latitude, destLocations.first.longitude);

      String mode = _travelModes[_currentModeIndex];
      bool success = await _fetchAndDrawRoute(originLatLng, destLatLng, mode);
      
      if (success) {
        if (_currentModeIndex == 0) {
          // If we've cycled through all modes and back to the first one
          _showManualNavHint();
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Alternative route ($mode) shown. Click GET DIRECTIONS to verify safety.")),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error changing route: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getDirections() async {
    if (_originController.text.isEmpty || _destinationController.text.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _directionsFetched = false;
      _polylines.clear();
      _isRouteSafe = false;
    });

    try {
      LatLng originLatLng;
      String originText = _originController.text;
      String destText = _destinationController.text;

      if (originText != "My Location" && !originText.toLowerCase().contains("sri lanka")) {
        originText += ", Sri Lanka";
      }
      if (!destText.toLowerCase().contains("sri lanka")) {
        destText += ", Sri Lanka";
      }

      if (_originController.text == "My Location") {
        originLatLng = _currentPosition;
      } else {
        List<Location> locations = await locationFromAddress(originText);
        originLatLng = LatLng(locations.first.latitude, locations.first.longitude);
      }

      List<Location> destLocations = await locationFromAddress(destText);
      LatLng destLatLng = LatLng(destLocations.first.latitude, destLocations.first.longitude);

      // 1. Draw route immediately for "live" feel
      await _fetchAndDrawRoute(originLatLng, destLatLng, _travelModes[_currentModeIndex]);
      setState(() => _directionsFetched = true);

      // 2. Then check safety status from backend
      final String? status = await _saveRouteRequest(originLatLng, destLatLng);
      
      if (status != null) {
        _showSafetyDialog(status, originLatLng, destLatLng);
        setState(() {
          _isRouteSafe = (status == 'safe');
        });
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _fetchAndDrawRoute(LatLng origin, LatLng destination, String mode) async {
    final String url = 
        "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=$mode&key=$_googleApiKey";

    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        final String points = data['routes'][0]['overview_polyline']['points'];
        _updatePolyline(points);
        
        setState(() {
          _markers.add(Marker(
            markerId: const MarkerId('origin'),
            position: origin,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: const InfoWindow(title: 'Origin'),
          ));
          _markers.add(Marker(
            markerId: const MarkerId('destination'),
            position: destination,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: const InfoWindow(title: 'Destination'),
          ));
        });

        _fitBounds(origin, destination);
        return true;
      }
    }
    return false;
  }

  void _updatePolyline(String encodedPoints) {
    List<LatLng> points = _decodePolyline(encodedPoints);
    setState(() {
      _polylines.add(Polyline(
        polylineId: PolylineId('route_${DateTime.now().millisecondsSinceEpoch}'),
        points: points,
        color: Colors.blue,
        width: 5,
      ));
    });
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  void _fitBounds(LatLng p1, LatLng p2) {
    double minLat = min(p1.latitude, p2.latitude);
    double maxLat = max(p1.latitude, p2.latitude);
    double minLng = min(p1.longitude, p2.longitude);
    double maxLng = max(p1.longitude, p2.longitude);

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Go Safe Navigation'),
        backgroundColor: Colors.black.withValues(alpha: 0.7),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 12),
            onMapCreated: (controller) => _mapController = controller,
            markers: _markers,
            circles: _circles,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            onTap: _handleMapTap,
          ),
          
          SafeArea(
            child: Column(
              children: [
                if (!_isNavigating) _buildSearchCard(),
                if (_isNavigating) _buildNavigationOverlay(),
              ],
            ),
          ),

          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "refresh",
            onPressed: _initData,
            backgroundColor: Colors.white,
            child: const Icon(Icons.refresh, color: Colors.black),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "myLocation",
            onPressed: _getCurrentLocation,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildLocationInputField(_originController, 'Start Location', Icons.trip_origin, Colors.green),
          const Padding(
            padding: EdgeInsets.only(left: 40),
            child: Divider(height: 20, thickness: 1, color: Colors.white24),
          ),
          _buildLocationInputField(_destinationController, 'Where To Go?', Icons.location_on, Colors.redAccent),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                onPressed: _clearAll,
                icon: const Icon(Icons.delete_sweep, color: Colors.white70),
                tooltip: 'Clear All',
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: _getDirections,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('GET DIRECTIONS', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              if (_directionsFetched) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isRouteSafe ? _startNavigation : _changeRoute,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRouteSafe ? Colors.blue : Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(
                      _isRouteSafe ? 'GO' : 'CHANGE ROUTE', 
                      style: const TextStyle(fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationOverlay() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Navigating...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              Text("Mode: ${_travelModes[_currentModeIndex].toUpperCase()}", style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          ElevatedButton(
            onPressed: _stopNavigation,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("STOP"),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInputField(TextEditingController controller, String hintText, IconData icon, Color iconColor) {
    bool isFocused = _focusedController == controller;
    
    return Row(
      children: [
        Icon(icon, color: isFocused ? iconColor : iconColor.withValues(alpha: 0.5)),
        const SizedBox(width: 15),
        Expanded(
          child: TextField(
            controller: controller,
            onTap: () {
              setState(() {
                _focusedController = controller;
              });
            },
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.white54),
              border: InputBorder.none,
              suffixIcon: isFocused ? const Icon(Icons.edit_location_alt, color: Colors.green, size: 18) : null,
            ),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
