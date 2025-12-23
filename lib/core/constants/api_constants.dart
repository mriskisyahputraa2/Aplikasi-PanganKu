// API sudah terhubung dengan hosting

import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get _host {
    // Langsung tembak ke domain hosting yang sudah live
    return "https://panganku.mrkasir.com";
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

// Lokal
// import 'dart:io';
// import 'package:flutter/foundation.dart';

// class ApiConstants {
//   static String get _host {
//     if (kIsWeb) {
//       return "http://127.0.0.1:8000";
//     } else if (Platform.isAndroid) {
//       // (Khusus HP Fisik Android)
//       return "http://192.168.100.58:8000";
//     } else {
//       return "http://127.0.0.1:8000";
//     }
//   }

//   // Bagian bawah ini tetap sama
//   static String get baseUrl => "$_host/api";
//   static String get storageBaseUrl => _host;

//   static String get login => "$baseUrl/login";
//   static String get register => "$baseUrl/register";
//   static String get user => "$baseUrl/user";
//   static String get logout => "$baseUrl/logout";
// }
