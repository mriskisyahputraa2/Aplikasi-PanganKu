import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:panganku_mobile/core/theme/app_theme.dart';
import 'package:panganku_mobile/providers/cart_provider.dart';
import 'package:panganku_mobile/providers/product_provider.dart';
import 'package:panganku_mobile/ui/pages/product/product_detail_page.dart';
import 'package:panganku_mobile/ui/widgets/product_card.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      provider.fetchCategories();
      provider.fetchProducts(query: '', category: 'Semua');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      final currentCategory = provider.selectedCategory;
      provider.fetchProducts(query: query, category: currentCategory);
    });
  }

  void _onCategorySelected(String categoryName) {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    provider.fetchProducts(
      query: _searchController.text,
      category: categoryName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // ===============================================
            // 1. CUSTOM HEADER (Title & Back Button)
            // ===============================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppTheme.textDark,
                        size: 20,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      "Katalog Produk",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ClashDisplay',
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Penyeimbang ruang tombol kembali
                ],
              ),
            ),

            // ===============================================
            // 2. FILTER SECTION (Search + Category)
            // ===============================================
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                children: [
                  // SEARCH BAR
                  TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: "Cari ayam, ikan, bumbu...",
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
                        borderRadius: BorderRadius.circular(
                          16,
                        ), // Lebih membulat
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // KATEGORI HORIZONTAL
                  SizedBox(
                    height: 40,
                    child: Consumer<ProductProvider>(
                      builder: (context, provider, child) {
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: provider.categories.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final cat = provider.categories[index];
                            final name = cat['name'];
                            final isSelected =
                                provider.selectedCategory == name;

                            return GestureDetector(
                              onTap: () => _onCategorySelected(name),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primary
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    24,
                                  ), // Pil utuh
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primary
                                        : Colors.grey.shade300,
                                    width: 1.5,
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
                                child: Center(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ===============================================
            // 3. PRODUCT GRID SECTION
            // ===============================================
            Expanded(
              child: Consumer<ProductProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    );
                  }

                  if (provider.products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Produk tidak ditemukan",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio:
                              0.68, // Sedikit lebih tinggi agar elegan
                          mainAxisSpacing: 20, // Spasi lebih lega
                          crossAxisSpacing: 20, // Spasi lebih lega
                        ),
                    itemCount: provider.products.length,
                    itemBuilder: (context, index) {
                      final product = provider.products[index];
                      return ProductCard(
                        name: product.name,
                        category: product.category,
                        price: product.price,
                        stock: product.stock,
                        imageUrl: product.imageUrl ?? '',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailPage(product: product),
                            ),
                          );
                        },
                        onAdd: () async {
                          final success = await Provider.of<CartProvider>(
                            context,
                            listen: false,
                          ).addToCart(product.id);

                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
