import 'dart:io';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb

class ApiConstants {
  // LOGIKA OTOMATIS MEMILIH URL
  static String get baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:8000/api"; // Web Browser
    } else if (Platform.isAndroid) {
      // Cek apakah ini Emulator (biasanya device modelnya mengandung 'sdk')
      // Tapi untuk aman, kita default ke 10.0.2.2 untuk emulator
      // Jika pakai HP Fisik, Anda WAJIB ganti string ini manual ke IP Laptop (misal 192.168.1.X)
      return "http://10.0.2.2:8000/api";
    } else {
      return "http://127.0.0.1:8000/api"; // iOS Simulator / Lainnya
    }
  }

  // Endpoints
  static String get login => "$baseUrl/login";
  static String get register => "$baseUrl/register";
  static String get user => "$baseUrl/user";
  static String get logout => "$baseUrl/logout";
}
