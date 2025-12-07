import 'dart:async';
import 'dart:io'; // Wajib untuk Platform
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart'; // Wajib untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:panganku_mobile/core/theme/app_theme.dart';
import 'package:panganku_mobile/providers/order_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailPage extends StatefulWidget {
  final int orderId;
  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedProof;
  Timer? _timer;
  String _timeLeft = "";

  // Nomor WA Admin (Default)
  final String _adminPhone = "628123456789";

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<OrderProvider>(
        context,
        listen: false,
      ).fetchOrderDetail(widget.orderId),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- LOGIC 1: TIMER MUNDUR (Sesuai File Anda) ---
  void _startTimer(String createdAtRaw) {
    if (createdAtRaw.isEmpty) return;
    try {
      final created = DateTime.parse(createdAtRaw);
      final deadline = created.add(const Duration(minutes: 30));

      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final now = DateTime.now();
        final difference = deadline.difference(now);

        if (difference.isNegative) {
          timer.cancel();
          if (mounted) setState(() => _timeLeft = "Waktu Habis");
        } else {
          final minutes = difference.inMinutes.toString().padLeft(2, '0');
          final seconds = (difference.inSeconds % 60).toString().padLeft(
            2,
            '0',
          );
          if (mounted) setState(() => _timeLeft = "$minutes : $seconds");
        }
      });
    } catch (e) {
      print("Error Timer: $e");
    }
  }

  // --- LOGIC 2: FIX URL GAMBAR (Sesuai File Anda) ---
  String _fixImageUrl(String? url) {
    if (url == null) return '';
    // Lakukan penggantian HANYA jika berjalan di emulator Android
    if (!kIsWeb && Platform.isAndroid) {
      if (url.contains('localhost') || url.contains('127.0.0.1')) {
        return url.replaceFirst(RegExp(r'localhost|127\.0\.0\.1'), '10.0.2.2');
      }
    }
    // Untuk platform lain (web, desktop, iOS), URL asli harusnya sudah benar
    return url;
  }

  // --- ACTIONS ---

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Nomor Order disalin!"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _contactAdmin(String orderNumber) async {
    final url = Uri.parse(
      "https://wa.me/$_adminPhone?text=Halo Admin PanganKU, saya butuh bantuan untuk pesanan #$orderNumber",
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _pickImage() async {
    // Cek Web agar tidak crash (Opsional, tapi aman)
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Upload file hanya tersedia di Aplikasi Mobile."),
        ),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (image != null) {
      setState(() {
        _selectedProof = File(image.path);
      });
    }
  }

  void _uploadProofConfirmed() async {
    if (_selectedProof == null) return;

    final provider = Provider.of<OrderProvider>(context, listen: false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Mengupload bukti...")));

    final success = await provider.uploadProof(widget.orderId, _selectedProof!);

    if (success && mounted) {
      setState(() => _selectedProof = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Berhasil diupload!"),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? "Gagal upload"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmAction(String action, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _executeAction(action);
            },
            child: const Text(
              "Ya, Lanjutkan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _executeAction(String action) async {
    final provider = Provider.of<OrderProvider>(context, listen: false);
    bool success = false;

    if (action == 'complete')
      success = await provider.completeOrder(widget.orderId);
    if (action == 'cancel')
      success = await provider.cancelOrder(widget.orderId);

    if (success && mounted) {
      String msg = action == 'complete'
          ? "Pesanan Selesai. Terima Kasih!"
          : "Pesanan Dibatalkan.";
      Color color = action == 'complete' ? Colors.green : Colors.red;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Detail Pesanan",
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
        centerTitle: true,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          final order = provider.selectedOrder;

          if (provider.isLoading && order == null)
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          if (order == null)
            return const Center(child: Text("Gagal memuat data"));

          // --- LOGIC STATUS ---
          bool isPending = order.status == 'menunggu_pembayaran';
          bool showUpload =
              isPending &&
              order.paymentProofUrl == null &&
              order.paymentMethod != 'tunai';
          bool showCancel = isPending;
          bool showComplete =
              order.status == 'dikirim' || order.status == 'siap_diambil';

          if (isPending && _timer == null && order.createdAtRaw.isNotEmpty) {
            _startTimer(order.createdAtRaw);
          }

          // --- TEMA STATUS PREMIUM ---
          Color themeColor = AppTheme.primary;
          String statusText = order.status.replaceAll('_', ' ').toUpperCase();

          switch (order.status) {
            case 'menunggu_pembayaran':
              themeColor = const Color(0xFFF59E0B);
              break; // Orange
            case 'menunggu_verifikasi':
              themeColor = const Color(0xFF3B82F6);
              break; // Biru
            case 'diproses':
              themeColor = const Color(0xFF9333EA);
              break; // Ungu
            case 'dikirim':
            case 'siap_diambil':
              themeColor = const Color(0xFFA855F7);
              break; // Ungu Terang
            case 'selesai':
              themeColor = const Color(0xFF10B981);
              break; // Hijau
            case 'dibatalkan':
              themeColor = const Color(0xFFEF4444);
              break; // Merah
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. STATUS CARD (GRADIENT PREMIUM)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [themeColor, themeColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: themeColor.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Status Pesanan",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Order #${order.orderNumber}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _copyToClipboard(order.orderNumber),
                              child: const Icon(
                                Icons.copy,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isPending && order.paymentMethod != 'tunai') ...[
                        const SizedBox(height: 24),
                        const Text(
                          "Sisa Waktu Pembayaran",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _timeLeft.isEmpty ? "..." : _timeLeft,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Konten Utama (Overlap ke atas)
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // 2. RINCIAN PRODUK (GAMBAR WAJIB MUNCUL DISINI)
                        _buildCard(
                          title: "Rincian Produk",
                          child: Column(
                            children: [
                              ...order.items.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 64,
                                        width: 64,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        // [PENERAPAN FIX GAMBAR]
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: _fixImageUrl(
                                              item.imageUrl,
                                            ), // Panggil Fungsi
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                const Center(
                                                  child: SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  ),
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(
                                                      Icons.image_not_supported,
                                                      color: Colors.grey,
                                                    ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.productName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              maxLines: 2,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "${item.quantity} x ${currencyFormatter.format(item.price)}",
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        currencyFormatter.format(
                                          item.price * item.quantity,
                                        ),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Total Pembayaran",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    currencyFormatter.format(order.totalAmount),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: themeColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 3. PENGIRIMAN
                        _buildCard(
                          title: "Informasi Pengiriman",
                          child: Column(
                            children: [
                              _buildInfoRow(
                                "Metode",
                                order.deliveryType == 'pickup'
                                    ? "Ambil Sendiri (Pickup)"
                                    : "Diantar Kurir (Delivery)",
                              ),
                              const SizedBox(height: 12),
                              if (order.deliveryType == 'delivery')
                                _buildInfoRow(
                                  "Alamat",
                                  order.shippingAddress ?? '-',
                                ), // Statis (Tanpa Link Maps)
                              if (order.deliveryType == 'pickup')
                                const Text(
                                  "Lokasi Toko: Jl. Politeknik No. 1 (Dekat Kampus)",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              if (order.trackingNumber != null) ...[
                                const Divider(height: 24),
                                _buildInfoRow(
                                  "Resi / Kurir",
                                  order.trackingNumber!,
                                  isHighlight: true,
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 4. PEMBAYARAN
                        _buildCard(
                          title: "Informasi Pembayaran",
                          child: Column(
                            children: [
                              _buildInfoRow(
                                "Metode Bayar",
                                order.paymentMethod.toUpperCase(),
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                "Status",
                                order.paymentStatus == 'paid'
                                    ? "LUNAS"
                                    : "BELUM LUNAS",
                                valueColor: order.paymentStatus == 'paid'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // 5. UPLOAD BUKTI (PREVIEW)
                        if (showUpload) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Bukti Pembayaran Belum Diupload",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (_selectedProof != null && !kIsWeb) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _selectedProof!,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: _pickImage,
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                          ),
                                          child: const Text("Ganti Foto"),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: _uploadProofConfirmed,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                          child: const Text("Kirim Bukti"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: _pickImage,
                                      icon: const Icon(
                                        Icons.camera_alt,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        "Upload Bukti Transfer",
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // INFO BUKTI DITERIMA
                        if (isPending && order.paymentProofUrl != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue[100]!),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Bukti pembayaran sedang diverifikasi",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // TOMBOL TERIMA
                        if (showComplete) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _confirmAction(
                                'complete',
                                'Pesanan Diterima?',
                                'Pastikan barang sudah sesuai.',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Pesanan Diterima",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // TOMBOL WA & BATAL
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _contactAdmin(order.orderNumber),
                                icon: const Icon(
                                  Icons.chat_bubble_outline,
                                  size: 18,
                                ),
                                label: const Text("Hubungi Admin"),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  side: const BorderSide(color: Colors.green),
                                  foregroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            if (showCancel) ...[
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _confirmAction(
                                    'cancel',
                                    'Batalkan Pesanan?',
                                    'Stok akan dikembalikan.',
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    side: const BorderSide(color: Colors.red),
                                    foregroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text("Batalkan"),
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 40),
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

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isAddress = false,
    bool isHighlight = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
                color:
                    valueColor ??
                    (isHighlight ? AppTheme.primary : AppTheme.textDark),
              ),
              maxLines: isAddress ? 3 : 1,
              overflow: isAddress ? TextOverflow.ellipsis : null,
            ),
          ),
        ],
      ),
    );
  }
}
