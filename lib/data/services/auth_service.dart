import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:panganku_mobile/core/constants/api_constants.dart';
import 'package:panganku_mobile/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // 1. LOGIN
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Accept': 'application/json'},
        body: {'email': email, 'password': password, 'device_name': 'mobile'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final userMap = body['data']['user'];
        final token = body['data']['access_token'];

        if (token == null) {
          throw Exception("Token tidak ditemukan dalam respon server.");
        }

        return UserModel.fromMap(userMap, token: token);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Login Gagal');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 2. REGISTER
  Future<UserModel> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {'Accept': 'application/json'},
        body: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'device_name': 'mobile',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final userMap = body['data']['user'];
        final token = body['data']['access_token'];
        return UserModel.fromMap(userMap, token: token);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Registrasi Gagal');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 3. UPDATE PROFILE (MULTIPART)
  Future<UserModel> updateProfile(String name, File? photoFile) async {
    final uri = Uri.parse("${ApiConstants.baseUrl}/user/update");

    var request = http.MultipartRequest('POST', uri);

    // Header Token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    // Field Teks
    request.fields['name'] = name;

    // Field File (Foto)
    if (photoFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('photo', photoFile.path),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userMap = data['data']['user'];
        // Kembalikan user model parsial, provider yang akan menggabungkannya
        return UserModel.fromMap(userMap);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal update profil');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 4. SIMPAN SESI
  Future<void> saveUserSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    // Pastikan token tidak null sebelum disimpan
    if (user.token != null) {
      await prefs.setString('auth_token', user.token!);
    }
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);
    if (user.photoUrl != null) {
      await prefs.setString('user_photo', user.photoUrl!);
    } else {
      await prefs.remove('user_photo');
    }
  }

  // 5. LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

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
        print("Logout API error: $e");
      }
    }
    await prefs.clear();
  }
}
