import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF202028); // Dark background
  static const Color glassWhite = Color(0x1FFFFFFF); // 12% opacity white
  static const Color accentColor = Color(0xFF6C63FF);

  static const Map<String, Color> categoryColors = {
    'Health': Color(0xFF69F0AE), // Green
    'Career': Color(0xFF40C4FF), // Blue
    'Finances': Color(0xFF7C4DFF), // Deep Purple
    'Growth': Color(0xFFFF4081), // Pink
    'Romance': Color(0xFFFF5252), // Red
    'Social': Color(0xFFFFAB40), // Orange
    'Fun': Color(0xFFFFD740), // Yellow
    'Environment': Color(0xFF18FFFF), // Cyan
  };

  static final TextStyle heading1 = GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static final TextStyle heading2 = GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static final TextStyle bodyText = GoogleFonts.outfit(
    fontSize: 16,
    color: Colors.white70,
  );

  static final BoxDecoration glassDecoration = BoxDecoration(
    color: glassWhite,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withOpacity(0.1)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 16,
        spreadRadius: 4,
      ),
    ],
  );

  static Widget glassCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: glassDecoration,
          child: child,
        ),
      ),
    );
  }

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accentColor,
      textTheme: TextTheme(
        headlineLarge: heading1,
        headlineMedium: heading2,
        bodyMedium: bodyText,
      ),
      useMaterial3: true,
    );
  }
}
