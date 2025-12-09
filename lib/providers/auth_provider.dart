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

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // 1. LOGIN
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await _authService.login(email, password);

      // Simpan data user ke State Provider
      _user = user;

      // Simpan data user ke Local Storage (HP) agar tetap login saat aplikasi ditutup
      await _authService.saveUserSession(user);

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _setLoading(false);
      return false;
    }
  }

  // 2. REGISTER
  Future<bool> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Panggil service register
      // Kita TIDAK menyimpan sesi di sini, agar user diarahkan login manual
      await _authService.register(name, email, password, passwordConfirmation);

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _setLoading(false);
      return false;
    }
  }

  // 3. UPDATE PROFILE
  Future<bool> updateProfile(String name, File? photo) async {
    _setLoading(true);
    try {
      // Panggil service untuk update ke server
      final updatedUser = await _authService.updateProfile(name, photo);

      // [CRUCIAL] Update state _user di memori aplikasi dengan data baru
      // Ini yang membuat tampilan Profil langsung berubah tanpa refresh
      _user = updatedUser;
      _errorMessage = null;

      _setLoading(false);
      return true;
    } catch (e) {
      print("Provider Update Error: $e");
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _setLoading(false);
      return false;
    }
  }

  // 4. LOGOUT
  Future<void> logout() async {
    await _authService.logout();
    _user = null; // Hapus data user dari memori
    notifyListeners();
  }

  // 5. CHECK SESSION (Auto Login saat Splas Screen)
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final name = prefs.getString('user_name');
    final email = prefs.getString('user_email');
    final photo = prefs.getString('user_photo');

    if (token != null && name != null) {
      // Restore user dari penyimpanan lokal HP
      _user = UserModel(
        id: 0, // ID dummy tidak masalah, nanti fetch ulang jika perlu
        name: name,
        email: email ?? '',
        token: token,
        photoUrl: photo,
      );
    }
    notifyListeners();
  }

  // Helper Loading
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
