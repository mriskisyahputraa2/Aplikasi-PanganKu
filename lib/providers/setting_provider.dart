import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:panganku_mobile/core/constants/api_constants.dart';

class SettingProvider with ChangeNotifier {
  // Default values (jika gagal fetch)
  String _appName = "PanganKU";
  String _adminPhone = "628123456789";
  String _storeAddress = "Memuat alamat...";
  String _csEmail = "info@panganku.com";

  String get appName => _appName;
  String get adminPhone => _adminPhone;
  String get storeAddress => _storeAddress;
  String get csEmail => _csEmail;

  // Fetch dari API
  Future<void> fetchSettings() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/settings"),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final data = jsonResponse['data'];

        _appName = data['app_name'] ?? _appName;
        _adminPhone = data['admin_phone'] ?? _adminPhone;
        _storeAddress = data['store_address'] ?? _storeAddress;
        _csEmail = data['cs_email'] ?? _csEmail;

        notifyListeners();
      }
    } catch (e) {
      print("Gagal load settings: $e");
    }
  }
}
