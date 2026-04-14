import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryText = Color(0xFF1E293B);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color primaryBlue = Color(0xFF2563EB); // like the search button in image
  static const Color background = Color(0xFFF8FAFC);
  
  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: background,
    primaryColor: primaryBlue,
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: primaryText),
      titleTextStyle: TextStyle(
        color: primaryText,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  static LinearGradient weatherGradient(String iconCode) {
    if (iconCode.contains('02') || iconCode.contains('03') || iconCode.contains('04')) {
      // Mây: BlueGrey
      return const LinearGradient(
        colors: [Color(0xFF607D8B), Color(0xFF90A4AE)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (iconCode.contains('09') || iconCode.contains('10')) {
      // Mưa: Blue
      return const LinearGradient(
        colors: [Color(0xFF1E88E5), Color(0xFF64B5F6)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (iconCode.contains('11')) {
      // Sấm chớp: DeepPurple
      return const LinearGradient(
        colors: [Color(0xFF512DA8), Color(0xFF7E57C2)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (iconCode.contains('13')) {
      // Tuyết: Cyan
      return const LinearGradient(
        colors: [Color(0xFF00BCD4), Color(0xFF4DD0E1)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else if (iconCode.contains('01n')) {
      // Đêm: Indigo
      return const LinearGradient(
        colors: [Color(0xFF303F9F), Color(0xFF5C6BC0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
    
    // Mặc định nắng (01d): Nền cam nắng 
    return const LinearGradient(
      colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }
}
