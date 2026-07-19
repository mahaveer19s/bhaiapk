import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSosTriggered = false;
  bool _isVolunteerMode = false;
  String _currentAddress = 'Fetching current address...';
  int _batteryLevel = 92;
  String _networkStatus = 'LTE Excellent';
  String _weather = 'Cloudy 28°C';

  @override
  void initState() {
    super.initState();
    _loadVolunteerState();
    _fetchLocationDetails();
  }

  void _loadVolunteerState() {
    final box = Hive.box('settings');
    setState(() {
      _isVolunteerMode = box.get('volunteer_mode', defaultValue: false) as bool;
    });
  }

  void _fetchLocationDetails() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentAddress = 'Sector 62, Noida, UP, India';
        });
      }
    });
  }

  void _toggleVolunteerMode(bool val) async {
    final box = Hive.box('settings');
    await box.put('volunteer_mode', val);
    setState(() {
      _isVolunteerMode = val;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isVolunteerMode ? 'Volunteer Mode Enabled' : 'Volunteer Mode Disabled')),
    );
    if (_isVolunteerMode) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) context.push('/volunteer');
      });
    }
  }

  void _triggerSos() {
    setState(() {
      _isSosTriggered = !_isSosTriggered;
    });
    if (_isSosTriggered) {
      // In production, triggers the SOS Dispatch pipeline (audio/video, location tracking, background SMS, WhatsApp pre-fill)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.accentCrimson,
          content: Text('SOS Triggered! Location sharing active. Contacts alerted.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('SOS Resolved. Telemetry tracking stopped.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BHAI SHIELD'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/settings'), // Navigates to settings/profile
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.darkGradient : AppTheme.lightGradient,
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Header Card
                    _buildStatusHeaderCard(),
                    const SizedBox(height: 20),

                    // Quick Telemetry Info Row
                    Row(
                      children: [
                        Expanded(child: _buildTelemetryCard(Icons.battery_charging_full, '$_batteryLevel%', 'Device Battery')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTelemetryCard(Icons.wifi, _networkStatus, 'Network State')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildTelemetryCard(Icons.cloud_queue, _weather, 'Weather')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTelemetryCard(Icons.location_on_outlined, 'Sector 62', 'Trusted Zone')),
                      ],
                    ),
                    const SizedBox(height: 35),

                    // Center Big SOS Button
                    Center(child: _buildEmergencySosButton()),
                    const SizedBox(height: 40),

                    // Volunteer Mode Toggle panel
                    _buildVolunteerTogglePanel(),
                    const SizedBox(height: 20),

                    // Emergency Services Buttons
                    _buildEmergencyQuickActions(),
                  ],
                ),
              ),
            ),
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeaderCard() {
    return GlassmorphicContainer(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _isSosTriggered ? AppTheme.accentCrimson.withOpacity(0.2) : Colors.green.withOpacity(0.2),
            radius: 24,
            child: Icon(
              _isSosTriggered ? Icons.warning_amber_rounded : Icons.shield_rounded,
              color: _isSosTriggered ? AppTheme.accentCrimson : Colors.green,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isSosTriggered ? 'SOS SYSTEM ACTIVE' : 'YOUR SHIELD IS ACTIVE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isSosTriggered ? AppTheme.accentCrimson : Colors.green,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  _currentAddress,
                  style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis),
                  maxLines: 1,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTelemetryCard(IconData icon, String val, String subtitle) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.accentCyan, size: 20),
          const SizedBox(height: 8),
          Text(val, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmergencySosButton() {
    return GestureDetector(
      onLongPress: _triggerSos,
      onDoubleTap: _triggerSos,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 180,
        width: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (_isSosTriggered ? AppTheme.accentCrimson : AppTheme.accentCyan).withOpacity(0.35),
              blurRadius: 25,
              spreadRadius: 5,
            )
          ],
          gradient: _isSosTriggered ? AppTheme.sosGradient : const LinearGradient(
            colors: [Color(0xFF0284C7), Color(0xFF0F172A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(
            color: _isSosTriggered ? Colors.white : AppTheme.accentCyan,
            width: 3,
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isSosTriggered ? Icons.warning : Icons.power_settings_new_rounded,
              color: Colors.white,
              size: 50,
            ),
            const SizedBox(height: 8),
            Text(
              _isSosTriggered ? 'ACTIVE' : 'SOS',
              style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            const Text(
              'HOLD OR TAP TWICE',
              style: TextStyle(fontSize: 9, color: Colors.white70, letterSpacing: 0.5),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildVolunteerTogglePanel() {
    return GlassmorphicContainer(
      child: SwitchListTile(
        title: const Text('Volunteer Protection Mode', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Allow nearby emergencies to contact you for help', style: TextStyle(fontSize: 12)),
        activeColor: AppTheme.accentCyan,
        value: _isVolunteerMode,
        onChanged: _toggleVolunteerMode,
      ),
    );
  }

  Widget _buildEmergencyQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildQuickCircleButton(Icons.local_police_outlined, 'Police', () => context.push('/safe-route')),
        _buildQuickCircleButton(Icons.local_hospital_outlined, 'Hospital', () => context.push('/safe-route')),
        _buildQuickCircleButton(Icons.call, 'Helplines', () => context.push('/helpline')),
        _buildQuickCircleButton(Icons.phone_in_talk, 'Fake Call', () => context.push('/fake-call')),
        _buildQuickCircleButton(Icons.directions_run, 'Travel Mode', () => context.push('/travel-mode')),
      ],
    );
  }

  Widget _buildQuickCircleButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.secondaryDark.withOpacity(0.3),
              border: Border.all(color: AppTheme.accentCyan.withOpacity(0.3), width: 1.5),
            ),
            child: Icon(icon, color: AppTheme.accentCyan, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home, color: AppTheme.accentCyan, size: 28),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.map_outlined, color: Colors.grey, size: 28),
            onPressed: () => context.push('/safe-route'),
          ),
          IconButton(
            icon: const Icon(Icons.contact_phone_outlined, color: Colors.grey, size: 28),
            onPressed: () => context.push('/helpline'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.grey, size: 28),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}
