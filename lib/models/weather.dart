class Weather {
  final double temperature;
  final double windSpeed;
  final DateTime time;

  Weather({
    required this.temperature,
    required this.windSpeed,
    required this.time,
  });

  factory Weather.fromCurrentWeatherJson(Map<String, dynamic> json) {
    // expects Open-Meteo current_weather format
    return Weather(
      temperature: (json['temperature'] as num).toDouble(),
      windSpeed: (json['windspeed'] as num).toDouble(),
      time: DateTime.parse(json['time'] as String),
    );
  }
}
