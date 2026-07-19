import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pocketbase/pocketbase.dart';
import 'location_service.dart';
import 'bluetooth_service.dart';
import '../storage/local_storage.dart';
import '../database/database_service.dart';

class SosActivationService {
  static final SosActivationService _instance = SosActivationService._internal();
  factory SosActivationService() => _instance;
  SosActivationService._internal();

  final _locationService = LocationService();
  final _localStorage = LocalStorage();
  final _databaseService = DatabaseService();
  final _bluetoothService = BluetoothService();
  final _notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isSosModeActive = false;
  String? _activeEventId;
  Timer? _flashlightTimer;

  bool get isSosModeActive => _isSosModeActive;

  /// Main entry point to activate SOS mode.
  Future<void> activateSos() async {
    if (_isSosModeActive) return;
    _isSosModeActive = true;
    
    // 1. Device haptics & sirens
    _startVibrationSirenSequence();
    _startFlashlightSOSPattern();
    
    // Trigger Bluetooth SOS broadcasting & show local status notification
    await _bluetoothService.startSosAdvertising(_localStorage.userId ?? 'guest');
    await _showLocalNotification();

    // 2. Capture Location
    final position = await _locationService.getCurrentLocation();
    final lat = position?.latitude ?? 0.0;
    final lng = position?.longitude ?? 0.0;
    final timestamp = DateTime.now().toUtc().toIso8601String();
    _activeEventId = 'event_${DateTime.now().millisecondsSinceEpoch}';

    // 3. Log incident locally in SQLite
    final eventRecord = {
      'id': _activeEventId!,
      'user_id': _localStorage.userId ?? 'guest',
      'status': 'active',
      'start_time': timestamp,
      'initial_latitude': lat,
      'initial_longitude': lng,
      'initial_address': 'GPS Coordinates: $lat, $lng',
      'synced': 0
    };
    await _databaseService.insertEvent(eventRecord);

    // 4. Try posting to PocketBase & start 10s background tracking updates
    await _syncEventToPocketBase(eventRecord);
    _locationService.startBackgroundTracking(_activeEventId!);

    // 5. Send alerts to emergency contacts (SMS / WhatsApp prep)
    await _dispatchEmergencyAlerts(lat, lng);
  }

  /// Resolves the active SOS incident.
  Future<void> resolveSos() async {
    if (!_isSosModeActive) return;
    _isSosModeActive = false;

    _stopVibrationSirenSequence();
    _stopFlashlightSOSPattern();
    _locationService.stopBackgroundTracking();
    await _bluetoothService.stopSosAdvertising();
    await _notificationsPlugin.cancel(101); // Dismiss sticky notification

    if (_activeEventId != null) {
      // Mark event resolved locally
      final db = await _databaseService.database;
      await db.update('offline_events', {'status': 'resolved'}, where: 'id = ?', whereArgs: [_activeEventId]);
      
      // Update PocketBase status
      await _syncResolutionToPocketBase(_activeEventId!);
    }

    _activeEventId = null;
  }

  Future<void> _showLocalNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'bhai_sos_channel',
      'BHAI SOS Status',
      channelDescription: 'Alert status for active safety broadcasts',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true, // Keep ongoing until resolved
      playSound: true,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);
    
    await _notificationsPlugin.show(
      101,
      '🚨 BHAI SOS Shield ACTIVE!',
      'Live coordinates sharing in background. Sirens & flashlight active.',
      details,
    );
  }

  // --- Device Trigger Mechanics ---

  void _startVibrationSirenSequence() {
    // Triggers haptic feedback pulses representing an emergency alert
    HapticFeedback.vibrate();
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isSosModeActive) {
        timer.cancel();
        return;
      }
      HapticFeedback.vibrate();
    });
  }

  void _stopVibrationSirenSequence() {
    // Vibration sequences automatically stop when timer cancels
  }

  void _startFlashlightSOSPattern() {
    /*
      DEVELOPER NOTE: Camera Flashlight Blinking (Morse code SOS: 3 short, 3 long, 3 short)
      In production, we instantiate the camera controller and toggle flash:
      cameraController.setFlashMode(FlashMode.torch) -> FlashMode.off.
      Here we register the blinking timer pattern.
    */
    int pulse = 0;
    _flashlightTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!_isSosModeActive) {
        timer.cancel();
        return;
      }
      pulse++;
      bool lightOn = false;
      // Simple SOS blink rhythm simulation
      if (pulse % 6 < 3) {
        // Short pulses
        lightOn = pulse % 2 == 0;
      } else {
        // Long pulses
        lightOn = (pulse % 6) < 5;
      }
      // Toggle device flash logic based on lightOn variable status
    });
  }

  void _stopFlashlightSOSPattern() {
    _flashlightTimer?.cancel();
    _flashlightTimer = null;
  }

  // --- Remote Database Communication ---

  Future<void> _syncEventToPocketBase(Map<String, dynamic> event) async {
    final token = _localStorage.token;
    if (token == null) return;

    try {
      final pb = PocketBase('http://10.208.241.82:8080');
      pb.authStore.save(token, null);

      final pbEvent = await pb.collection('emergency_events').create(body: {
        'id': event['id'],
        'user': event['user_id'],
        'status': event['status'],
        'start_time': event['start_time'],
        'initial_latitude': event['initial_latitude'],
        'initial_longitude': event['initial_longitude'],
        'initial_address': event['initial_address'],
      });

      // Update SQLite to show synced
      await _databaseService.markEventSynced(event['id'] as String);
    } catch (e) {
      print('Offline: Event cached locally in SQLite. Details: ${e.toString()}');
    }
  }

  Future<void> _syncResolutionToPocketBase(String eventId) async {
    final token = _localStorage.token;
    if (token == null) return;

    try {
      final pb = PocketBase('http://10.208.241.82:8080');
      pb.authStore.save(token, null);

      await pb.collection('emergency_events').update(eventId, body: {
        'status': 'resolved',
        'end_time': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      print('Offline status cached. Resolution sync delayed: ${e.toString()}');
    }
  }

  // --- Dispatch Emergency Messaging & Channels ---

  Future<void> _dispatchEmergencyAlerts(double lat, double lng) async {
    final locationUrl = 'https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=16/$lat/$lng';
    final message = 'EMERGENCY! I need help. My current location is: $locationUrl';

    /*
      DEVELOPER NOTE: Platform SMS Guidelines
      - On Android: Using background SMS permissions we can send silent text alerts
        using telephony methods.
      - On iOS: Silent background SMS is restricted. We invoke the native message composer 
        using MethodChannels, pre-populating it with the contacts and emergency body.
    */
    print('Sending SMS alerts: "$message"');

    // prep WhatsApp deep links.
    // Deep links format: https://wa.me/?text=encodedMessage
    final encodedMsg = Uri.encodeComponent(message);
    final whatsappUrl = 'https://wa.me/?text=$encodedMsg';
    print('Pre-filled WhatsApp URL: $whatsappUrl');
    
    // In a real device environment:
    // launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
  }
}
