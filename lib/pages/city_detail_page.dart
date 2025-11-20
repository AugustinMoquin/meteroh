import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/city.dart';
import '../models/weather.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../widgets/weather_card.dart';

class CityDetailPage extends StatefulWidget {
  final City city;
  const CityDetailPage({super.key, required this.city});

  @override
  State<CityDetailPage> createState() => _CityDetailPageState();
}

class _CityDetailPageState extends State<CityDetailPage> {
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService();
  Weather? _weather;
  bool _loading = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadWeather();
    _checkFavorite();
  }

  Future<void> _loadWeather() async {
    if (mounted) setState(() => _loading = true);
    try {
      final w = await _apiService.getWeather(widget.city.latitude, widget.city.longitude);
      if (mounted) setState(() => _weather = w);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur météo: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _checkFavorite() async {
    final isFav = await _dbService.isFavorite(widget.city);
    if (mounted) setState(() => _isFavorite = isFav);
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await _dbService.removeFavorite(widget.city);
      if (mounted) {
        setState(() => _isFavorite = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Retiré des favoris')),
        );
      }
    } else {
      final success = await _dbService.addFavorite(widget.city);
      if (mounted) {
        if (success) {
          setState(() => _isFavorite = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ajouté aux favoris')),
          );
        } else {
          final count = await _dbService.getFavoritesCount();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(count >= 10 ? 'Maximum 10 favoris' : 'Déjà dans les favoris')),
            );
          }
        }
      }
    }
  }

  Future<void> _openMaps() async {
    final lat = widget.city.latitude;
    final lon = widget.city.longitude;
    final google = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
    if (await canLaunchUrl(google)) {
      await launchUrl(google, mode: LaunchMode.externalApplication);
    } else {
      final apple = Uri.parse('maps:0,0?q=$lat,$lon');
      if (await canLaunchUrl(apple)) {
        await launchUrl(apple);
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot open maps')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.city.name),
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            tooltip: _isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
          ),
          IconButton(onPressed: _openMaps, icon: const Icon(Icons.map)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_city, size: 32, color: Colors.blue),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.city.name,
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      if (widget.city.country != null)
                                        Text(
                                          widget.city.country!,
                                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              children: [
                                const Icon(Icons.pin_drop, size: 20, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  '${widget.city.latitude.toStringAsFixed(4)}, ${widget.city.longitude.toStringAsFixed(4)}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Météo actuelle',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (_weather != null)
                      WeatherCard(weather: _weather!)
                    else
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(
                            child: Text('Pas de données météo disponibles'),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
