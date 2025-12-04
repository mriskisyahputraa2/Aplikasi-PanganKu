import 'package:flutter/material.dart';
import 'package:panganku_mobile/data/models/cart_item_model.dart';
import 'package:panganku_mobile/data/services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();

  List<CartItemModel> _items = [];
  bool _isLoading = false;

  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;

  int get totalPrice =>
      _items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  // Load Awal
  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _cartService.getCart();
    } catch (e) {
      print("Error cart: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // [UPDATE 1] Tambah Item (Tanpa Loading Layar Penuh)
  Future<bool> addToCart(int productId) async {
    try {
      await _cartService.addToCart(productId, 1);
      // Kita fetch cart di background saja (silent update)
      final updatedItems = await _cartService.getCart();
      _items = updatedItems;
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // [UPDATE 2] Update Qty (OPTIMISTIC UPDATE - ANTI KEDIP)
  Future<void> updateQty(int itemId, int newQty) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1) return;

    final oldQty = _items[index].quantity;

    // 1. Ubah UI duluan (biar user merasa cepat)
    _items[index] = CartItemModel(
      id: _items[index].id,
      quantity: newQty,
      product: _items[index].product,
    );
    notifyListeners();

    // 2. Kirim ke Server di belakang layar
    try {
      await _cartService.updateQty(itemId, newQty);
    } catch (e) {
      // 3. Kalau gagal, kembalikan angka lama (Rollback)
      _items[index] = CartItemModel(
        id: _items[index].id,
        quantity: oldQty,
        product: _items[index].product,
      );
      notifyListeners();
      throw Exception("Gagal update stok");
    }
  }

  // [UPDATE 3] Hapus Item
  Future<void> removeItem(int itemId) async {
    // Hapus dari UI dulu
    final backupItem = _items.firstWhere((item) => item.id == itemId);
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();

    try {
      await _cartService.removeItem(itemId);
    } catch (e) {
      // Kembalikan jika gagal
      _items.add(backupItem);
      notifyListeners();
      rethrow;
    }
  }
}
