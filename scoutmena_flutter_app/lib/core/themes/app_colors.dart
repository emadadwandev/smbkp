import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF4285F4);
  static const Color primaryGreen = Color.fromARGB(243, 22, 201, 61);

  // Secondary Colors
  static const Color lightBlue = Color.fromARGB(255, 127, 225, 250);
  static const Color lightGreen = Color(0xFF8BC995);

  // Neutral Colors (Dark Theme)
  static const Color black = Color.fromARGB(255, 29, 27, 27);
  static const Color darkGray1 = Color(0xFF3D3D3D);
  static const Color darkGray2 = Color.fromARGB(255, 102, 99, 99);
  static const Color lightGray = Color(0xFFDADCE0);
  static const Color white = Color(0xFFFFFFFF);

  // Status Colors
  static const Color error = Color.fromARGB(255, 234, 68, 53);
  static const Color warning = Color(0xFFFBBC04);
  static const Color success = Color(0xFF34A853);
  static const Color info = Color(0xFF4285F4);

  // Additional UI Colors
  static const Color cardBackground = darkGray1;
  static const Color surfaceColor = darkGray2;
  static const Color dividerColor = lightGray;
  static const Color textPrimary = white;
  static const Color textSecondary = lightGray;
  static const Color scaffoldBackground = black;
  static const Color orange = Color(0xFFFFA500);

  // Light Theme Colors
  static const Color lightScaffoldBackground = Color(0xFFF8F9FA);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightSurfaceColor = Color(0xFFF1F3F4);
  static const Color lightTextPrimary = Color(0xFF202124);
  static const Color lightTextSecondary = Color(0xFF5F6368);
  static const Color lightDividerColor = Color(0xFFDADCE0);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
