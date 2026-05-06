import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String apiKey = "4658f6c5f28655121e4fbf8a29263147";

  Future<Map<String, dynamic>> getWeather(double lat, double lon) async {
    final url =
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        // Provide more detail in the exception
        final errorBody = json.decode(response.body);
        throw Exception("Weather API Error (${response.statusCode}): ${errorBody['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      rethrow;
    }
  }
}
