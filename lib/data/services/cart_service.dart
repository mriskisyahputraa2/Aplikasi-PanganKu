import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:panganku_mobile/core/constants/api_constants.dart';
import 'package:panganku_mobile/data/models/cart_item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  // Helper untuk Header Token
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 1. Ambil Data Keranjang
  Future<List<CartItemModel>> getCart() async {
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/cart"),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Asumsi response Laravel: { status: 'success', data: { items: [...] } }
      // Sesuaikan dengan response API CartController Anda
      final List items = data['data']['items'] ?? [];
      return items.map((e) => CartItemModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat keranjang');
    }
  }

  // 2. Tambah ke Keranjang
  Future<void> addToCart(int productId, int quantity) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/cart/add"),
      headers: await _getHeaders(),
      body: {
        'product_id': productId.toString(),
        'quantity': quantity.toString(),
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Gagal menambah produk');
    }
  }

  // 3. Update Jumlah (Qty)
  Future<void> updateQty(int itemId, int quantity) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/cart/update/$itemId"),
      headers: await _getHeaders(),
      body: {'quantity': quantity.toString()},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal update jumlah');
    }
  }

  // 4. Hapus Item
  Future<void> removeItem(int itemId) async {
    final response = await http.delete(
      Uri.parse("${ApiConstants.baseUrl}/cart/remove/$itemId"),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus item');
    }
  }
}
