import 'dart:async';
import 'package:flutter/material.dart';

class ToastService {
  // Variabel untuk menyimpan overlay yang sedang aktif agar bisa ditumpuk/diganti
  static OverlayEntry? _overlayEntry;
  static Timer? _timer;

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
    // 1. Hapus toast lama jika masih ada
    _removeToast();

    // 2. Buat OverlayEntry baru
    _overlayEntry = OverlayEntry(
      builder: (context) => _TopToastWidget(
        message: message,
        color: color,
        icon: icon,
        onDismiss: _removeToast,
      ),
    );

    // 3. Tampilkan ke layar
    // Menggunakan try-catch untuk keamanan jika context sudah tidak valid
    try {
      Overlay.of(context).insert(_overlayEntry!);
    } catch (e) {
      // Handle jika dipanggil saat screen sudah dispose
      _overlayEntry = null;
      return;
    }

    // 4. Set timer untuk menghilangkannya otomatis setelah 3 detik
    _timer = Timer(const Duration(seconds: 3), () {
      _removeToast();
    });
  }

  // Fungsi untuk membersihkan toast
  static void _removeToast() {
    if (_overlayEntry != null && _overlayEntry!.mounted) {
      _overlayEntry?.remove();
    }
    _overlayEntry = null;
    _timer?.cancel();
  }
}

// WIDGET KHUSUS UNTUK ANIMASI
class _TopToastWidget extends StatefulWidget {
  final String message;
  final Color color;
  final IconData icon;
  final VoidCallback onDismiss;

  const _TopToastWidget({
    required this.message,
    required this.color,
    required this.icon,
    required this.onDismiss,
  });

  @override
  State<_TopToastWidget> createState() => _TopToastWidgetState();
}

class _TopToastWidgetState extends State<_TopToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // Dua animasi: Scale (Ukuran) dan Fade (Transparansi)
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Setup Animasi
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500), // Durasi 'Pop' yang pas
      vsync: this,
    );

    // 1. Animasi Membesar (Scale) dengan efek membal sedikit (BackOut)
    // Mulai dari setengah ukuran (0.5) ke ukuran penuh (1.0)
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack, // Kunci efek 'Pop' yang membal
      ),
    );

    // 2. Animasi Transparansi (Fade)
    // Mulai dari tidak terlihat (0.0) ke terlihat jelas (1.0)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut, // Muncul perlahan
      ),
    );

    // Jalankan animasi masuk
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil tinggi SafeArea atas (Notch/Status Bar)
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 10, // Posisi di bawah status bar
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        // Menerapkan Animasi Scale dan Fade secara bersamaan
        child: ScaleTransition(
          scale: _scaleAnimation,
          alignment:
              Alignment.topCenter, // Penting: Membesar dari titik tengah atas
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Dismissible(
              key: UniqueKey(),
              direction:
                  DismissDirection.up, // Bisa di-swipe ke atas untuk dismiss
              onDismissed: (_) => widget.onDismiss(),
              child: _buildToastContent(), // Memanggil fungsi UI konten
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi helper untuk membangun UI Kapsul (agar kode build lebih bersih)
  Widget _buildToastContent() {
    return Center(
      child: Container(
        // Konfigurasi Ukuran Kapsul
        constraints: const BoxConstraints(
          minHeight: 60,
          minWidth: 300,
          maxWidth: 400,
        ),
        padding: const EdgeInsets.fromLTRB(70, 12, 16, 12),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(50), // Sangat bulat (Pill Shape)
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Konten Teks
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTitle(widget.color),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),

            // Icon di Kiri
            Positioned(
              left: -54, // Posisi icon relatif terhadap padding teks
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, size: 24, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle(Color color) {
    if (color == const Color(0xFF10B981)) return "Berhasil";
    if (color == const Color(0xFFEF4444)) return "Gagal";
    return "Info";
  }
}
