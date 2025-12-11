import 'package:flutter/material.dart';

class ToastService {
  static void showSuccess(BuildContext context, String message) {
    _showToast(
      context,
      message,
      const Color(0xFF10B981),
      Icons.check_circle_rounded,
    );
  }

  static void showError(BuildContext context, String message) {
    _showToast(context, message, const Color(0xFFEF4444), Icons.error_rounded);
  }

  static void showWarning(BuildContext context, String message) {
    _showToast(
      context,
      message,
      const Color(0xFFF59E0B),
      Icons.warning_rounded,
    );
  }

  static void _showToast(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              // [PERBAIKAN] Tambahkan ini agar lebar toast full
              width: double.infinity,

              padding: const EdgeInsets.fromLTRB(48, 12, 16, 12),
              constraints: const BoxConstraints(minHeight: 60),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getTitle(color),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Floating Icon Effect
            Positioned(
              bottom: 0,
              top: 0,
              left: 12,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 24, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Margin ini yang menentukan seberapa lebar toast dari pinggir layar
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static String _getTitle(Color color) {
    if (color == const Color(0xFF10B981)) return "Berhasil!";
    if (color == const Color(0xFFEF4444)) return "Gagal!";
    if (color == const Color(0xFFF59E0B)) return "Perhatian";
    return "Info";
  }
}
