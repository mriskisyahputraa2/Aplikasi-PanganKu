import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:panganku_mobile/core/theme/app_theme.dart';
import 'package:panganku_mobile/providers/auth_provider.dart';
import 'package:panganku_mobile/providers/product_provider.dart';
import 'package:panganku_mobile/providers/cart_provider.dart';
import 'package:panganku_mobile/ui/widgets/product_card.dart';
import 'package:panganku_mobile/ui/pages/product/product_detail_page.dart';
import 'package:panganku_mobile/ui/pages/product/catalog_page.dart';
import 'package:panganku_mobile/ui/pages/cart/cart_page.dart'; // Import Cart Page

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final PageController _bannerController = PageController();
  int _currentBanner = 0;
  Timer? _timer;

  // Data Banner Statis
  final List<Map<String, dynamic>> _banners = [
    {
      "color": [const Color(0xFF065F46), const Color(0xFF10B981)], // Hijau
      "title": "Promo Gajian",
      "subtitle": "Diskon Daging\nHingga 30%",
      "image": "assets/images/logo.png",
    },
    {
      "color": [const Color(0xFFC2410C), const Color(0xFFFB923C)], // Orange
      "title": "Gratis Ongkir",
      "subtitle": "Belanja Hemat\nTanpa Batas",
      "image": "assets/icons/chicken.png",
    },
    {
      "color": [const Color(0xFF1E40AF), const Color(0xFF60A5FA)], // Biru
      "title": "Paket Sayur",
      "subtitle": "Masak Sehat\nMulai 15Rb",
      "image": "assets/icons/broccoli.png",
    },
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      productProvider.fetchCategories();
      productProvider.fetchProducts();
      // Pastikan cart juga di-load agar badge angka muncul benar
      Provider.of<CartProvider>(context, listen: false).getCart();
    });
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_bannerController.hasClients) {
        int nextPage = _currentBanner + 1;
        if (nextPage >= _banners.length) nextPage = 0;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _handleSearch(String query) {
    Provider.of<ProductProvider>(
      context,
      listen: false,
    ).fetchProducts(query: query);
  }

  void _handleCategorySelect(String slug) {
    Provider.of<ProductProvider>(
      context,
      listen: false,
    ).fetchProducts(query: _searchController.text, category: slug);
  }

  String _getCategoryIconPath(String name) {
    final n = name.toLowerCase();
    if (n.contains('semua') || n.contains('all'))
      return 'assets/icons/list.png';
    if (n.contains('sayap')) return 'assets/icons/chicken-wings.png';
    if (n.contains('fillet') || n.contains('dada'))
      return 'assets/icons/chicken-breast.png';
    if (n.contains('jeroan') || n.contains('daging') || n.contains('sapi'))
      return 'assets/icons/meat.png';
    if (n.contains('ayam')) return 'assets/icons/chicken.png';
    if (n.contains('ikan')) return 'assets/icons/fish.png';
    if (n.contains('telur')) return 'assets/icons/eggs.png';
    if (n.contains('beras')) return 'assets/icons/rice.png';
    if (n.contains('minyak')) return 'assets/icons/oil.png';
    if (n.contains('bumbu')) return 'assets/icons/spices.png';
    if (n.contains('sayur')) return 'assets/icons/broccoli.png';
    if (n.contains('buah')) return 'assets/icons/fruits.png';
    return 'assets/icons/list.png';
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            final p = Provider.of<ProductProvider>(context, listen: false);
            await p.fetchCategories();
            await p.fetchProducts();
            await Provider.of<CartProvider>(
              context,
              listen: false,
            ).getCart(); // Refresh Cart Badge
          },
          child: CustomScrollView(
            slivers: [
              // 1. HEADER (LOKASI, PROFILE & KERANJANG BADGE)
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Dikirim ke Rumah ▾",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Halo, ${user?.name?.split(' ')[0] ?? 'Pelanggan'} 👋",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'ClashDisplay',
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // [REVISI] Icon Keranjang dengan Badge
                          Consumer<CartProvider>(
                            builder: (context, cart, child) {
                              // Hitung total items
                              int itemCount = cart.items.length;
                              String badgeText = itemCount > 99
                                  ? "99+"
                                  : itemCount.toString();

                              return GestureDetector(
                                onTap: () async {
                                  // [PERBAIKAN] Tunggu hasil dari CartPage
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const CartPage(),
                                    ),
                                  );

                                  // Jika kembali dari cart (result == true), refresh cart
                                  if (result == true && context.mounted) {
                                    Provider.of<CartProvider>(
                                      context,
                                      listen: false,
                                    ).getCart();
                                  }
                                },
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.shopping_bag_outlined,
                                        color: AppTheme.textDark,
                                        size: 24,
                                      ),
                                    ),
                                    if (itemCount > 0)
                                      Positioned(
                                        right: -2,
                                        top: -2,
                                        child: AnimatedContainer(
                                          // Animasi sederhana saat angka berubah
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          padding: const EdgeInsets.all(5),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 20,
                                            minHeight: 20,
                                          ),
                                          child: Center(
                                            child: Text(
                                              badgeText,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Search Bar
                      TextField(
                        controller: _searchController,
                        onSubmitted: _handleSearch,
                        decoration: InputDecoration(
                          hintText: "Cari ayam, daging, sayur...",
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppTheme.primary,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF3F4F6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // 2. BANNER SLIDER
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 160,
                  child: PageView.builder(
                    controller: _bannerController,
                    onPageChanged: (index) =>
                        setState(() => _currentBanner = index),
                    itemCount: _banners.length,
                    itemBuilder: (context, index) {
                      final banner = _banners[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            colors: banner['color'],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (banner['color'][0] as Color).withOpacity(
                                0.3,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -30,
                              top: -30,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white24,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            banner['title'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          banner['subtitle'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'ClashDisplay',
                                            height: 1.1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Image.asset(
                                      banner['image'],
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) =>
                                          const SizedBox(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 3. INFO BAR
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem(
                        Icons.verified_user_outlined,
                        "100% Halal",
                      ),
                      Container(height: 20, width: 1, color: Colors.grey[300]),
                      _buildInfoItem(Icons.timer_outlined, "Antar Cepat"),
                      Container(height: 20, width: 1, color: Colors.grey[300]),
                      _buildInfoItem(
                        Icons.thumb_up_alt_outlined,
                        "Pasti Segar",
                      ),
                    ],
                  ),
                ),
              ),

              // 4. KATEGORI
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Text(
                        "Kategori Pilihan",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'ClashDisplay',
                        ),
                      ),
                    ),
                    Consumer<ProductProvider>(
                      builder: (context, provider, child) {
                        return SizedBox(
                          height: 90,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.horizontal,
                            itemCount: provider.categories.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final cat = provider.categories[index];
                              final isSelected =
                                  provider.selectedCategory ==
                                  (cat['slug'] ?? 'all');
                              return GestureDetector(
                                onTap: () =>
                                    _handleCategorySelect(cat['slug'] ?? 'all'),
                                child: Column(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      width: 56,
                                      height: 56,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppTheme.primary
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: isSelected
                                            ? null
                                            : Border.all(
                                                color: Colors.grey[200]!,
                                              ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: AppTheme.primary
                                                      .withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Image.asset(
                                        _getCategoryIconPath(cat['name'] ?? ''),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      cat['name'] ?? '',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? AppTheme.primary
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // 5. REKOMENDASI (SKIP 5 LOGIC)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Spesial Hari Ini 🔥",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'ClashDisplay',
                        ),
                      ),
                      // [REVISI] Timer Dihapus sesuai permintaan
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Consumer<ProductProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading)
                      return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    if (provider.products.isEmpty)
                      return const SizedBox.shrink();

                    // [REVISI] Ambil 5 Pertama untuk Spesial Hari Ini
                    final recommended = provider.products.take(5).toList();

                    return SizedBox(
                      height: 240,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: recommended.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final product = recommended[index];
                          return SizedBox(
                            width: 160,
                            child: ProductCard(
                              name: product.name,
                              category: product.category,
                              price: product.price,
                              stock: product.stock,
                              imageUrl: product.imageUrl ?? '',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailPage(product: product),
                                ),
                              ),
                              onAdd: () async {
                                final success = await Provider.of<CartProvider>(
                                  context,
                                  listen: false,
                                ).addToCart(product.id);
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Berhasil masuk keranjang"),
                                      backgroundColor: AppTheme.primary,
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              // 6. PRODUK TERLARIS (SKIP 5 LOGIC)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Produk Terlaris",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'ClashDisplay',
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CatalogPage(),
                          ),
                        ),
                        child: const Text(
                          "Lihat Semua",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Consumer<ProductProvider>(
                builder: (context, provider, child) {
                  if (provider.products.isEmpty)
                    return const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    );

                  // [REVISI] SKIP 5 Logic: Lewati 5 produk pertama yang sudah muncul di atas
                  // Agar produk tidak kembar
                  final bestSellers = provider.products.length > 5
                      ? provider.products
                            .skip(5)
                            .take(6)
                            .toList() // Jika data > 5, skip 5 ambil 6
                      : provider.products
                            .take(6)
                            .toList(); // Jika data sedikit, ambil saja semua

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.70,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final product = bestSellers[index];
                        return ProductCard(
                          name: product.name,
                          category: product.category,
                          price: product.price,
                          stock: product.stock,
                          imageUrl: product.imageUrl ?? '',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailPage(product: product),
                            ),
                          ),
                          onAdd: () async {
                            final success = await Provider.of<CartProvider>(
                              context,
                              listen: false,
                            ).addToCart(product.id);
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Berhasil masuk keranjang"),
                                  backgroundColor: AppTheme.primary,
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                        );
                      }, childCount: bestSellers.length),
                    ),
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}
