import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:panganku_mobile/core/constants/api_constants.dart';
import 'package:panganku_mobile/data/models/cart_item_model.dart'; // Pastikan model ini ada

class CartProvider with ChangeNotifier {
  List<CartItemModel> _items = [];
  bool _isLoading = false;

  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;

  // [GETTER BARU] Hitung Total Harga
  double get totalPrice {
    return _items.fold(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
  }

  // 1. Fetch Cart (Ganti nama getCart -> fetchCart agar sesuai error)
  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/cart"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Sesuaikan parsing JSON dengan struktur API Anda
        // Asumsi: data['data']['items'] adalah list cart item
        final List<dynamic> cartList = data['data']['items'] ?? [];

        _items = cartList.map((json) => CartItemModel.fromJson(json)).toList();
      } else {
        _items = [];
      }
    } catch (e) {
      print("Error fetching cart: $e");
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Alias agar getCart() yang ada di HomePage tidak error
  Future<void> getCart() => fetchCart();

  // 2. Add to Cart
  Future<bool> addToCart(int productId, {int quantity = 1}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) return false;

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/cart/add"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'product_id': productId, 'quantity': quantity}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchCart(); // Refresh data
        return true;
      }
      return false;
    } catch (e) {
      print("Error adding to cart: $e");
      return false;
    }
  }

  // 3. Update Quantity (API) - [PERBAIKAN BUG 1]
  Future<bool> updateQty(int itemId, int quantity) async {
    if (quantity < 1) return false;

    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1) return false;

    // Simpan state asli untuk revert jika gagal
    final originalItems = List<CartItemModel>.from(_items);
    final itemToUpdate = _items[index];

    // Optimistic Update (Ubah di UI dulu)
    final updatedItem = itemToUpdate.copyWith(quantity: quantity);
    _items[index] = updatedItem;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception('Authentication token not found.');

      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/cart/update/$itemId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'quantity': quantity}),
      );

      if (response.statusCode == 200) {
        return true; // Sukses
      } else {
        // Jika gagal, kembalikan ke state semula
        _items = originalItems;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Jika ada error, kembalikan juga
      _items = originalItems;
      notifyListeners();
      print("Error updating quantity: $e");
      return false;
    }
  }

  // 4. Remove Item - [PERBAIKAN BUG 1]
  Future<bool> removeItem(int itemId) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1) return false;

    // Simpan state asli dan item yang dihapus
    final originalItems = List<CartItemModel>.from(_items);
    final removedItem = _items[index];

    // Optimistic Update (Hapus dari UI dulu)
    _items.removeAt(index);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception('Authentication token not found.');

      final response = await http.delete(
        Uri.parse("${ApiConstants.baseUrl}/cart/remove/$itemId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true; // Sukses
      } else {
        // Jika gagal, kembalikan item yang dihapus
        _items = originalItems;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Jika error, kembalikan juga
      _items = originalItems;
      notifyListeners();
      print("Error removing item: $e");
      return false;
    }
  }
}
