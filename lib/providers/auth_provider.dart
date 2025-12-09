import 'dart:io';
import 'package:flutter/material.dart';
import 'package:panganku_mobile/data/models/user_model.dart';
import 'package:panganku_mobile/data/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // LOGIN
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await _authService.login(email, password);
      _user = user;
      await _authService.saveUserSession(user);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _setLoading(false);
      return false;
    }
  }

  // REGISTER
  Future<bool> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Hanya panggil service, tidak auto login
      await _authService.register(name, email, password, passwordConfirmation);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _setLoading(false);
      return false;
    }
  }

  // UPDATE PROFILE
  Future<bool> updateProfile(String name, File? photo) async {
    if (_user == null) {
      _errorMessage = "User not authenticated.";
      return false;
    }

    _setLoading(true);
    try {
      // 1. Panggil service, dapatkan user model dengan data parsial (tanpa token)
      final partialUpdate = await _authService.updateProfile(name, photo);

      // 2. Gabungkan data baru ke user state yang ada menggunakan copyWith
      // Ini memastikan token dan role yang ada tidak hilang
      _user = _user!.copyWith(
        name: partialUpdate.name,
        // ValueGetter memastikan kita bisa set photoUrl ke null secara eksplisit
        photoUrl: () => partialUpdate.photoUrl,
      );

      // 3. Simpan sesi lengkap yang sudah diperbarui
      await _authService.saveUserSession(_user!);

      _errorMessage = null;
      _setLoading(false);
      notifyListeners(); // Beri tahu UI tentang perubahan
      return true;
    } catch (e) {
      print("Provider Update Error: $e");
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _setLoading(false);
      return false;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  // CHECK SESSION (Auto Login)
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final name = prefs.getString('user_name');
    final email = prefs.getString('user_email');
    final photo = prefs.getString('user_photo');

    if (token != null && name != null) {
      _user = UserModel.fromMap({
        'id': 0, // ID tidak disimpan di prefs, jadi default
        'name': name,
        'email': email ?? '',
        'photo_url': photo,
      }, token: token);
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
