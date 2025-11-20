class City {
  final String name;
  final String? country;
  final double latitude;
  final double longitude;
  final int? population;

  City({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.population,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'] as String? ?? 'Unknown',
      country: json['country'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      population: json['population'] != null ? (json['population'] as num).toInt() : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
        'population': population,
      };
}
