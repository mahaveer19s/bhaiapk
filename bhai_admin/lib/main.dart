import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/dashboard/presentation/admin_dashboard.dart';

void main() {
  runApp(
    const ProviderScope(
      child: BhaiAdminApp(),
    ),
  );
}

class BhaiAdminApp extends StatelessWidget {
  const BhaiAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BHAI Response Center Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617), // Deep slate black
        cardColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF06B6D4), // Cyan
          secondary: Color(0xFFEF4444), // Crimson SOS
          surface: Color(0xFF0B1329),
        ),
      ),
      home: const AdminDashboard(),
    );
  }
}
