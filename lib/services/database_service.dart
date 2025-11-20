import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/city.dart';

class DatabaseService {
  static Database? _database;
  static const String _tableName = 'favorites';
  static const int _maxFavorites = 10;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialize sqflite_common_ffi for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cityweather.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            country TEXT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            population INTEGER,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  /// Get all favorite cities ordered by creation date (newest first)
  Future<List<City>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => City.fromJson(maps[i]));
  }

  /// Add a city to favorites (up to 10)
  Future<bool> addFavorite(City city) async {
    final db = await database;
    
    // Check if already exists
    final existing = await db.query(
      _tableName,
      where: 'latitude = ? AND longitude = ?',
      whereArgs: [city.latitude, city.longitude],
    );
    
    if (existing.isNotEmpty) {
      return false; // Already in favorites
    }

    // Check if we've reached the limit
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tableName'),
    ) ?? 0;

    if (count >= _maxFavorites) {
      return false; // Max favorites reached
    }

    // Add the favorite
    await db.insert(
      _tableName,
      {
        'name': city.name,
        'country': city.country,
        'latitude': city.latitude,
        'longitude': city.longitude,
        'population': city.population,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
    );
    return true;
  }

  /// Remove a city from favorites
  Future<void> removeFavorite(City city) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'latitude = ? AND longitude = ?',
      whereArgs: [city.latitude, city.longitude],
    );
  }

  /// Check if a city is in favorites
  Future<bool> isFavorite(City city) async {
    final db = await database;
    final result = await db.query(
      _tableName,
      where: 'latitude = ? AND longitude = ?',
      whereArgs: [city.latitude, city.longitude],
    );
    return result.isNotEmpty;
  }

  /// Get the count of favorites
  Future<int> getFavoritesCount() async {
    final db = await database;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $_tableName'),
    ) ?? 0;
  }
}
