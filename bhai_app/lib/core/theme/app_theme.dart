import 'dart:ui';
import 'package:flutter/material.dart';

class AppTheme {
  // Brand color scheme: Deep protection blue & glowing emergency crimson
  static const Color primaryDark = Color(0xFF0F172A); // Slate 900
  static const Color secondaryDark = Color(0xFF1E293B); // Slate 800
  static const Color accentCrimson = Color(0xFFEF4444); // Crimson SOS
  static const Color accentCyan = Color(0xFF06B6D4); // Safety Cyan
  
  static const Color primaryLight = Color(0xFFF8FAFC); // Slate 50
  static const Color secondaryLight = Color(0xFFF1F5F9); // Slate 100

  // Standard Linear Gradients
  static const Gradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF1E1E38)],
  );

  static const Gradient lightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
  );

  static const Gradient sosGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
  );

  // Modern Dark Mode ColorScheme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryDark,
      scaffoldBackgroundColor: const Color(0xFF020617), // Deep slate black
      cardColor: secondaryDark,
      colorScheme: const ColorScheme.dark(
        primary: accentCyan,
        secondary: accentCrimson,
        surface: Color(0xFF0B1329),
        error: accentCrimson,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
        titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 16.0, color: Color(0xFF94A3B8)), // Slate 400
        bodyMedium: TextStyle(fontSize: 14.0, color: Color(0xFF64748B)), // Slate 500
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  // Modern Light Mode ColorScheme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryLight,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      cardColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: accentCyan,
        secondary: accentCrimson,
        surface: Colors.white,
        error: accentCrimson,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: 0.5),
        titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
        bodyLarge: TextStyle(fontSize: 16.0, color: Color(0xFF475569)), // Slate 600
        bodyMedium: TextStyle(fontSize: 14.0, color: Color(0xFF64748B)), // Slate 500
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF0F172A)),
        titleTextStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
      ),
    );
  }
}

// Reusable Glassmorphism Card Widget
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry padding;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.blur = 20.0,
    this.opacity = 0.08,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white : Colors.black;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: baseColor.withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: baseColor.withOpacity(isDark ? 0.12 : 0.08),
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
