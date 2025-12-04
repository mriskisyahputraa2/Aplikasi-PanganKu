import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:panganku_mobile/core/theme/app_theme.dart';
import 'package:panganku_mobile/providers/auth_provider.dart';
// import 'package:panganku_mobile/ui/pages/main_page.dart';
import 'package:panganku_mobile/ui/pages/auth/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controller Input
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Fungsi Register
  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Panggil fungsi register di Provider
      final success = await authProvider.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _confirmPasswordController.text,
      );

      if (!mounted) return;

      if (success) {
        // 1. Tampilkan Pesan Sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registrasi Berhasil! Silakan Login."),
            backgroundColor: AppTheme.primary,
            duration: Duration(seconds: 2), // Tampil agak lama
          ),
        );

        // 2. [UBAH ARAH] Pindah ke Halaman Login
        // pushAndRemoveUntil: Hapus halaman register dari history agar tidak bisa di-back
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? "Registrasi Gagal."),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER HIJAU MELENGKUNG
            Stack(
              children: [
                Container(
                  height: size.height * 0.35, // 35% tinggi layar
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Dekorasi Lingkaran Transparan
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 50,
                        left: -30,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),

                      // Konten Header (Tombol Back & Logo)
                      SafeArea(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_back_ios_new,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  const Spacer(),
                                  const Text(
                                    "Buat Akun",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  const SizedBox(
                                    width: 48,
                                  ), // Penyeimbang layout
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Logo dengan Hero Animation
                            Hero(
                              tag: 'logo',
                              child: Image.asset(
                                'assets/images/logo.png',
                                height: 80,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 2. FORM CARD (MENGAMBANG)
            Transform.translate(
              offset: const Offset(0, -40), // Naik ke atas menutupi header
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Daftar Sekarang",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Lengkapi data diri Anda untuk mulai belanja.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textGrey,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Input Nama
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        validator: (val) =>
                            val!.isEmpty ? "Nama wajib diisi" : null,
                        decoration: InputDecoration(
                          labelText: "Nama Lengkap",
                          hintText: "Contoh: Budi Santoso",
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: AppTheme.primary,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Input Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (val) =>
                            !val!.contains('@') ? "Email tidak valid" : null,
                        decoration: InputDecoration(
                          labelText: "Alamat Email",
                          hintText: "nama@email.com",
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: AppTheme.primary,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Input Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        textInputAction: TextInputAction.next,
                        validator: (val) =>
                            val!.length < 6 ? "Minimal 6 karakter" : null,
                        decoration: InputDecoration(
                          labelText: "Kata Sandi",
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: AppTheme.primary,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(
                              () => _isPasswordVisible = !_isPasswordVisible,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Input Confirm Password
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_isPasswordVisible,
                        textInputAction: TextInputAction.done,
                        validator: (val) {
                          if (val != _passwordController.text)
                            return "Sandi tidak sama";
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Ulangi Kata Sandi",
                          // Menggunakan icon lock biasa agar aman
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: AppTheme.primary,
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Tombol Daftar
                      Consumer<AuthProvider>(
                        builder: (context, auth, child) {
                          return ElevatedButton(
                            onPressed: auth.isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 5,
                              shadowColor: AppTheme.primary.withOpacity(0.4),
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
                                : const Text(
                                    "Daftar Sekarang",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. FOOTER LINK
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Sudah punya akun? ",
                      style: TextStyle(color: AppTheme.textGrey),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Masuk",
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
