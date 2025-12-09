import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // WARNA PANGANKU (Sesuai Web)
  static const Color primary = Color(0xFF10B981); // Hijau Emerald
  static const Color primaryDark = Color(0xFF047857); // Hijau Tua
  static const Color secondary = Color(0xFFECFDF5); // Hijau Muda
  static const Color background = Color(0xFFFFFFFF); // Putih Bersih
  static const Color textDark = Color(0xFF1F2937); // Abu Gelap
  static const Color textGrey = Color(0xFF6B7280); // Abu-abu teks

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

    // KONSISTENSI FONT: Clash Display (Judul) + Poppins (Isi)
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      // Judul Besar (Hero Section, Banner) -> Clash Display
      displayLarge: const TextStyle(
        fontFamily: 'ClashDisplay',
        fontWeight: FontWeight.bold,
      ),
      displayMedium: const TextStyle(
        fontFamily: 'ClashDisplay',
        fontWeight: FontWeight.bold,
      ),
      displaySmall: const TextStyle(
        fontFamily: 'ClashDisplay',
        fontWeight: FontWeight.bold,
      ),

      // Judul Halaman / Section -> Clash Display
      headlineLarge: const TextStyle(
        fontFamily: 'ClashDisplay',
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: const TextStyle(
        fontFamily: 'ClashDisplay',
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: const TextStyle(
        fontFamily: 'ClashDisplay',
        fontWeight: FontWeight.bold,
      ),

      // Judul AppBar / Card Title -> Clash Display
      titleLarge: const TextStyle(
        fontFamily: 'ClashDisplay',
        fontWeight: FontWeight.w600,
      ),

      // Sisanya (Body text, caption, button) otomatis tetap Poppins dari GoogleFonts
    ),

    // Style AppBar (Header Atas)
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: textDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'ClashDisplay', // [UPDATE] Judul AppBar pakai Clash Display
        color: textDark,
        fontSize: 20, // Sedikit diperbesar agar gagah
        fontWeight: FontWeight.w600,
      ),
    ),

    // Style Tombol (ElevatedButton)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: primary.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: GoogleFonts.poppins(
          // Tombol tetap Poppins agar jelas terbaca
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
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
    ),

    // Style Input Form
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error),
      ),
      labelStyle: const TextStyle(color: textGrey), // Poppins (Default)
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)), // Poppins (Default)
    ),
  );
}
