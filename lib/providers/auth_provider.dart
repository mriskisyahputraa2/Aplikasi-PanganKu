import 'package:flutter/material.dart';
import 'package:panganku_mobile/data/models/user_model.dart';
import 'package:panganku_mobile/data/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Getter agar UI bisa membaca data (tapi tidak bisa ubah langsung)
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Fungsi Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null; // Reset error

    try {
      // 1. Panggil Service
      final user = await _authService.login(email, password);

      // 2. Simpan data di memory
      _user = user;

      // 3. Simpan sesi di HP (biar gak login ulang terus)
      await _authService.saveUserSession(user);

      _setLoading(false);
      return true; // Berhasil
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      _setLoading(false);
      return false; // Gagal
    }
  }

  // Fungsi Logout
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  // Fungsi Cek Status Login saat Aplikasi Dibuka (Auto Login)
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final name = prefs.getString('user_name');
    final email = prefs.getString('user_email');

    if (token != null && name != null && email != null) {
      // Restore user dari memori HP
      _user = UserModel(
        id: 0,
        name: name,
        email: email,
        token: token,
      ); // ID 0 sementara, nanti bisa fetch profile
    }
    notifyListeners();
  }

  // Helper untuk ubah loading state & update UI
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners(); // Beritahu semua halaman yang pakai provider ini untuk refresh
  }
}
