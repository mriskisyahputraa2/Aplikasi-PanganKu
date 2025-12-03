class ApiConstants {
  // --- OPSI 1: JIKA RUN DI BROWSER (CHROME/EDGE) ---
  static const String baseUrl = "http://127.0.0.1:8000/api";
  static const String imageUrl = "http://127.0.0.1:8000/storage/";

  // --- OPSI 2: JIKA RUN DI EMULATOR ANDROID ---
  // static const String baseUrl = "http://10.0.2.2:8000/api";
  // static const String imageUrl = "http://10.0.2.2:8000/storage/";

  // --- OPSI 3: JIKA RUN DI HP FISIK (WIFI SAMA) ---
  // static const String baseUrl = "http://192.168.1.X:8000/api"; // Ganti X dengan IP Laptop
  // static const String imageUrl = "http://192.168.1.X:8000/storage/";
  // Endpoints
  static const String login = "$baseUrl/login";
  static const String register = "$baseUrl/register";
  static const String user = "$baseUrl/user";
  static const String logout = "$baseUrl/logout";
}
