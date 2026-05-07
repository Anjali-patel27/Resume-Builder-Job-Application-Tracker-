import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - Deep Professional Palette
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  
  static const Color accent = Color(0xFF10B981); // Emerald
  static const Color accentLight = Color(0xFF34D399);

  // Backgrounds - Neutral Professional Dark
  static const Color background = Color(0xFF0F172A); // Slate 900
  static const Color surface = Color(0xFF1E293B);    // Slate 800
  static const Color card = Color(0xFF1E293B);
  static const Color cardBorder = Color(0xFF334155); // Slate 700

  // Status Colors - Professional Tones
  static const Color applied = Color(0xFF3B82F6);      // Blue 500
  static const Color shortlisted = Color(0xFF8B5CF6); // Violet 500
  static const Color interview = Color(0xFFF59E0B);    // Amber 500
  static const Color rejected = Color(0xFFEF4444);     // Red 500
  static const Color selected = Color(0xFF10B981);     // Emerald 500

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);   // Slate 50
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color textHint = Color(0xFF64748B);      // Slate 500

  // Gradients
  static const LinearGradient mainGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color getStatusColor(int index) {
    switch (index) {
      case 0: return applied;
      case 1: return shortlisted;
      case 2: return interview;
      case 3: return rejected;
      case 4: return selected;
      default: return applied;
    }
  }
}
