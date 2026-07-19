import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TravelModeScreen extends StatefulWidget {
  const TravelModeScreen({super.key});

  @override
  State<TravelModeScreen> createState() => _TravelModeScreenState();
}

class _TravelModeScreenState extends State<TravelModeScreen> {
  final TextEditingController _destController = TextEditingController(text: 'Shipra Mall, Indirapuram');
  final TextEditingController _etaController = TextEditingController(text: '15 Mins');

  bool _isTripActive = false;
  bool _isDeviated = false;
  int _deviationCountDown = 30;
  Timer? _deviationTimer;

  void _startTrip() {
    setState(() {
      _isTripActive = true;
      _isDeviated = false;
    });

    // Simulate route monitoring, trigger a mock deviation alert after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isTripActive) {
        setState(() {
          _isDeviated = true;
        });
        _startDeviationCountdown();
      }
    });
  }

  void _startDeviationCountdown() {
    _deviationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_deviationCountDown <= 1) {
        timer.cancel();
        // Trigger emergency SOS automatically
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppTheme.accentCrimson,
            content: Text('Route deviation! SOS triggered automatically.', style: TextStyle(color: Colors.white)),
          ),
        );
        setState(() {
          _isTripActive = false;
          _isDeviated = false;
        });
      } else {
        setState(() {
          _deviationCountDown--;
        });
      }
    });
  }

  void _resolveDeviation() {
    _deviationTimer?.cancel();
    setState(() {
      _isDeviated = false;
      _deviationCountDown = 30;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Route deviation resolved. Safe status restored.')),
    );
  }

  void _endTrip() {
    _deviationTimer?.cancel();
    setState(() {
      _isTripActive = false;
      _isDeviated = false;
      _deviationCountDown = 30;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trip ended successfully.')),
    );
  }

  @override
  void dispose() {
    _deviationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TRAVEL PROTECTION'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.darkGradient : AppTheme.lightGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trip Route Monitor',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Share your trip route in real-time. If your vehicle deviates significantly from the target path, we automatically notify your contacts.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              if (!_isTripActive) ...[
                // Trip setup details
                GlassmorphicContainer(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _destController,
                        decoration: InputDecoration(
                          labelText: 'Destination Address',
                          prefixIcon: const Icon(Icons.location_city_outlined),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _etaController,
                        decoration: InputDecoration(
                          labelText: 'Expected Travel Duration (ETA)',
                          prefixIcon: const Icon(Icons.timer_outlined),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentCyan,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.share_location_outlined),
                        label: const Text('Start Monitored Trip'),
                        onPressed: _startTrip,
                      )
                    ],
                  ),
                )
              ] else ...[
                // Trip active tracker details
                GlassmorphicContainer(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Trip Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _isDeviated ? AppTheme.accentCrimson.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _isDeviated ? 'DEVIATION DETECTED' : 'ON TRACK',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _isDeviated ? AppTheme.accentCrimson : Colors.green,
                              ),
                            ),
                          )
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 24),
                      ListTile(
                        leading: const Icon(Icons.navigation, color: AppTheme.accentCyan),
                        title: Text(_destController.text),
                        subtitle: Text('Estimated Duration: ${_etaController.text}'),
                      ),
                      
                      if (_isDeviated) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.accentCrimson.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.accentCrimson.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Auto-SOS triggers in $_deviationCountDown seconds!',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentCrimson),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: _resolveDeviation,
                                child: const Text('I am Safe (Dismiss Alarm)'),
                              )
                            ],
                          ),
                        )
                      ],

                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentCrimson,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _endTrip,
                        child: const Text('End Monitored Trip'),
                      )
                    ],
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
