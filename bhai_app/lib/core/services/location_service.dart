import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../database/database_service.dart';
import '../storage/local_storage.dart';
import 'package:pocketbase/pocketbase.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionStreamSubscription;
  final _databaseService = DatabaseService();
  final _localStorage = LocalStorage();

  /// Checks if location services are enabled and permissions are granted.
  Future<bool> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  /// Gets the current location.
  Future<Position?> getCurrentLocation() async {
    final hasPermission = await checkPermission();
    if (!hasPermission) return null;
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  /// Starts streaming location updates every 10 seconds.
  void startBackgroundTracking(String activeEventId) {
    if (_positionStreamSubscription != null) return;

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update if moves 10 meters, or every interval
      timeLimit: Duration(seconds: 10),
    );

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) async {
          final timestamp = DateTime.now().toUtc().toIso8601String();
          final battery = await _getBatteryLevel();
          final network = await _checkNetworkStatus();

          // Prepare telemetry packet
          final locationPacket = {
            'id': 'loc_${DateTime.now().millisecondsSinceEpoch}',
            'event': activeEventId,
            'latitude': position.latitude,
            'longitude': position.longitude,
            'timestamp': timestamp,
            'battery_level': battery,
            'network_status': network,
            'synced': 0
          };

          // Save locally in SQLite offline queue
          await _databaseService.insertLocation(locationPacket);

          // Try updating remote PocketBase database if online
          await _syncLocationPacket(locationPacket);
    });
  }

  /// Stops background tracking.
  void stopBackgroundTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  // --- Utility Mocking for system indicators ---

  Future<double> _getBatteryLevel() async {
    // In production, we'd use battery_plus. Mocking 85% for safety details
    return 85.0;
  }

  Future<String> _checkNetworkStatus() async {
    // In production, connectivity_plus. Mocking '4G'
    return '4G';
  }

  Future<void> _syncLocationPacket(Map<String, dynamic> packet) async {
    final token = _localStorage.token;
    if (token == null) return;

    try {
      final pb = PocketBase('https://bhaiapk.onrender.com');
      pb.authStore.save(token, null);
      
      await pb.collection('locations').create(body: {
        'event': packet['event'],
        'latitude': packet['latitude'],
        'longitude': packet['longitude'],
        'timestamp': packet['timestamp'],
        'battery_level': packet['battery_level'],
        'network_status': packet['network_status'],
      });

      // Mark as synced in SQLite
      await _databaseService.markLocationSynced(packet['id'] as String);
    } catch (e) {
      // Quietly fail and let the SQLite offline queue handle sync when online status updates
      print('Network offline. Location cached in SQLite: ${e.toString()}');
    }
  }
}
