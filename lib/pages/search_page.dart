import 'package:flutter/material.dart';
import '../models/city.dart';
import '../services/api_service.dart';
import 'city_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final ApiService _apiService = ApiService();
  List<City> _results = [];
  bool _loading = false;

  Future<void> _search() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _loading = true;
    });
    try {
      final cities = await _apiService.searchCities(q);
      if (mounted) {
        setState(() {
          _results = cities;
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CityWeather'),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Rechercher une ville...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _search(),
                      ),
                    ),
                    FilledButton(
                      onPressed: _search,
                      child: const Text('Rechercher'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'Recherchez une ville',
                            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ou utilisez votre position actuelle',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, i) {
                        final c = _results[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: const Icon(Icons.location_city, color: Colors.blue),
                            ),
                            title: Text(
                              '${c.name}${c.country != null ? ', ${c.country}' : ''}',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text('${c.latitude.toStringAsFixed(2)}, ${c.longitude.toStringAsFixed(2)}'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => CityDetailPage(city: c)),
                            ),
                          ),
                        );
                      }),
            )
          ],
        ),
      ),
    );
  }
}
