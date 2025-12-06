import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:panganku_mobile/core/constants/api_constants.dart';
import 'package:panganku_mobile/data/models/order_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  // Helper untuk Header Token
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 1. AMBIL LIST PESANAN
  Future<List<OrderModel>> getOrders({String status = 'all'}) async {
    final uri = Uri.parse("${ApiConstants.baseUrl}/orders?status=$status");

    try {
      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Handle struktur data (jika pakai pagination Laravel)
        final List listData =
            (jsonResponse['data'] is Map &&
                jsonResponse['data']['data'] != null)
            ? jsonResponse['data']['data']
            : jsonResponse['data'];

        return listData.map((e) => OrderModel.fromJson(e)).toList();
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

      // [DEBUG] Cetak respons mentah dari server
      if (kDebugMode) {
        print("===== DETAIL PESANAN RESPONSE =====");
        print(response.body);
        print("===================================");
      }

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return OrderModel.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Gagal memuat detail pesanan');
      }
    } catch (e) {
      if (kDebugMode) {
        print("===== DETAIL PESANAN ERROR =====");
        print(e.toString());
        print("================================");
      }
      rethrow;
    }
  }

  // 3. UPLOAD BUKTI BAYAR (POST MULTIPART)
  Future<bool> uploadProof(int orderId, File imageFile) async {
    final uri = Uri.parse(
      "${ApiConstants.baseUrl}/orders/$orderId/upload-proof",
    );

    // Gunakan POST (sesuai route api.php Anda)
    var request = http.MultipartRequest('POST', uri);

    request.headers.addAll(await _getHeaders());

    // Tambahkan File
    request.files.add(
      await http.MultipartFile.fromPath('payment_proof', imageFile.path),
    );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print("UPLOAD STATUS: ${response.statusCode}");
        print("UPLOAD BODY: ${response.body}");
      }

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
