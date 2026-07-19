import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Simulated active SOS events
  final List<Map<String, dynamic>> _activeIncidents = [
    {
      'id': 'event_101',
      'user': 'Ananya Sharma',
      'age': 24,
      'blood_group': 'O+',
      'medical': 'Asthma',
      'location': 'Sector 62, Noida',
      'contacts': ['Dad (+91 98765 43210)', 'Mom (+91 98765 43211)'],
      'time': '2 Mins Ago',
      'volunteers_dispatched': 2,
    },
    {
      'id': 'event_102',
      'user': 'Sneha Patel',
      'age': 22,
      'blood_group': 'A+',
      'medical': 'None',
      'location': 'Indirapuram, Ghaziabad',
      'contacts': ['Husband (+91 98765 43212)'],
      'time': '5 Mins Ago',
      'volunteers_dispatched': 1,
    }
  ];

  Map<String, dynamic>? _selectedIncident;

  @override
  void initState() {
    super.initState();
    if (_activeIncidents.isNotEmpty) {
      _selectedIncident = _activeIncidents.first;
    }
  }

  void _resolveIncident(String id) {
    setState(() {
      _activeIncidents.removeWhere((inc) => inc['id'] == id);
      _selectedIncident = _activeIncidents.isNotEmpty ? _activeIncidents.first : null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('SOS Incident marked as resolved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar navigation
          _buildSidebar(),

          // Main control console
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  
                  // Top Stats Counters Cards Grid
                  _buildStatsGrid(),
                  const SizedBox(height: 24),

                  // Split screen: List of incidents on left, selected incident details on right
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Incidents Queue List
                        Expanded(
                          flex: 3,
                          child: _buildIncidentsQueue(),
                        ),
                        const SizedBox(width: 20),
                        
                        // Incident Details Panel / Chart Panel
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              if (_selectedIncident != null)
                                Expanded(child: _buildDetailsPanel())
                              else
                                Expanded(child: _buildAnalyticsChartPanel()),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 240,
      color: const Color(0xFF0F172A),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined, color: Color(0xFF06B6D4), size: 30),
              SizedBox(width: 10),
              Text(
                'BHAI CONTROL',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.0),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _buildSidebarItem(Icons.dashboard_outlined, 'Live Operations', true),
          _buildSidebarItem(Icons.people_outline, 'Volunteers', false),
          _buildSidebarItem(Icons.analytics_outlined, 'Historical Analytics', false),
          _buildSidebarItem(Icons.contact_phone_outlined, 'Helpline Manager', false),
          _buildSidebarItem(Icons.settings_outlined, 'Console Settings', false),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, bool isSelected) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFF06B6D4) : Colors.grey),
      title: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey)),
      tileColor: isSelected ? Colors.white.withOpacity(0.05) : null,
      onTap: () {},
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Response Center Dashboard', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text('Monitoring active safety signals in real-time.', style: TextStyle(color: Colors.grey)),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Export logs'),
              onPressed: () {},
            ),
            const SizedBox(width: 16),
            const CircleAvatar(
              backgroundColor: Color(0xFF06B6D4),
              child: Icon(Icons.person, color: Colors.white),
            )
          ],
        )
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Active Emergencies', '${_activeIncidents.length}', Colors.red)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Active Volunteers', '412', Colors.green)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Total Incidents Today', '14', Colors.blue)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Avg Dispatch Time', '1.8 Mins', Colors.cyan)),
      ],
    );
  }

  Widget _buildStatCard(String title, String val, Color highlight) {
    return Card(
      elevation: 0,
      color: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 8),
            Text(
              val,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: highlight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidentsQueue() {
    return Card(
      color: const Color(0xFF0F172A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Live Incident Dispatch Queue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          Expanded(
            child: _activeIncidents.isEmpty
                ? const Center(child: Text('All zones secure. No active SOS signals.'))
                : ListView.separated(
                    itemCount: _activeIncidents.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final inc = _activeIncidents[index];
                      final isSelected = _selectedIncident?['id'] == inc['id'];

                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: Colors.white.withOpacity(0.03),
                        title: Text(inc['user'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Location: ${inc['location']} | ${inc['time']}'),
                        trailing: const Icon(Icons.circle, color: Colors.red, size: 12),
                        onTap: () {
                          setState(() {
                            _selectedIncident = inc;
                          });
                        },
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailsPanel() {
    final inc = _selectedIncident!;
    return Card(
      color: const Color(0xFF0F172A),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(inc['user'] as String, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Chip(
                  label: const Text('SOS ACTIVE'),
                  backgroundColor: Colors.red.withOpacity(0.2),
                  labelStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                )
              ],
            ),
            const SizedBox(height: 10),
            Text('Profile Metadata: Age: ${inc['age']} | Blood Type: ${inc['blood_group']}'),
            Text('Medical Condition: ${inc['medical']}'),
            const SizedBox(height: 16),
            const Text('Emergency Contacts Alerted:', style: TextStyle(fontWeight: FontWeight.bold)),
            for (var contact in inc['contacts'] as List<String>) Text('- $contact'),
            const SizedBox(height: 16),
            Text('Nearby Volunteers Dispatched: ${inc['volunteers_dispatched']}'),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                    icon: const Icon(Icons.phone),
                    label: const Text('Call Local Police (112)'),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    icon: const Icon(Icons.check),
                    label: const Text('Mark Resolved'),
                    onPressed: () => _resolveIncident(inc['id'] as String),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsChartPanel() {
    return Card(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SOS Signal Frequency - Hourly Peak Analysis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 20,
                barTouchData: BarTouchData(enabled: false),
                titlesData: const FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: _bottomTitles,
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 5, color: Colors.cyan)]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 12, color: Colors.cyan)]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 18, color: Colors.red)]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 8, color: Colors.cyan)]),
                  BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 3, color: Colors.cyan)]),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  static Widget _bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.grey, fontSize: 10);
    String text;
    switch (value.toInt()) {
      case 0:
        text = '08:00';
        break;
      case 1:
        text = '12:00';
        break;
      case 2:
        text = '18:00';
        break;
      case 3:
        text = '22:00';
        break;
      case 4:
        text = '02:00';
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }
}
