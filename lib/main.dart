import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:panganku_mobile/core/theme/app_theme.dart';

// Import Semua Provider
import 'package:panganku_mobile/providers/auth_provider.dart';
import 'package:panganku_mobile/providers/product_provider.dart';
import 'package:panganku_mobile/providers/cart_provider.dart';
import 'package:panganku_mobile/providers/checkout_provider.dart';
import 'package:panganku_mobile/providers/order_provider.dart';
import 'package:panganku_mobile/providers/setting_provider.dart'; // Provider Setting

// Import Halaman Awal
import 'package:panganku_mobile/ui/pages/splash_page.dart';

void main() {
  // Pastikan binding terinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        // 1. Auth & Setting (Global)
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingProvider()),

        // 2. Produk & Belanja
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CheckoutProvider()),

        // 3. Transaksi
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PanganKU',
      debugShowCheckedModeBanner: false, // Hilangkan label Debug
      theme: AppTheme.lightTheme, // Tema Custom (Font Clash Display)

      // Mulai dari Splash Screen
      home: const SplashPage(),
    );
  }
}
