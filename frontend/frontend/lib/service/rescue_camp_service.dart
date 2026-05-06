import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/constants.dart';

class RescueCampService {
  final _storage = const FlutterSecureStorage();

  Future<bool> createRescueCamp({
    required String name,
    required double lat,
    required double lon,
    required int capacity,
    required String address,
    required String phone,
    File? imageFile,
  }) async {
    final String? userIdStr = await _storage.read(key: 'user_id');
    final int managerId = userIdStr != null ? int.parse(userIdStr) : 1;

    final url = Uri.parse('${AppConstants.baseUrl}/api/rescue_camp/create');

    final Map<String, dynamic> campData = {
      "name": name,
      "location_lat": lat,
      "location_lon": lon,
      "capacity": capacity,
      "current_people_count": 0,
      "address": address,
      "tp_no": phone,
      "managerId": managerId,
    };

    try {
      var request = http.MultipartRequest('POST', url);

      // Add the JSON part
      request.files.add(
        http.MultipartFile.fromString(
          'rescueCampDto',
          jsonEncode(campData),
          contentType: MediaType('application', 'json'),
        ),
      );

      // Add the image part if it exists
      if (imageFile != null) {
        String fileName = imageFile.path.split('/').last;
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            filename: fileName,
            contentType: MediaType('image', 'jpeg'), // Adjust based on file type if needed
          ),
        );
      }

      // Add authorization header if needed (optional based on your backend)
      final String? token = await _storage.read(key: 'jwt_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Rescue Camp Created: $responseBody');
        return true;
      } else {
        print('Failed to create rescue camp: ${response.statusCode}');
        print('Response: $responseBody');
        return false;
      }
    } catch (e) {
      print('Error creating rescue camp: $e');
      return false;
    }
  }

  Future<List<dynamic>> getAllRescueCamps() async {
    final url = Uri.parse('${AppConstants.baseUrl}/api/rescue_camp/');
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      final Map<String, String> headers = {};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to load camps: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching camps: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getRescueCampById(int id) async {
    final url = Uri.parse('${AppConstants.baseUrl}/api/rescue_camp/$id');
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      final Map<String, String> headers = {};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to load camp details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching camp details: $e');
      return null;
    }
  }

  Future<bool> updateRescueCamp({
    required int id,
    required String name,
    required double lat,
    required double lon,
    required int capacity,
    required int currentPeopleCount,
    required String address,
    required String phone,
    String? existingImageUrl,
    File? imageFile,
  }) async {
    final String? userIdStr = await _storage.read(key: 'user_id');
    final int managerId = userIdStr != null ? int.parse(userIdStr) : 1;

    final url = Uri.parse('${AppConstants.baseUrl}/api/rescue_camp/$id');

    final Map<String, dynamic> campData = {
      "name": name,
      "location_lat": lat,
      "location_lon": lon,
      "capacity": capacity,
      "current_people_count": currentPeopleCount,
      "address": address,
      "tp_no": phone,
      "managerId": managerId,
      "people_image_url": existingImageUrl,
    };

    try {
      var request = http.MultipartRequest('PUT', url);

      request.files.add(
        http.MultipartFile.fromString(
          'rescueCampDto',
          jsonEncode(campData),
          contentType: MediaType('application', 'json'),
        ),
      );

      if (imageFile != null) {
        String fileName = imageFile.path.split('/').last;
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            filename: fileName,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      final String? token = await _storage.read(key: 'jwt_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Rescue Camp Updated: $responseBody');
        return true;
      } else {
        print('Failed to update rescue camp: ${response.statusCode}');
        print('Response: $responseBody');
        return false;
      }
    } catch (e) {
      print('Error updating rescue camp: $e');
      return false;
    }
  }

  Future<bool> createOrphanGroup({
    required String name,
    required int numOfKids,
    required double lat,
    required double lon,
    required int rescueCampId,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}/api/orphan_group/create');
    final Map<String, dynamic> groupData = {
      "name": name,
      "num_of_kids": numOfKids,
      "location_lat": lat,
      "location_lon": lon,
      "created_at": DateTime.now().toIso8601String(),
      "rescueCampId": rescueCampId,
    };

    try {
      final String? token = await _storage.read(key: 'jwt_token');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(groupData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print('Failed to create orphan group: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating orphan group: $e');
      return false;
    }
  }

  Future<List<dynamic>> getOrphanGroupsByCampId(int campId) async {
    final url = Uri.parse('${AppConstants.baseUrl}/api/orphan_group/by_rescue_camp_id/$campId');
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      final Map<String, String> headers = {};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to load orphan groups: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching orphan groups: $e');
      return [];
    }
  }

  Future<bool> createResourceNeed({
    required dynamic foodQty,
    required dynamic medicineQty,
    required dynamic clothesQty,
    required dynamic priceQty,
    required String urgencyLevel,
    required int rescueCampId,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}/api/resource_need/create');
    final Map<String, dynamic> body = {
      "food_qty": foodQty,
      "medicine_qty": medicineQty,
      "clothes_qty": clothesQty,
      "price_qty": priceQty,
      "urgency_level": urgencyLevel,
      "rescueCampId": rescueCampId,
    };

    try {
      final String? token = await _storage.read(key: 'jwt_token');
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print('Failed to create resource need: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating resource need: $e');
      return false;
    }
  }

  Future<List<dynamic>> getAllResourceNeeds() async {
    final url = Uri.parse('${AppConstants.baseUrl}/api/resource_need/');
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      final Map<String, String> headers = {};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to load resource needs: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching resource needs: $e');
      return [];
    }
  }

  Future<bool> deleteRescueCamp(int id) async {
    final url = Uri.parse('${AppConstants.baseUrl}/api/rescue_camp/$id');
    try {
      final String? token = await _storage.read(key: 'jwt_token');
      final Map<String, String> headers = {};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.delete(url, headers: headers);
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('Failed to delete rescue camp: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting rescue camp: $e');
      return false;
    }
  }

  Future<int> countPeopleFromImage(File imageFile) async {
    final url = Uri.parse('${AppConstants.baseUrl}/api/vision/count-people');
    try {
      var request = http.MultipartRequest('POST', url);

      String fileName = imageFile.path.split('/').last;
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final String? token = await _storage.read(key: 'jwt_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(responseBody);
        return data['peopleCount'] ?? 0;
      } else {
        print('Failed to count people: ${response.statusCode}');
        print('Response: $responseBody');
        return 0;
      }
    } catch (e) {
      print('Error counting people: $e');
      return 0;
    }
  }
}
