import 'dart:io'; // Import IO
import 'package:flutter/material.dart';
import 'package:panganku_mobile/data/services/checkout_service.dart';

class CheckoutProvider with ChangeNotifier {
  final CheckoutService _checkoutService = CheckoutService();

  bool _isLoading = false;
  String? _errorMessage;
  String _storeAddress = "Memuat alamat...";
  List<Map<String, dynamic>> _paymentMethods = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get storeAddress => _storeAddress;
  List<Map<String, dynamic>> get paymentMethods => _paymentMethods;

  Future<void> fetchCheckoutData() async {
    // ... (Kode fetch data sama seperti sebelumnya) ...
    try {
      final data = await _checkoutService.getCheckoutData();
      _storeAddress = data['store_address'] ?? 'Alamat toko tidak tersedia';
      _paymentMethods = List<Map<String, dynamic>>.from(
        data['payment_methods'],
      );
    } catch (e) {
      print("Error fetching checkout data: $e");
    } finally {
      notifyListeners();
    }
  }

  // [UPDATE] Tambah parameter paymentProof
  Future<bool> processCheckout({
    required String name,
    required String phone,
    required String deliveryType,
    required String paymentMethod,
    String? address,
    String? time,
    int? productId,
    File? paymentProof, // [BARU]
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _checkoutService.checkout(
        customerName: name,
        customerPhone: phone,
        deliveryType: deliveryType,
        paymentMethod: paymentMethod,
        shippingAddress: address,
        pickupTime: time,
        productId: productId,
        paymentProof: paymentProof, // [BARU]
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      notifyListeners();
      return false;
    }
  }
}
