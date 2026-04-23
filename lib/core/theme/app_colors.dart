import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color primary = Color(0xFFFF6B00);
  static const Color primaryDark = Color(0xFFD94F00);
  static const Color secondary = Color(0xFFFFB347);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFF6B00), Color(0xFFD94F00)],
  );

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF1A1A1A);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
}
