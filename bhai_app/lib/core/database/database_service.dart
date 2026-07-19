import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'bhai_offline.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Table for offline SOS incidents
        await db.execute('''
          CREATE TABLE offline_events (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            status TEXT NOT NULL,
            start_time TEXT NOT NULL,
            initial_latitude REAL NOT NULL,
            initial_longitude REAL NOT NULL,
            initial_address TEXT,
            synced INTEGER DEFAULT 0
          )
        ''');

        // Table for offline SOS live location tracks
        await db.execute('''
          CREATE TABLE offline_locations (
            id TEXT PRIMARY KEY,
            event_id TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            timestamp TEXT NOT NULL,
            battery_level REAL,
            network_status TEXT,
            synced INTEGER DEFAULT 0,
            FOREIGN KEY (event_id) REFERENCES offline_events (id) ON DELETE CASCADE
          )
        ''');

        // Table for offline helpline cache
        await db.execute('''
          CREATE TABLE helpline_cache (
            id TEXT PRIMARY KEY,
            state TEXT NOT NULL,
            category TEXT NOT NULL,
            number TEXT NOT NULL,
            name TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // --- Offline Events Helpers ---

  Future<void> insertEvent(Map<String, dynamic> event) async {
    final db = await database;
    await db.insert('offline_events', event, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedEvents() async {
    final db = await database;
    return await db.query('offline_events', where: 'synced = 0');
  }

  Future<void> markEventSynced(String id) async {
    final db = await database;
    await db.update('offline_events', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  // --- Offline Locations Helpers ---

  Future<void> insertLocation(Map<String, dynamic> location) async {
    final db = await database;
    await db.insert('offline_locations', location, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedLocations() async {
    final db = await database;
    return await db.query('offline_locations', where: 'synced = 0');
  }

  Future<void> markLocationSynced(String id) async {
    final db = await database;
    await db.update('offline_locations', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  // --- Helpline Cache Helpers ---

  Future<void> cacheHelplines(List<Map<String, dynamic>> helplines) async {
    final db = await database;
    final batch = db.batch();
    
    // Clear old cache before replacing
    batch.delete('helpline_cache');
    for (var line in helplines) {
      batch.insert('helpline_cache', line, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> searchHelplines(String query) async {
    final db = await database;
    if (query.isEmpty) {
      return await db.query('helpline_cache');
    }
    return await db.query(
      'helpline_cache',
      where: 'state LIKE ? OR category LIKE ? OR name LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
  }
}
