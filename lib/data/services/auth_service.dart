import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:panganku_mobile/core/constants/api_constants.dart';
import 'package:panganku_mobile/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<UserModel> login(String email, String password) async {
    try {
      print("Mengirim request ke: ${ApiConstants.login}");

      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded', // Tambahkan ini
        },
        body: {
          'email': email,
          'password': password,
          'device_name': 'flutter_mobile', // Opsional tapi bagus untuk Sanctum
        },
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Validasi: Pastikan respon sukses
        if (data['success'] == false) {
          throw Exception(data['message'] ?? 'Login Gagal');
        }

        // Parsing JSON ke Model (Logic baru di user_model.dart akan menangani strukturnya)
        return UserModel.fromJson(data);
      } else {
        // Handle Error 401/422
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Gagal Login (Cek Email/Password)',
        );
      }
    } catch (e) {
      print("Error Login: $e");
      rethrow;
    }
  }

  Future<void> saveUserSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', user.token ?? '');
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);
    if (user.photoUrl != null) {
      await prefs.setString('user_photo', user.photoUrl!);
    }
    print("Sesi disimpan! Token: ${user.token}");
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // [BARU] Fungsi Register
  Future<UserModel> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'device_name': 'flutter_mobile',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Parsing JSON ke Model (Sama seperti login)
        return UserModel.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);

        // Handle Validasi Laravel (Misal: Email sudah ada)
        if (errorData['errors'] != null) {
          Map<String, dynamic> errors = errorData['errors'];
          // Ambil pesan error pertama saja biar simpel
          String firstError = errors.values.first[0];
          throw Exception(firstError);
        }

        throw Exception(errorData['message'] ?? 'Registrasi Gagal');
      }
    } catch (e) {
      rethrow;
    }
  }
}
