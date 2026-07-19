import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();

  late Box _settingsBox;
  late Box _profileBox;

  Future<void> init() async {
    _settingsBox = await Hive.openBox('settings');
    _profileBox = await Hive.openBox('profile');
  }

  // --- Theme & Language ---

  bool get isDarkMode => _settingsBox.get('dark_mode', defaultValue: true) as bool;
  Future<void> setDarkMode(bool val) async => await _settingsBox.put('dark_mode', val);

  String get language => _settingsBox.get('language', defaultValue: 'English') as String;
  Future<void> setLanguage(String lang) async => await _settingsBox.put('language', lang);

  // --- Volunteer Mode Toggles ---

  bool get isVolunteerMode => _settingsBox.get('volunteer_mode', defaultValue: false) as bool;
  Future<void> setVolunteerMode(bool val) async => await _settingsBox.put('volunteer_mode', val);

  // --- Auth Session Caching ---

  String? get token => _settingsBox.get('auth_token') as String?;
  Future<void> setToken(String? token) async => await _settingsBox.put('auth_token', token);

  String? get userId => _settingsBox.get('user_id') as String?;
  Future<void> setUserId(String? id) async => await _settingsBox.put('user_id', id);

  // --- User Profile Details Cache ---

  Map<String, dynamic>? getCachedProfile() {
    final raw = _profileBox.get('user_data');
    if (raw == null) return null;
    return Map<String, dynamic>.from(raw as Map);
  }

  Future<void> cacheProfile(Map<String, dynamic> data) async {
    await _profileBox.put('user_data', data);
  }

  Future<void> clearSession() async {
    await _settingsBox.delete('auth_token');
    await _settingsBox.delete('user_id');
    await _profileBox.delete('user_data');
  }
}
