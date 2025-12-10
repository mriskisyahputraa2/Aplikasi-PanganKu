import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:panganku_mobile/core/theme/app_theme.dart';
import 'package:panganku_mobile/providers/auth_provider.dart';
import 'package:panganku_mobile/providers/product_provider.dart';
import 'package:panganku_mobile/providers/cart_provider.dart';
import 'package:panganku_mobile/ui/widgets/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

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
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
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

  // LOGIC ICON (SAMA SEPERTI SEBELUMNYA)
  String _getCategoryIconPath(String name) {
    final n = name.toLowerCase();
    if (n.contains('semua') || n.contains('all'))
      return 'assets/icons/list.png';
    if (n.contains('sayap')) return 'assets/icons/chicken-wings.png';
    if (n.contains('fillet') || n.contains('dada'))
      return 'assets/icons/chicken-breast.png';
    if (n.contains('jeroan') || n.contains('daging') || n.contains('sapi'))
      return 'assets/icons/meat.png';
    if (n.contains('ayam') || n.contains('utuh'))
      return 'assets/icons/chicken.png';
    if (n.contains('ikan') || n.contains('lele'))
      return 'assets/icons/fish.png';
    if (n.contains('telur')) return 'assets/icons/eggs.png';
    if (n.contains('beras') || n.contains('nasi'))
      return 'assets/icons/rice.png';
    if (n.contains('minyak')) return 'assets/icons/oil.png';
    if (n.contains('bumbu') || n.contains('rempah'))
      return 'assets/icons/spices.png';
    if (n.contains('sayur') || n.contains('brokoli'))
      return 'assets/icons/broccoli.png';
    if (n.contains('buah')) return 'assets/icons/fruits.png';
    return 'assets/icons/list.png';
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        bottom: false, // Biarkan konten mengalir ke bawah navbar floating
        child: RefreshIndicator(
          onRefresh: () async {
            final provider = Provider.of<ProductProvider>(
              context,
              listen: false,
            );
            await provider.fetchCategories();
            await provider.fetchProducts();
          },
          color: AppTheme.primary,
          child: CustomScrollView(
            slivers: [
              // 1. HEADER & SEARCH
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Halo, ${user?.name?.split(' ')[0] ?? 'Pelanggan'} 👋",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                  fontFamily: 'ClashDisplay',
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Mau masak apa hari ini?",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: AppTheme.textDark,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Search Bar Modern
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
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
                        child: TextField(
                          controller: _searchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: _handleSearch,
                          decoration: InputDecoration(
                            hintText: "Cari bahan masak...",
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                            icon: const Icon(
                              Icons.search,
                              color: AppTheme.primary,
                            ),
                            border: InputBorder.none,
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: () => setState(() {
                                      _searchController.clear();
                                      _handleSearch('');
                                    }),
                                  )
                                : null,
                          ),
                          onChanged: (val) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. HERO BANNER (Full Width)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  width: double.infinity,
                  height: 170,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    image: const DecorationImage(
                      // Ganti dengan asset banner jika ada, atau gunakan gradient
                      image: AssetImage(
                        'assets/images/logo.png',
                      ), // Placeholder
                      fit: BoxFit.cover,
                      opacity: 0.1, // Transparansi gambar bg
                    ),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF065F46),
                        Color(0xFF10B981),
                      ], // Dark Green to Emerald
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "Promo Spesial",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Bahan Segar\nLangsung Antar",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                                fontFamily: 'ClashDisplay',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: -10,
                        bottom: -10,
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 140,
                        ), // Ilustrasi
                      ),
                    ],
                  ),
                ),
              ),

              // 3. KATEGORI (PILL SHAPE / KAPSUL)
              SliverToBoxAdapter(
                child: Consumer<ProductProvider>(
                  builder: (context, provider, child) {
                    final categories = provider.categories;
                    return Container(
                      height: 50, // Tinggi Pill
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final slug = cat['slug'] ?? 'all';
                          final name = cat['name'] ?? 'Semua';
                          final isSelected = provider.selectedCategory == slug;
                          final iconPath = _getCategoryIconPath(name);

                          return GestureDetector(
                            onTap: () => _handleCategorySelect(slug),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(
                                  30,
                                ), // Kapsul
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primary
                                      : Colors.grey.shade200,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primary.withOpacity(
                                            0.3,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    iconPath,
                                    width: 20,
                                    height: 20,
                                  ), // Icon Kecil
                                  const SizedBox(width: 8),
                                  Text(
                                    name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[700],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              // 4. JUDUL PRODUK
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    "Pilihan Terbaik",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ClashDisplay',
                    ),
                  ),
                ),
              ),

              // 5. GRID PRODUK
              Consumer<ProductProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading)
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primary,
                        ),
                      ),
                    );
                  if (provider.products.isEmpty)
                    return const SliverFillRemaining(
                      child: Center(child: Text("Produk tidak ditemukan")),
                    );

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final product = provider.products[index];
                        return ProductCard(
                          name: product.name,
                          category: product.category,
                          price: product.price,
                          stock: product.stock,
                          imageUrl: product.imageUrl ?? '',
                          onTap: () {},
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
                                SnackBar(
                                  content: Text(
                                    "${product.name} masuk keranjang",
                                  ),
                                  backgroundColor: AppTheme.primary,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 1),
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

              // Spacer Ekstra untuk Bottom Nav Floating
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }
}
