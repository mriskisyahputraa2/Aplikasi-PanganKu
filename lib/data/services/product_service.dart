import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:panganku_mobile/core/constants/api_constants.dart';
import 'package:panganku_mobile/data/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<ProductModel> getProduct(int id) async {
    final uri = Uri.parse("${ApiConstants.products}/$id");
    try {
      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return ProductModel.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Gagal memuat produk: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
