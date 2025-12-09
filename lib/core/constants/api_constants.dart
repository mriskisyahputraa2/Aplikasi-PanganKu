import 'dart:io';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb

class ApiConstants {
  // LOGIKA OTOMATIS MEMILIH HOST
  static String get _host {
    if (kIsWeb) {
      return "http://127.0.0.1:8000"; // Web Browser
    } else if (Platform.isAndroid) {
      // Jika pakai HP Fisik, Anda WAJIB ganti string ini manual ke IP Laptop (misal 192.168.1.X)
      return "http://10.0.2.2:8000"; // Android Emulator
    } else {
      return "http://127.0.0.1:8000"; // iOS Simulator / Lainnya
    }
  }

  // BASE URLS
  static String get baseUrl => "$_host/api";
  static String get storageBaseUrl => _host;

  // Endpoints
  static String get login => "$baseUrl/login";
  static String get register => "$baseUrl/register";
  static String get user => "$baseUrl/user";
  static String get logout => "$baseUrl/logout";
}
