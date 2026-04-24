import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/checkout_screen.dart';
import 'screens/main_shell.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const TechStoreApp());
}

class TechStoreApp extends StatelessWidget {
  const TechStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Premium Light Palette ──
    const primaryColor = Color(0xFF1A1A2E);    // Deep navy
    const accentColor = Color(0xFF0077ED);      // Apple blue
    const surfaceColor = Color(0xFFF8F9FC);     // Off-white
    const cardColor = Colors.white;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: Brightness.light,
      primary: accentColor,
      onPrimary: Colors.white,
      secondary: const Color(0xFF5856D6),       // Purple accent
      surface: surfaceColor,
      onSurface: primaryColor,
      surfaceContainerLowest: cardColor,
      surfaceContainerLow: const Color(0xFFF2F3F7),
      surfaceContainer: const Color(0xFFECEDF1),
      surfaceContainerHigh: const Color(0xFFE8E9ED),
      outline: const Color(0xFFD1D5DB),
      outlineVariant: const Color(0xFFE5E7EB),
    );

    return MaterialApp(
      title: 'Tech Store Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: surfaceColor,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).copyWith(
          headlineLarge: GoogleFonts.poppins(fontWeight: FontWeight.w800, color: primaryColor),
          headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: primaryColor),
          headlineSmall: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: primaryColor),
          titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: primaryColor),
          titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: primaryColor),
          bodyLarge: GoogleFonts.poppins(color: const Color(0xFF374151)),
          bodyMedium: GoogleFonts.poppins(color: const Color(0xFF6B7280)),
          bodySmall: GoogleFonts.poppins(color: const Color(0xFF9CA3AF)),
          labelLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: surfaceColor,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          surfaceTintColor: Colors.transparent,
          foregroundColor: primaryColor,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: primaryColor,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: cardColor,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: colorScheme.outlineVariant.withAlpha(128)),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colorScheme.surfaceContainerLow,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: accentColor, width: 1.5),
          ),
          hintStyle: GoogleFonts.poppins(color: const Color(0xFF9CA3AF), fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
            textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            foregroundColor: accentColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            side: BorderSide(color: accentColor.withAlpha(77)),
            textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide.none,
          elevation: 0,
          backgroundColor: colorScheme.surfaceContainerLow,
          selectedColor: accentColor,
          labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
          secondaryLabelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
          showCheckmark: false,
        ),
        dividerTheme: DividerThemeData(
          color: colorScheme.outlineVariant.withAlpha(128),
          thickness: 1,
          space: 0,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: primaryColor,
          contentTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainShell(),
        '/checkout': (context) => const CheckoutScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
