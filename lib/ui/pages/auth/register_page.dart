import 'package:flutter/material.dart';
import 'package:panganku_mobile/core/theme/app_theme.dart';
// import 'package:provider/provider.dart';
// import 'package:panganku_mobile/providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fitur Register akan segera hadir!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background, // Abu-abu sangat muda
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
                      // Dekorasi lingkaran transparan
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

                      // Konten Header
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
                                  ), // Placeholder agar judul di tengah
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Hero(
                              tag: 'logo',
                              child: Image.asset(
                                'assets/images/logo.png', // Pastikan logo versi putih/kontras jika ada, atau default
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
                        "Lengkapi data diri Anda untuk mulai berbelanja.",
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
                          prefixIcon: const Icon(
                            Icons.lock_reset,
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
                      ElevatedButton(
                        onPressed: _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 5,
                          shadowColor: AppTheme.primary.withOpacity(0.4),
                        ),
                        child: const Text(
                          "Daftar Sekarang",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. FOOTER TEXT
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
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
