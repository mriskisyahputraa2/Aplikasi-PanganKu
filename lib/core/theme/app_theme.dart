import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // WARNA PANGANKU (Sesuai Web)
  static const Color primary = Color(0xFF10B981); // Hijau Emerald
  static const Color primaryDark = Color(
    0xFF047857,
  ); // Hijau Tua (untuk hover/tekan)
  static const Color secondary = Color(
    0xFFECFDF5,
  ); // Hijau Muda (untuk background item)
  static const Color background = Color(0xFFFFFFFF); // Putih Bersih
  static const Color textDark = Color(0xFF1F2937); // Abu Gelap (hampir hitam)
  static const Color textGrey = Color(0xFF6B7280); // Abu-abu teks biasa
  static const Color error = Color(0xFFEF4444); // Merah Error

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: background,
    primaryColor: primary,

    // Skema Warna Global
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      surface: Colors.white,
      background: background,
      error: error,
    ),

    // Font Default (Poppins)
    textTheme: GoogleFonts.poppinsTextTheme(),

    // Style AppBar (Header Atas)
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: textDark, // Warna Teks/Icon AppBar
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textDark,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Style Tombol (ElevatedButton) -> Hijau PanganKU
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white, // Teks Putih
        elevation: 2,
        shadowColor: primary.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Sudut membulat
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Style Tombol Garis (OutlinedButton)
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),

    // Style Input Form (Mirip Web: Abu muda, Fokus Hijau)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF9FAFB), // Gray-50
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)), // Gray-200
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error),
      ),
      labelStyle: const TextStyle(color: textGrey),
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
    ),
  );
}
