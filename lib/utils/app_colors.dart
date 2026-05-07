import 'package:flutter/material.dart';

class AppColors {
  // Primary palette - deep indigo + violet
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4A43D4);
  static const Color primaryLight = Color(0xFF9C97FF);

  // Accent
  static const Color accent = Color(0xFFFF6584);
  static const Color accentGold = Color(0xFFFFD166);

  // Background / Surface
  static const Color background = Color(0xFF0F0E17);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color card = Color(0xFF16213E);
  static const Color cardBorder = Color(0xFF2A2A4A);

  // Status colors
  static const Color applied = Color(0xFF4FC3F7);
  static const Color shortlisted = Color(0xFFAB47BC);
  static const Color interviewScheduled = Color(0xFFFFB74D);
  static const Color rejected = Color(0xFFEF5350);
  static const Color selected = Color(0xFF66BB6A);

  // Text
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFFB0B0C8);
  static const Color textHint = Color(0xFF6B6B8A);

  // Others
  static const Color divider = Color(0xFF2A2A4A);
  static const Color inputFill = Color(0xFF1E1E35);
  static const Color shimmerBase = Color(0xFF1E1E35);
  static const Color shimmerHighlight = Color(0xFF2A2A55);

  static Color statusColor(int index) {
    switch (index) {
      case 0:
        return applied;
      case 1:
        return shortlisted;
      case 2:
        return interviewScheduled;
      case 3:
        return rejected;
      case 4:
        return selected;
      default:
        return applied;
    }
  }
}

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accent = LinearGradient(
    colors: [Color(0xFFFF6584), Color(0xFFFF8C94)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient background = LinearGradient(
    colors: [Color(0xFF0F0E17), Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient card = LinearGradient(
    colors: [Color(0xFF1E1E35), Color(0xFF16213E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gold = LinearGradient(
    colors: [Color(0xFFFFD166), Color(0xFFFF9F1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
