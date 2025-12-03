import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:panganku_mobile/core/theme/app_theme.dart';
import 'package:panganku_mobile/providers/auth_provider.dart';
// import 'package:panganku_mobile/ui/pages/auth/register_page.dart'; // (Nanti di-uncomment saat buat register)

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller untuk mengambil teks input
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Key untuk validasi form
  final _formKey = GlobalKey<FormState>();

  // State untuk sembunyikan/tampilkan password
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi Login
  void _handleLogin() async {
    // 1. Cek validasi input (apakah kosong/tidak sesuai format)
    if (_formKey.currentState!.validate()) {
      // 2. Panggil Provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // 3. Eksekusi Login
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // 4. Cek Hasil
      if (!mounted) return; // Cek jika widget masih ada di layar

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login Berhasil! Selamat Datang."),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // TODO: Navigasi ke HomePage
        // Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? "Login Gagal. Periksa koneksi.",
            ),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil ukuran layar
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND IMAGE FULL SCREEN
          Container(
            height: size.height,
            width: size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                // Pastikan gambar ini ada di folder assets/images/
                image: AssetImage('assets/images/login_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. GRADIENT OVERLAY (Agar teks terbaca jelas)
          Container(
            height: size.height,
            width: size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1), // Atas agak transparan
                  Colors.white.withOpacity(0.9), // Tengah mulai putih
                  Colors.white, // Bawah putih solid
                ],
                stops: const [0.0, 0.4, 0.6], // Titik perubahan warna
              ),
            ),
          ),

          // 3. KONTEN HALAMAN (Scrollable agar aman saat keyboard muncul)
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),

                      // LOGO
                      Hero(
                        // Efek animasi halus saat pindah halaman
                        tag: 'logo',
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 80,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // TEKS JUDUL
                      Text(
                        "Selamat Datang!",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Masuk untuk mulai belanja ayam segar.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),

                      const SizedBox(height: 48),

                      // INPUT EMAIL
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (val) {
                          if (val == null || val.isEmpty)
                            return "Email wajib diisi";
                          if (!val.contains('@')) return "Email tidak valid";
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: "Alamat Email",
                          prefixIcon: Icon(Icons.email_outlined),
                          hintText: "contoh@email.com",
                        ),
                      ),

                      const SizedBox(height: 20),

                      // INPUT PASSWORD
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible, // Sembunyikan teks
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) =>
                            _handleLogin(), // Enter langsung login
                        validator: (val) {
                          if (val == null || val.isEmpty)
                            return "Password wajib diisi";
                          if (val.length < 6) return "Minimal 6 karakter";
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Kata Sandi",
                          prefixIcon: const Icon(Icons.lock_outline),
                          // Tombol mata (Show/Hide)
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),

                      // TOMBOL LUPA PASSWORD
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Navigasi ke Lupa Password
                          },
                          child: const Text(
                            "Lupa Kata Sandi?",
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // TOMBOL LOGIN (Dengan Loading State)
                      Consumer<AuthProvider>(
                        builder: (context, auth, child) {
                          return ElevatedButton(
                            onPressed: auth.isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              elevation: 4, // Bayangan tombol
                            ),
                            child: auth.isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text("Masuk ke Akun"),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // LINK REGISTER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Belum punya akun? ",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          GestureDetector(
                            onTap: () {
                              // TODO: Navigasi ke Register Page
                              // Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage()));
                            },
                            child: const Text(
                              "Daftar Gratis",
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20), // Jarak aman bawah
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
