import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CleanAuthorityTheme {
  // Brand Colors
  static const Color primary = Color(0xFF0D47A1); // Enterprise Blue
  static const Color accent = Color(0xFF29B6F6);
  
  // Surfaces & Background
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF1F5F9); // For subtle contrast
  static const Color surfaceContainerHigh = Color(0xFFE2E8F0); // For denser areas

  // Status & Utility Colors
  static const Color success = Color(0xFF10B981);
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFFFEE2E2);

  // Text Colors
  static const Color onSurface = Color(0xFF0F172A); // Slate 900
  static const Color onSurfaceVariant = Color(0xFF64748B); // Slate 500

  // Spacing & Geometry
  static const double baseSpacing = 8.0;
  static const double borderRadius = 12.0;

  static ThemeData get lightTheme {
    final textTheme = _buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        secondary: accent,
        onSecondary: Colors.white,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerHighest: surfaceContainerLow,
        onSurfaceVariant: onSurfaceVariant,
        error: error,
        onError: Colors.white,
        errorContainer: errorContainer,
        onErrorContainer: error,
      ),
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2, // Subtle tonal shadow instead of stark
          shadowColor: primary.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: surfaceContainerHigh),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // Text Field (Input)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: textTheme.bodyMedium?.copyWith(color: onSurfaceVariant),
        hintStyle: textTheme.bodyMedium?.copyWith(color: onSurfaceVariant.withOpacity(0.6)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: surfaceContainerHigh),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: error, width: 2),
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: onSurfaceVariant,
        showUnselectedLabels: true,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: textTheme.labelSmall,
      ),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 1, // subtle corporative elevation
        shadowColor: Colors.black.withOpacity(0.05),
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: surface,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    // Outfit for headlines
    final displayFont = GoogleFonts.outfitTextTheme();
    // Open Sans for body
    final bodyFont = GoogleFonts.openSansTextTheme();

    return bodyFont.copyWith(
      displayLarge: displayFont.displayLarge?.copyWith(fontWeight: FontWeight.bold, color: onSurface),
      displayMedium: displayFont.displayMedium?.copyWith(fontWeight: FontWeight.bold, color: onSurface),
      displaySmall: displayFont.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: onSurface),
      headlineLarge: displayFont.headlineLarge?.copyWith(fontWeight: FontWeight.w600, color: onSurface),
      headlineMedium: displayFont.headlineMedium?.copyWith(fontWeight: FontWeight.w600, color: onSurface),
      headlineSmall: displayFont.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: onSurface),
      titleLarge: displayFont.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: onSurface),
      titleMedium: displayFont.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: onSurface),
      titleSmall: displayFont.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: onSurface),
      
      bodyLarge: bodyFont.bodyLarge?.copyWith(color: onSurface),
      bodyMedium: bodyFont.bodyMedium?.copyWith(color: onSurface),
      bodySmall: bodyFont.bodySmall?.copyWith(color: onSurfaceVariant),
      
      labelLarge: bodyFont.labelLarge?.copyWith(fontWeight: FontWeight.w500),
      labelMedium: bodyFont.labelMedium?.copyWith(fontWeight: FontWeight.w500),
      labelSmall: bodyFont.labelSmall?.copyWith(fontWeight: FontWeight.w500),
    );
  }
}
