import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  bool _isScanning = false;
  bool _isAdvertising = false;
  
  // Custom Service UUID representing BHAI SOS alert beacon
  static const String bhaiSosServiceUuid = '0000bhai-0000-1000-8000-00805f9b34fb';

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Requests Bluetooth permission.
  Future<bool> requestPermissions() async {
    final statusScan = await Permission.bluetoothScan.request();
    final statusAdvertise = await Permission.bluetoothAdvertise.request();
    final statusConnect = await Permission.bluetoothConnect.request();
    
    return statusScan.isGranted && statusAdvertise.isGranted && statusConnect.isGranted;
  }

  /// Starts broadcasting (advertising) the SOS distress BLE signature.
  Future<void> startSosAdvertising(String encryptedUserId) async {
    if (_isAdvertising) return;
    
    final permitted = await requestPermissions();
    if (!permitted) {
      print('Bluetooth permissions denied for SOS advertising.');
      return;
    }

    _isAdvertising = true;
    /*
      DEVELOPER NOTE: Bluetooth BLE Advertising Implementation
      In production, we invoke flutter_blue_plus or native channels:
      FlutterBluePlus.startAdvertising(
        serviceUuid: bhaiSosServiceUuid,
        manufacturerData: [1, 2, 3], // Custom encrypted payload bytes
        localName: 'BHAI_SOS'
      );
    */
    print('BLE advertising started: Broadcasting SOS with UUID: $bhaiSosServiceUuid');
  }

  /// Stops broadcasting the SOS BLE signature.
  Future<void> stopSosAdvertising() async {
    if (!_isAdvertising) return;
    _isAdvertising = false;
    print('BLE advertising stopped.');
  }

  /// Starts scanning for nearby SOS BLE signatures (active for volunteers).
  Future<void> startSosScanning() async {
    if (_isScanning) return;

    final permitted = await requestPermissions();
    if (!permitted) {
      print('Bluetooth permissions denied for SOS scanning.');
      return;
    }

    _isScanning = true;
    print('BLE scanning started: Searching for nearby devices advertising UUID: $bhaiSosServiceUuid');

    /*
      DEVELOPER NOTE: BLE Scan & Notification Dispatch
      We scan for devices with matching service UUID.
      If a device is discovered, we trigger a high-priority local notification 
      alerting the volunteer of a nearby distress beacon.
    */
    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_isScanning) {
        timer.cancel();
        return;
      }
      // Mock discovering a nearby SOS beacon to demonstrate local notification trigger
      _triggerNearbySosNotification();
    });
  }

  /// Stops scanning for SOS signatures.
  Future<void> stopSosScanning() async {
    if (!_isScanning) return;
    _isScanning = false;
    print('BLE scanning stopped.');
  }

  Future<void> _triggerNearbySosNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'bhai_bluetooth_channel',
      'Nearby Bluetooth Alerts',
      channelDescription: 'Alerts triggered by nearby bluetooth safety beacons',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);
    
    await _notificationsPlugin.show(
      202,
      '⚠️ Nearby Distress Signal!',
      'Bluetooth detected an active BHAI SOS beacon within 30 meters.',
      details,
    );
  }
}
