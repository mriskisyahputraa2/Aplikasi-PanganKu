import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:panganku_mobile/core/theme/app_theme.dart';
import 'package:panganku_mobile/data/models/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // 1. Tentukan Warna & Teks Status
    Color statusColor;
    Color statusBg;
    String statusText = order.status.replaceAll('_', ' ').toUpperCase();
    String actionText = "Lihat Detail"; // Default

    switch (order.status) {
      case 'menunggu_pembayaran':
        statusColor = const Color(0xFFD97706); // Amber Dark
        statusBg = const Color(0xFFFFFBEB); // Amber Light
        actionText = "Bayar Sekarang";
        break;
      case 'menunggu_verifikasi':
        statusColor = const Color(0xFF2563EB); // Blue
        statusBg = const Color(0xFFEFF6FF);
        break;
      case 'diproses':
        statusColor = const Color(0xFF0D9488); // Teal
        statusBg = const Color(0xFFF0FDFA);
        break;
      case 'dikirim':
      case 'siap_diambil':
        statusColor = const Color(0xFF7C3AED); // Violet
        statusBg = const Color(0xFFF5F3FF);
        actionText = "Lacak Pesanan";
        break;
      case 'selesai':
        statusColor = const Color(0xFF059669); // Emerald
        statusBg = const Color(0xFFECFDF5);
        actionText = "Beli Lagi";
        break;
      case 'dibatalkan':
        statusColor = const Color(0xFFDC2626); // Red
        statusBg = const Color(0xFFFEF2F2);
        break;
      default:
        statusColor = Colors.grey;
        statusBg = Colors.grey.shade50;
    }

    // Ambil info produk pertama
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final otherCount = order.items.length - 1;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            // HEADER: Tanggal & Status
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order.createdAtFormatted,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.2)),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 0.5),

            // CONTENT: Gambar & Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Produk
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      color: Colors.grey.shade50,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: firstItem?.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: firstItem!.imageUrl!,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            )
                          : const Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Detail Teks
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstItem?.productName ??
                              "Pesanan #${order.orderNumber}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (otherCount > 0)
                          Text(
                            "+ $otherCount produk lainnya",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          )
                        else
                          Text(
                            "${firstItem?.quantity} Pack",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormatter.format(order.totalAmount),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // FOOTER: Tombol Aksi (Jika status Batal, sembunyikan tombol)
            if (order.status != 'dibatalkan')
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: order.status == 'menunggu_pembayaran'
                            ? AppTheme.primary
                            : Colors.grey.shade300,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: order.status == 'menunggu_pembayaran'
                          ? AppTheme.primary
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      actionText,
                      style: TextStyle(
                        color: order.status == 'menunggu_pembayaran'
                            ? Colors.white
                            : AppTheme.textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
