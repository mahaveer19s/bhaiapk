import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_theme.dart';

class VolunteerDashboardScreen extends StatefulWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  State<VolunteerDashboardScreen> createState() => _VolunteerDashboardScreenState();
}

class _VolunteerDashboardScreenState extends State<VolunteerDashboardScreen> {
  final MapController _mapController = MapController();
  final LatLng _volunteerLocation = const LatLng(28.6273, 77.3725); // Volunteer coordinates
  final LatLng _victimLocation = const LatLng(28.6295, 77.3768); // Simulated victim location

  bool _isRequestAccepted = false;
  List<LatLng> _routeToVictim = [];
  bool _isLoadingRoute = false;

  Future<void> _acceptEmergency() async {
    setState(() => _isLoadingRoute = true);

    // OSRM walking path from volunteer to victim
    final String url = 'https://router.project-osrm.org/route/v1/foot/'
        '${_volunteerLocation.longitude},${_volunteerLocation.latitude};'
        '${_victimLocation.longitude},${_victimLocation.latitude}'
        '?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final geometry = data['routes'][0]['geometry']['coordinates'] as List;
        
        setState(() {
          _routeToVictim = geometry.map((coord) {
            return LatLng(coord[1] as double, coord[0] as double);
          }).toList();
          _isRequestAccepted = true;
        });
      }
    } catch (e) {
      print('Failed to calculate navigation line to victim: $e');
      setState(() {
        _routeToVictim = [_volunteerLocation, _victimLocation];
        _isRequestAccepted = true;
      });
    } finally {
      setState(() => _isLoadingRoute = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('VOLUNTEER FEED'),
      ),
      body: Stack(
        children: [
          // OpenStreetMap Tile rendering
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _volunteerLocation,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.bhai.app',
                tileBuilder: isDark ? (context, tileWidget, tile) {
                  return ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      -1.0, 0.0, 0.0, 0.0, 255.0,
                      0.0, -1.0, 0.0, 0.0, 255.0,
                      0.0, 0.0, -1.0, 0.0, 255.0,
                      0.0, 0.0, 0.0, 1.0, 0.0,
                    ]),
                    child: tileWidget,
                  );
                } : null,
              ),
              if (_isRequestAccepted)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routeToVictim,
                      strokeWidth: 4.5,
                      color: AppTheme.accentCrimson,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  // Volunteer Marker
                  Marker(
                    point: _volunteerLocation,
                    width: 40.0,
                    height: 40.0,
                    child: const Icon(Icons.shield, color: AppTheme.accentCyan, size: 30),
                  ),
                  // Victim Marker
                  Marker(
                    point: _victimLocation,
                    width: 40.0,
                    height: 40.0,
                    child: const Icon(Icons.warning, color: AppTheme.accentCrimson, size: 35),
                  ),
                ],
              ),
            ],
          ),

          // Sliding Info Card
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: GlassmorphicContainer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.accentCrimson.withOpacity(0.2),
                        child: const Icon(Icons.warning_amber_rounded, color: AppTheme.accentCrimson),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nearby Emergency Active',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentCrimson),
                            ),
                            Text('Distance: ~450m | Walk: ~5 mins', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 16),
                  if (!_isRequestAccepted) ...[
                    const Text(
                      'A nearby user has triggered an SOS alert. Are you available to assist?',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentCrimson,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _acceptEmergency,
                      child: _isLoadingRoute 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Accept & Navigate to Victim', style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                  ] else ...[
                    const Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'You have accepted this request.',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please navigate safely using the crimson route path. Victim has been notified that help is on the way.',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.call),
                            label: const Text('Call Emergency Services'),
                            onPressed: () {
                              // Direct call to local police line
                            },
                          ),
                        ),
                      ],
                    )
                  ]
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
