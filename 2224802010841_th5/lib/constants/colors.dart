import 'package:flutter/cupertino.dart';

/// iOS-style color constants for the Notes app
class AppColors {
  // Primary
  static const Color primary = Color(0xFF007AFF); // iOS Blue
  static const Color primaryLight = Color(0xFF5AC8FA); // iOS Light Blue

  // Backgrounds
  static const Color background = Color(
    0xFFF2F2F7,
  ); // iOS System Group Background
  static const Color cardBackground = Color(0xFFFFFFFF); // White card
  static const Color secondaryBackground = Color(0xFFE5E5EA);

  // Text
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF8E8E93); // iOS System Grey
  static const Color textTertiary = Color(0xFFC7C7CC);

  // Semantic
  static const Color destructive = Color(0xFFFF3B30); // iOS Red
  static const Color success = Color(0xFF34C759); // iOS Green
  static const Color warning = Color(0xFFFF9500); // iOS Orange
  static const Color deadlineOverdue = Color(0xFFFF3B30); // Red for overdue
  static const Color deadlineUpcoming = Color(
    0xFFFF9500,
  ); // Orange for upcoming

  // Borders
  static const Color border = Color(0xFFD1D1D6);
  static const Color separator = Color(0xFFC6C6C8);

  // Pin
  static const Color pinned = Color(0xFFFFCC00); // iOS Yellow
}
