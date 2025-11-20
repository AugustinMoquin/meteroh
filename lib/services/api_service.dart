import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/city.dart';
import '../models/weather.dart';

class ApiService {
  static const _geoBase = 'https://geocoding-api.open-meteo.com/v1/search';
  static const _weatherBase = 'https://api.open-meteo.com/v1/forecast';

  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  /// Search cities by name using Open-Meteo Geocoding API.
  Future<List<City>> searchCities(String name, {int count = 10, String language = 'fr'}) async {
    final uri = Uri.parse('$_geoBase?name=${Uri.encodeComponent(name)}&count=$count&language=$language');
    final res = await client.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch geocoding: ${res.statusCode}');
    }
    final Map<String, dynamic> j = json.decode(res.body) as Map<String, dynamic>;
    final results = j['results'] as List<dynamic>?;
    if (results == null) return [];
    return results.map((e) => City.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Get current weather using Open-Meteo Forecast API (current_weather=true)
  Future<Weather> getWeather(double latitude, double longitude) async {
    final uri = Uri.parse('$_weatherBase?latitude=$latitude&longitude=$longitude&current_weather=true&timezone=auto');
    final res = await client.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch weather: ${res.statusCode}');
    }
    final Map<String, dynamic> j = json.decode(res.body) as Map<String, dynamic>;
    final current = j['current_weather'] as Map<String, dynamic>?;
    if (current == null) throw Exception('No current weather data');
    return Weather.fromCurrentWeatherJson(current);
  }
}

