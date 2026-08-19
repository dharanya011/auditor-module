import 'package:flutter/material.dart';

class AppColors {
  // Dark Navy Sidebar (matching reference screenshot)
  static const Color sidebarBg = Color(0xFF0F172A);
  static const Color sidebarActive = Color(0xFF4F46E5);
  static const Color sidebarActiveBg = Color(0xFF4F46E5);
  static const Color sidebarHover = Color(0xFF1E293B);
  static const Color sidebarText = Color(0xFF94A3B8);
  static const Color sidebarTextActive = Color(0xFFFFFFFF);

  // Background & Surfaces
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color tableHeaderBg = Color(0xFFF8FAFC);

  // Primary Typography
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Accents & Statuses
  static const Color accent = Color(0xFF4F46E5);
  static const Color accentLight = Color(0xFFEEF2FF);
  static const Color verified = Color(0xFF10B981);
  static const Color pending = Color(0xFFF59E0B);
  static const Color issue = Color(0xFFEF4444);
  static const Color critical = Color(0xFFDC2626);

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
