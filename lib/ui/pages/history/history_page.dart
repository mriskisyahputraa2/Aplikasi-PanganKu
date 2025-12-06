import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:panganku_mobile/core/theme/app_theme.dart';
import 'package:panganku_mobile/providers/order_provider.dart';
import 'package:panganku_mobile/ui/widgets/order_card.dart';
import 'package:panganku_mobile/ui/pages/history/order_detail_page.dart'; // [1] Import Halaman Detail

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final List<Map<String, String>> _tabs = [
    {'label': 'Semua', 'val': 'all'},
    {'label': 'Belum Bayar', 'val': 'menunggu_pembayaran'},
    {'label': 'Diproses', 'val': 'diproses'},
    {'label': 'Dikirim', 'val': 'dikirim'},
    {'label': 'Selesai', 'val': 'selesai'},
    {'label': 'Batal', 'val': 'dibatalkan'},
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<OrderProvider>(context, listen: false).fetchOrders(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Riwayat Pesanan",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // FILTER TABS
          Container(
            height: 56,
            color: Colors.white,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final isActive =
                    Provider.of<OrderProvider>(context).currentStatus ==
                    tab['val'];

                return GestureDetector(
                  onTap: () => Provider.of<OrderProvider>(
                    context,
                    listen: false,
                  ).fetchOrders(status: tab['val']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? AppTheme.primary
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      tab['label']!,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // LIST ORDER
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  );
                }

                if (provider.orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Belum ada pesanan",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      provider.fetchOrders(status: provider.currentStatus),
                  color: AppTheme.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: provider.orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 0),
                    itemBuilder: (context, index) {
                      // [PERBAIKAN] Definisi Variabel 'order' disini
                      final order = provider.orders[index];

                      return OrderCard(
                        order: order, // Kirim data order ke card
                        onTap: () {
                          // [NAVIGASI] Pindah ke Halaman Detail
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  OrderDetailPage(orderId: order.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
