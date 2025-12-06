import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk Clipboard
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
  File? _selectedProof; // [3] Preview Gambar
  Timer? _timer;
  String _timeLeft = "";

  // [5] Nomor WA Admin (Default) - Idealnya dari API
  // Untuk sementara kita hardcode atau bisa diambil dari provider jika sudah ada API Settings
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

  // [2] LOGIKA TIMER (Berdasarkan Waktu Server)
  void _startTimer(String createdAtRaw) {
    if (createdAtRaw.isEmpty) return;
    try {
      final created = DateTime.parse(createdAtRaw);
      final deadline = created.add(
        const Duration(minutes: 30),
      ); // Batas 30 Menit

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

  // [7] COPY NO ORDER
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Nomor Order disalin!"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // [6] BUKA GOOGLE MAPS
  void _openMaps(String address) async {
    final query = Uri.encodeComponent(address);
    final googleMapsUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$query",
    );
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal membuka peta")));
    }
  }

  // [5] HUBUNGI ADMIN (WA)
  void _contactAdmin(String orderNumber) async {
    final url = Uri.parse(
      "https://wa.me/$_adminPhone?text=Halo Admin PanganKU, saya butuh bantuan untuk pesanan #$orderNumber",
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // PILIH GAMBAR (Belum Upload)
  void _pickImage() async {
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

  // [3] UPLOAD BUKTI (Setelah Preview)
  void _uploadProofConfirmed() async {
    if (_selectedProof == null) return;

    final provider = Provider.of<OrderProvider>(context, listen: false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Mengupload bukti...")));

    final success = await provider.uploadProof(widget.orderId, _selectedProof!);

    if (success && mounted) {
      setState(() => _selectedProof = null); // Reset preview
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

  // [4] & [9] DIALOG KONFIRMASI (Action)
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

  // Helper URL Gambar Localhost
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

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
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

          // Start Timer
          if (isPending && _timer == null && order.createdAtRaw.isNotEmpty) {
            _startTimer(order.createdAtRaw);
          }

          // [8] WARNA STATUS
          Color statusColor = Colors.grey;
          switch (order.status) {
            case 'menunggu_pembayaran':
              statusColor = Colors.orange;
              break;
            case 'diproses':
              statusColor = Colors.blue;
              break;
            case 'dikirim':
              statusColor = Colors.purple;
              break;
            case 'selesai':
              statusColor = Colors.green;
              break;
            case 'dibatalkan':
              statusColor = Colors.red;
              break;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HEADER STATUS
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        order.status.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "No. Order: ${order.orderNumber}",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _copyToClipboard(order.orderNumber),
                            child: const Icon(
                              Icons.copy,
                              size: 14,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                      if (isPending && order.paymentMethod != 'tunai') ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Sisa Waktu: ${_timeLeft.isEmpty ? '...' : _timeLeft}",
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. LIST PRODUK
                const Text(
                  "Rincian Produk",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ...order.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[100],
                                ),
                                // [1] FIX FOTO PRODUK
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: _fixImageUrl(
                                      item.imageUrl,
                                    ), // Pakai Helper
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                    ),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Pembayaran",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            currencyFormatter.format(order.totalAmount),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 3. INFO PENGIRIMAN (Dinamis + Maps)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        "Metode",
                        order.deliveryType == 'pickup'
                            ? "Ambil Sendiri (Pickup)"
                            : "Diantar Kurir (Delivery)",
                      ),
                      const SizedBox(height: 12),
                      if (order.deliveryType == 'delivery')
                        GestureDetector(
                          onTap: () => _openMaps(
                            order.shippingAddress ?? '',
                          ), // [6] Link Maps
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Alamat",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  order.shippingAddress ?? '-',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    color: AppTheme.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (order.deliveryType == 'pickup')
                        const Text(
                          "Lokasi Toko: Jl. Politeknik No. 1 (Dekat Kampus)",
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 4. UPLOAD BUKTI (PREVIEW DULU)
                if (showUpload) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.shade100),
                    ),
                    child: Column(
                      children: [
                        if (_selectedProof != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
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
                                  child: const Text("Ganti Foto"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _uploadProofConfirmed,
                                  child: const Text("Kirim Bukti"),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          const Text(
                            "Belum ada bukti pembayaran",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text("Pilih Foto Bukti"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // [9] KONFIRMASI TERIMA
                if (showComplete)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _confirmAction(
                        'complete',
                        'Pesanan Diterima?',
                        'Pastikan barang sudah sesuai dan dalam kondisi baik.',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                      ),
                      child: const Text("Pesanan Diterima"),
                    ),
                  ),

                const SizedBox(height: 16),

                // [4] BATALKAN PESANAN
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _contactAdmin(order.orderNumber),
                        icon: const Icon(Icons.chat, color: Colors.green),
                        label: const Text(
                          "Hubungi Admin",
                          style: TextStyle(color: Colors.green),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                    if (showCancel) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _confirmAction(
                            'cancel',
                            'Batalkan Pesanan?',
                            'Stok produk akan dikembalikan ke toko.',
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text(
                            "Batalkan",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
