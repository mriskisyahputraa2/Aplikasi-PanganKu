import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:panganku_mobile/core/constants/api_constants.dart';
import 'package:panganku_mobile/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Fungsi Login
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {
          'Accept': 'application/json', // Wajib agar Laravel tahu ini API
        },
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data);
      } else {
        // Jika error (401/422), ambil pesan errornya
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Login Gagal');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Fungsi Simpan Token ke HP (Agar tidak login ulang terus)
  Future<void> saveUserSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', user.token ?? '');
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);
  }

  // Fungsi Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    // Tembak API Logout Laravel (Opsional, biar token di server hangus)
    if (token != null) {
      try {
        await http.post(
          Uri.parse(ApiConstants.logout),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
      } catch (e) {
        // Ignore error saat logout
      }
    }

    // Hapus data di HP
    await prefs.clear();
  }
}
