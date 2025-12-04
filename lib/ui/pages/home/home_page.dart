import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Untuk format Rupiah
import 'package:panganku_mobile/core/theme/app_theme.dart';
import 'package:panganku_mobile/providers/cart_provider.dart';
import 'package:panganku_mobile/providers/auth_provider.dart';
import 'package:panganku_mobile/providers/product_provider.dart';
import 'package:panganku_mobile/ui/widgets/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Panggil data produk saat halaman dibuka
    Future.microtask(
      () =>
          Provider.of<ProductProvider>(context, listen: false).fetchProducts(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    // Kategori Statis (Bisa dibuat dinamis nanti jika mau)
    final categories = [
      {'name': 'Semua', 'icon': Icons.grid_view},
      {'name': 'Ayam', 'icon': Icons.egg_alt},
      {'name': 'Daging', 'icon': Icons.lunch_dining},
      {'name': 'Ikan', 'icon': Icons.set_meal},
      {'name': 'Bumbu', 'icon': Icons.soup_kitchen},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => Provider.of<ProductProvider>(
            context,
            listen: false,
          ).fetchProducts(),
          color: AppTheme.primary,
          child: CustomScrollView(
            slivers: [
              // 1. HEADER & SEARCH BAR
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Sapaan User
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Halo, ${user?.name ?? 'Pelanggan'} 👋",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const Text(
                                "Cari bahan segar apa hari ini?",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.notifications_none,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // [DESIGN BARU] SEARCH BAR (Floating Pill)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            30,
                          ), // Bulat penuh
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Cari ayam, daging, bumbu...",
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppTheme.primary,
                            ),
                            suffixIcon: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.tune,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. HERO BANNER (Branding Toko)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF059669), AppTheme.primary],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Dekorasi Lingkaran
                      Positioned(
                        right: -20,
                        top: -20,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        top: 30,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "PanganKU Fresh",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Kualitas Terbaik\nDari Peternak",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "100% Halal & Higienis",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Gambar Ilustrasi (Aset)
                      Positioned(
                        right: 10,
                        bottom: 0,
                        child: Image.asset(
                          'assets/images/logo.png', // Pastikan logo transparan
                          height: 100,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. KATEGORI
              SliverToBoxAdapter(
                child: Container(
                  height: 90,
                  margin: const EdgeInsets.only(top: 24, bottom: 10),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isFirst = index == 0;
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Column(
                          children: [
                            Container(
                              height: 56,
                              width: 56,
                              decoration: BoxDecoration(
                                color: isFirst
                                    ? AppTheme.primary
                                    : Colors.white,
                                shape: BoxShape.circle,
                                border: isFirst
                                    ? null
                                    : Border.all(color: Colors.grey[200]!),
                                boxShadow: isFirst
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primary.withOpacity(
                                            0.4,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                cat['icon'] as IconData,
                                color: isFirst
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              cat['name'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isFirst
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isFirst
                                    ? AppTheme.primary
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 4. JUDUL PRODUK
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Produk Pilihan",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Lihat Semua",
                        style: TextStyle(fontSize: 12, color: AppTheme.primary),
                      ),
                    ],
                  ),
                ),
              ),

              // 5. GRID PRODUK (REAL DATA)
              Consumer<ProductProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (provider.products.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(child: Text("Belum ada produk tersedia")),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72, // Rasio Kartu
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final product = provider.products[index];
                        return ProductCard(
                          name: product.name,
                          category: product.category,
                          price: product.price,
                          stock: product.stock, // [BARU] Kirim stok
                          imageUrl: product.imageUrl ?? '',

                          onTap: () {
                            /* Ke detail */
                          },

                          // [LOGIKA ADD KE CART]
                          onAdd: () async {
                            final cartProvider = Provider.of<CartProvider>(
                              context,
                              listen: false,
                            );
                            final success = await cartProvider.addToCart(
                              product.id,
                            );

                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    "Berhasil masuk keranjang!",
                                  ),
                                  backgroundColor: AppTheme.primary,
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      }, childCount: provider.products.length),
                    ),
                  );
                },
              ),

              // Spacer Bawah
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        ),
      ),
    );
  }
}
