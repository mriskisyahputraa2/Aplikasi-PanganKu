import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:panganku_mobile/core/constants/api_constants.dart';
import 'package:panganku_mobile/data/models/order_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaginatedOrders {
  final List<OrderModel> orders;
  final bool hasMore;

  PaginatedOrders({required this.orders, required this.hasMore});
}

class OrderService {
  // Helper Header Token
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 1. AMBIL LIST PESANAN
  Future<PaginatedOrders> getOrders(
      {String status = 'all', int page = 1}) async {
    final uri =
        Uri.parse("${ApiConstants.baseUrl}/orders?status=$status&page=$page");

    try {
      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        var listData = [];
        bool hasMorePages = false;

        // Handle struktur JSON dari Laravel Resource / Pagination
        if (jsonResponse['data'] is Map &&
            jsonResponse['data']['data'] != null) {
          listData = jsonResponse['data']['data'];
          // Check if there's a next page by comparing current and last page
          final currentPage = jsonResponse['data']['current_page'];
          final lastPage = jsonResponse['data']['last_page'];
          if (currentPage != null &&
              lastPage != null &&
              currentPage < lastPage) {
            hasMorePages = true;
          }
        } else if (jsonResponse['data'] is List) {
          listData = jsonResponse['data'];
        }

        final orders = listData.map((e) => OrderModel.fromJson(e)).toList();
        return PaginatedOrders(orders: orders, hasMore: hasMorePages);
      } else {
        throw Exception('Gagal memuat riwayat pesanan: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 2. AMBIL DETAIL PESANAN
  Future<OrderModel> getOrderDetail(int id) async {
    final uri = Uri.parse("${ApiConstants.baseUrl}/orders/$id");

    try {
      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return OrderModel.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Gagal memuat detail pesanan');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 3. UPLOAD BUKTI BAYAR (POST)
  Future<bool> uploadProof(int orderId, File imageFile) async {
    final uri = Uri.parse(
      "${ApiConstants.baseUrl}/orders/$orderId/upload-proof",
    );

    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll(await _getHeaders());

    // Kirim File
    request.files.add(
      await http.MultipartFile.fromPath('payment_proof', imageFile.path),
    );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Gagal upload bukti');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 4. KONFIRMASI TERIMA BARANG
  Future<bool> completeOrder(int orderId) async {
    final uri = Uri.parse("${ApiConstants.baseUrl}/orders/$orderId/complete");

    try {
      final response = await http.post(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Gagal menyelesaikan pesanan');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 5. BATALKAN PESANAN
  Future<bool> cancelOrder(int orderId) async {
    final uri = Uri.parse("${ApiConstants.baseUrl}/orders/$orderId/cancel");

    try {
      final response = await http.post(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Gagal membatalkan pesanan');
      }
    } catch (e) {
      rethrow;
    }
  }
}
