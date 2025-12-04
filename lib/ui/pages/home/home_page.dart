import 'package:flutter/material.dart';
import 'package:panganku_mobile/core/theme/app_theme.dart';
// import 'package:panganku_mobile/ui/pages/cart/cart_page.dart'; // Nanti

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER (Sapaan & Cart)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Selamat Datang, 👋",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Mau masak apa hari ini?",
                          style: TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Tombol Keranjang
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          color: AppTheme.primary,
                        ),
                        onPressed: () {
                          // TODO: Ke Halaman Cart
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // 2. SEARCH BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: "Cari ayam, daging, bumbu...",
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.grey),
                      contentPadding:
                          EdgeInsets.zero, // Hapus padding bawaan theme
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 3. BANNER PROMO (PageView)
              SizedBox(
                height: 160,
                child: PageView(
                  controller: PageController(viewportFraction: 0.9),
                  padEnds: false, // Mulai dari kiri
                  children: [
                    _buildBannerItem(
                      Colors.green[100]!,
                      "Diskon Spesial",
                      "Ayam Utuh",
                    ),
                    _buildBannerItem(
                      Colors.orange[100]!,
                      "Gratis Ongkir",
                      "Khusus Hari Ini",
                    ),
                    _buildBannerItem(
                      Colors.blue[100]!,
                      "Produk Baru",
                      "Bumbu Racik",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4. KATEGORI (Horizontal Scroll)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Kategori",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryItem("Semua", Icons.grid_view, true),
                          _buildCategoryItem("Ayam", Icons.egg_alt, false),
                          _buildCategoryItem(
                            "Daging",
                            Icons.lunch_dining,
                            false,
                          ),
                          _buildCategoryItem("Ikan", Icons.set_meal, false),
                          _buildCategoryItem(
                            "Bumbu",
                            Icons.soup_kitchen,
                            false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 5. PRODUK TERBARU (Grid)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Produk Terbaru",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // GridView di dalam Column harus pakai shrinkWrap & physics
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 4, // Dummy dulu
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio:
                                0.75, // Perbandingan lebar:tinggi kartu
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                          ),
                      itemBuilder: (context, index) {
                        return _buildProductCard();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET KECIL (Helper) ---

  Widget _buildBannerItem(Color color, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(left: 20), // Jarak antar banner
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(subtitle, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primary : Colors.white,
              shape: BoxShape.circle,
              border: isActive ? null : Border.all(color: Colors.grey[200]!),
            ),
            child: Icon(icon, color: isActive ? Colors.white : Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? AppTheme.primary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Produk
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: const Center(
                child: Icon(Icons.image, size: 40, color: Colors.grey),
              ),
            ),
          ),
          // Info Produk
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Ayam Potong Segar",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Rp 35.000",
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Tombol Tambah
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      side: const BorderSide(color: AppTheme.primary),
                    ),
                    child: const Text(
                      "+ Keranjang",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
