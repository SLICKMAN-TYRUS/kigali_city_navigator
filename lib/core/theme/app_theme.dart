// core/theme/app_theme.dart
// Global app styling using Montserrat font
// This ensures consistent look across all screens

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand colors - blue and green theme for Kigali city services
  static const Color primaryColor = Color(0xFF1565C0); // Blue
  static const Color secondaryColor = Color(0xFF2E7D32); // Green
  static const Color accentColor = Color(0xFFFF8F00); // Amber
  static const Color errorColor = Color(0xFFC62828); // Red

  // Background colors
  static const Color scaffoldBackground = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  static ThemeData get lightTheme {
    // Get the base Montserrat text theme
    final baseTextTheme = GoogleFonts.montserratTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldBackground,
      primarySwatch: Colors.blue,

      // Apply Montserrat font globally
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.montserrat(
            fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary),
        displayMedium: GoogleFonts.montserrat(
            fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary),
        titleLarge: GoogleFonts.montserrat(
            fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: GoogleFonts.montserrat(fontSize: 16, color: textPrimary),
        bodyMedium: GoogleFonts.montserrat(fontSize: 14, color: textSecondary),
        labelLarge: GoogleFonts.montserrat(
            fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
      ),

      // AppBar styling
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryColor,
        titleTextStyle: GoogleFonts.montserrat(
            fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Card styling
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: cardBackground,
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: GoogleFonts.montserrat(color: textSecondary),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle:
              GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Chips for categories
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade200,
        selectedColor: primaryColor.withOpacity(0.2),
        labelStyle: GoogleFonts.montserrat(fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
