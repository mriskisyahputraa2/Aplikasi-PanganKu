import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:panganku_mobile/core/theme/app_theme.dart';
import 'package:panganku_mobile/providers/auth_provider.dart';
import 'package:panganku_mobile/providers/product_provider.dart';
import 'package:panganku_mobile/providers/cart_provider.dart';
import 'package:panganku_mobile/providers/checkout_provider.dart';
import 'package:panganku_mobile/ui/pages/auth/login_page.dart';
import 'package:panganku_mobile/providers/order_provider.dart';

void main() {
  runApp(
    // [PENTING] Bungkus aplikasi dengan MultiProvider
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CheckoutProvider()),
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
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginPage(), // Arahkan ke Login Page dulu
    );
  }
}
