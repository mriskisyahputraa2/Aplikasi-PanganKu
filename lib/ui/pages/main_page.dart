import 'package:flutter/material.dart';
import 'package:panganku_mobile/core/theme/app_theme.dart';
import 'package:panganku_mobile/ui/pages/home/home_page.dart';
import 'package:panganku_mobile/ui/pages/product/catalog_page.dart';
import 'package:panganku_mobile/ui/pages/history/history_page.dart';
import 'package:panganku_mobile/ui/pages/cart/cart_page.dart';
import 'package:panganku_mobile/ui/pages/profile/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const CatalogPage(),
    const CartPage(),
    const HistoryPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // Animasi Perpindahan Halaman (Body)
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeOutQuart,
        switchOutCurve: Curves.easeInQuart,
        transitionBuilder: (Widget child, Animation<double> animation) {
          // Efek Fade + Slide sedikit ke atas agar smooth
          final slideAnimation = Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slideAnimation, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Container(
          height: 80,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E293B).withOpacity(0.1),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                0,
                Icons.home_rounded,
                Icons.home_outlined,
                "Beranda",
              ),
              _buildNavItem(
                1,
                Icons.dashboard_rounded,
                Icons.dashboard_outlined,
                "Katalog",
              ),
              _buildNavItem(
                2,
                Icons.local_mall_rounded,
                Icons.local_mall_outlined,
                "Keranjang",
              ),
              _buildNavItem(
                3,
                Icons.receipt_long_rounded,
                Icons.receipt_long_outlined,
                "Transaksi",
              ),
              _buildNavItem(
                4,
                Icons.person_rounded,
                Icons.person_outline_rounded,
                "Akun",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData iconActive,
    IconData iconInactive,
    String label,
  ) {
    bool isSelected = _currentIndex == index;

    return Tooltip(
      message: label,
      preferBelow: false,
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
        color: Colors.white,
      ),
      decoration: BoxDecoration(
        color: AppTheme.textDark.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _currentIndex = index),
          borderRadius: BorderRadius.circular(24),
          splashColor: AppTheme.primary.withOpacity(0.1),
          highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack, // Background bergerak membal
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: AnimatedSwitcher(
              // [KUNCI ANIMASI] Duration & Curves
              duration: const Duration(milliseconds: 500),
              switchInCurve:
                  Curves.elasticOut, // Efek Membal (Bouncy) saat muncul
              switchOutCurve: Curves.easeIn, // Efek cepat saat hilang

              transitionBuilder: (Widget child, Animation<double> animation) {
                // Cek apakah ini icon yang sedang MASUK (Active)
                final isEntering = child.key == ValueKey(iconActive);

                // Jika icon active, gunakan Scale membal. Jika tidak, fade biasa.
                if (isEntering) {
                  return ScaleTransition(scale: animation, child: child);
                } else {
                  return FadeTransition(opacity: animation, child: child);
                }
              },

              child: Icon(
                isSelected ? iconActive : iconInactive,
                // Key ini PENTING agar AnimatedSwitcher tahu widget berubah
                key: ValueKey<bool>(isSelected),
                color: isSelected ? AppTheme.primary : Colors.grey.shade400,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
