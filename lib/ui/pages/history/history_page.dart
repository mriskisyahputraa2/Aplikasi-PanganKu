import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:panganku_mobile/core/theme/app_theme.dart';
import 'package:panganku_mobile/providers/order_provider.dart';
import 'package:panganku_mobile/ui/widgets/order_card.dart';
import 'package:panganku_mobile/ui/pages/history/order_detail_page.dart'; // Pastikan import ini ada

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // Tab Filter Status
  final List<Map<String, String>> _tabs = [
    {'label': 'Semua', 'val': 'all'},
    {'label': 'Belum Bayar', 'val': 'menunggu_pembayaran'},
    {'label': 'Diproses', 'val': 'diproses'},
    {'label': 'Dikirim', 'val': 'dikirim'},
    {'label': 'Selesai', 'val': 'selesai'},
    {'label': 'Batal', 'val': 'dibatalkan'},
  ];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load data pesanan saat halaman dibuka
    Future.microtask(
      () => Provider.of<OrderProvider>(context, listen: false).fetchOrders(),
    );

    // Listener untuk infinite scroll
    _scrollController.addListener(() {
      // Panggil loadMoreOrders jika scroll mendekati akhir
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        Provider.of<OrderProvider>(context, listen: false).loadMoreOrders();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Background Abu lembut
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
        automaticallyImplyLeading: false, // Hilangkan tombol back di root tab
      ),
      body: Column(
        children: [
          // 1. FILTER TABS
          Container(
            height: 60,
            color: Colors.white,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                // Cek status aktif dari provider
                final isActive =
                    Provider.of<OrderProvider>(context).currentStatus ==
                        tab['val'];

                return GestureDetector(
                  onTap: () {
                    // Fetch ulang data berdasarkan status yang dipilih
                    Provider.of<OrderProvider>(
                      context,
                      listen: false,
                    ).fetchOrders(status: tab['val']!);
                  },
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
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. LIST PESANAN
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, provider, child) {
                // State Loading (hanya untuk load awal)
                if (provider.isLoading && provider.orders.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  );
                }

                // State Kosong
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

                // State Ada Data
                return RefreshIndicator(
                  onRefresh: () =>
                      provider.fetchOrders(status: provider.currentStatus),
                  color: AppTheme.primary,
                  child: ListView.separated(
                    controller: _scrollController, // Tambahkan controller
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.orders.length +
                        (provider.isLoadMoreRunning ? 1 : 0),
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 16), // Jarak antar kartu
                    itemBuilder: (context, index) {
                      // Tampilkan loader di item terakhir jika sedang load more
                      if (index == provider.orders.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child:
                                CircularProgressIndicator(color: AppTheme.primary),
                          ),
                        );
                      }
                      final order = provider.orders[index];

                      return OrderCard(
                        order: order,
                        onTap: () {
                          // Navigasi ke Halaman Detail
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
