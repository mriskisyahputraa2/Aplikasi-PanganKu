import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:panganku_mobile/providers/setting_provider.dart';
import 'package:provider/provider.dart';
import 'package:panganku_mobile/core/theme/app_theme.dart';
import 'package:panganku_mobile/providers/auth_provider.dart';
import 'package:panganku_mobile/ui/pages/auth/login_page.dart';
import 'package:panganku_mobile/ui/pages/profile/edit_profile_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Keluar Akun",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Ya, Keluar",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (r) => false,
        );
      }
    }
  }

  void _contactSupport(BuildContext context) async {
    // [AMBIL DARI PROVIDER]
    final settings = Provider.of<SettingProvider>(context, listen: false);

    // Format nomor (hapus 0 depan, ganti 62)
    String phone = settings.adminPhone.replaceAll(RegExp(r'\D'), '');
    if (phone.startsWith('0')) phone = "62${phone.substring(1)}";

    final url = Uri.parse("https://wa.me/$phone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Akun Saya",
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          final user = auth.user;
          final photoUrl = user?.photoUrl;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                // 1. HEADER PROFIL (DENGAN AKSEN HIJAU)
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        padding: const EdgeInsets.all(3), // Border gap
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // [WARNA TEMA] Border Hijau PanganKU
                          border: Border.all(
                            color: AppTheme.primary.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: photoUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: photoUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Container(
                                    color: AppTheme.primary.withOpacity(0.1),
                                    child: const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: AppTheme.primary.withOpacity(0.1),
                                  child: const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppTheme.primary,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.name ?? "Pengguna",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user?.email ?? "-",
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 2. MENU LIST (STYLE BARU)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Pengaturan Akun",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                _buildCleanMenuItem(
                  icon: Icons.person_outline_rounded,
                  title: "Edit Profil",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  ),
                ),

                const SizedBox(height: 32),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Bantuan",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                _buildCleanMenuItem(
                  icon: Icons.support_agent_rounded,
                  title: "Pusat Bantuan",
                  onTap: () => _contactSupport(context),
                ),

                const SizedBox(height: 40),

                // TOMBOL LOGOUT (SOFT RED)
                InkWell(
                  onTap: () => _handleLogout(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Keluar Aplikasi",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget Helper Menu
  Widget _buildCleanMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      // [WARNA TEMA] Efek tekan hijau muda
      highlightColor: AppTheme.primary.withOpacity(0.1),
      splashColor: AppTheme.primary.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          children: [
            // [WARNA TEMA] Icon Hijau dengan Background Hijau Muda
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
