import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:meteroh/services/api_service.dart';
import 'package:meteroh/models/city.dart';
import 'package:meteroh/models/weather.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  late MockClient mockClient;
  late ApiService apiService;

  setUp(() {
    mockClient = MockClient();
    apiService = ApiService(client: mockClient);
  });

  group('ApiService.searchCities', () {
    test('returns list of cities on successful response', () async {
      // Arrange
      final uri = Uri.parse(
          'https://geocoding-api.open-meteo.com/v1/search?name=Paris&count=10&language=fr');
      when(() => mockClient.get(uri)).thenAnswer(
        (_) async => http.Response(
          '''
          {
            "results": [
              {
                "name": "Paris",
                "country": "France",
                "latitude": 48.8566,
                "longitude": 2.3522,
                "population": 2161000
              },
              {
                "name": "Paris",
                "country": "United States",
                "latitude": 33.6609,
                "longitude": -95.5555,
                "population": 25171
              }
            ]
          }
          ''',
          200,
        ),
      );

      // Act
      final cities = await apiService.searchCities('Paris');

      // Assert
      expect(cities, isA<List<City>>());
      expect(cities.length, 2);
      expect(cities[0].name, 'Paris');
      expect(cities[0].country, 'France');
      expect(cities[0].latitude, 48.8566);
      expect(cities[1].country, 'United States');
    });

    test('returns empty list when no results', () async {
      // Arrange
      final uri = Uri.parse(
          'https://geocoding-api.open-meteo.com/v1/search?name=NonExistentCity&count=10&language=fr');
      when(() => mockClient.get(uri)).thenAnswer(
        (_) async => http.Response('{}', 200),
      );

      // Act
      final cities = await apiService.searchCities('NonExistentCity');

      // Assert
      expect(cities, isEmpty);
    });

    test('throws exception on failed response', () async {
      // Arrange
      final uri = Uri.parse(
          'https://geocoding-api.open-meteo.com/v1/search?name=Paris&count=10&language=fr');
      when(() => mockClient.get(uri)).thenAnswer(
        (_) async => http.Response('Server Error', 500),
      );

      // Act & Assert
      expect(
        () => apiService.searchCities('Paris'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('ApiService.getWeather', () {
    test('returns weather on successful response', () async {
      // Arrange
      final uri = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=48.85&longitude=2.35&current_weather=true&timezone=auto');
      when(() => mockClient.get(uri)).thenAnswer(
        (_) async => http.Response(
          '''
          {
            "current_weather": {
              "temperature": 15.5,
              "windspeed": 12.3,
              "time": "2025-11-20T14:30:00"
            }
          }
          ''',
          200,
        ),
      );

      // Act
      final weather = await apiService.getWeather(48.85, 2.35);

      // Assert
      expect(weather, isA<Weather>());
      expect(weather.temperature, 15.5);
      expect(weather.windSpeed, 12.3);
      expect(weather.time, DateTime.parse("2025-11-20T14:30:00"));
    });

    test('throws exception when no current_weather data', () async {
      // Arrange
      final uri = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=48.85&longitude=2.35&current_weather=true&timezone=auto');
      when(() => mockClient.get(uri)).thenAnswer(
        (_) async => http.Response('{}', 200),
      );

      // Act & Assert
      expect(
        () => apiService.getWeather(48.85, 2.35),
        throwsA(isA<Exception>()),
      );
    });

    test('throws exception on failed response', () async {
      // Arrange
      final uri = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=48.85&longitude=2.35&current_weather=true&timezone=auto');
      when(() => mockClient.get(uri)).thenAnswer(
        (_) async => http.Response('Server Error', 500),
      );

      // Act & Assert
      expect(
        () => apiService.getWeather(48.85, 2.35),
        throwsA(isA<Exception>()),
      );
    });
  });
}
