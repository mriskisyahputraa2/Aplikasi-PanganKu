import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:panganku_mobile/core/constants/api_constants.dart';
import 'package:panganku_mobile/data/models/order_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<OrderModel>> getOrders({String status = 'all'}) async {
    final uri = Uri.parse("${ApiConstants.baseUrl}/orders?status=$status");
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      // [PENTING] Ambil list dari dalam data.data (Pagination Laravel)
      final List listData = jsonResponse['data']['data'];

      return listData.map((e) => OrderModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat pesanan');
    }
  }
}
