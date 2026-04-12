import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary - Orange (food theme)
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8C42);
  static const Color primaryDark = Color(0xFFE55A2B);

  // Secondary - Deep Teal
  static const Color secondary = Color(0xFF1A535C);
  static const Color secondaryLight = Color(0xFF247B7B);

  // Background - Dark Mode Premium
  static const Color background = Color(0xFF0D1117);
  static const Color backgroundLight = Color(0xFF161B22);
  static const Color surface = Color(0xFF21262D);
  static const Color surfaceLight = Color(0xFF30363D);

  // Accent - Golden (for ratings/highlights)
  static const Color accent = Color(0xFFFFD166);
  static const Color accentDark = Color(0xFFE6B84D);

  // Text
  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textTertiary = Color(0xFF6E7681);

  // Status
  static const Color success = Color(0xFF3FB950);
  static const Color warning = Color(0xFFD29922);
  static const Color error = Color(0xFFF85149);
  static const Color info = Color(0xFF58A6FF);

  // Border
  static const Color border = Color(0xFF30363D);
  static const Color borderLight = Color(0xFF484F58);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [background, backgroundLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF21262D), Color(0xFF161B22)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glassmorphism overlay
  static Color glassOverlay = Colors.white.withValues(alpha: 0.05);
  static Color glassBorder = Colors.white.withValues(alpha: 0.1);
}
