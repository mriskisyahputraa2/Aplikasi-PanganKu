import 'dart:convert';
import 'dart:io'; // Import IO untuk File
import 'package:http/http.dart' as http;
import 'package:panganku_mobile/core/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Ambil Data Init (Tetap Sama)
  Future<Map<String, dynamic>> getCheckoutData() async {
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/checkout/init"),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Gagal memuat data checkout');
    }
  }

  // [UPDATE] Checkout dengan Multipart (Bisa Upload Gambar)
  Future<bool> checkout({
    required String customerName,
    required String customerPhone,
    required String deliveryType,
    required String paymentMethod,
    String? shippingAddress,
    String? pickupTime,
    int? productId,
    File? paymentProof, // [BARU] Terima File Gambar
  }) async {
    // Gunakan MultipartRequest untuk kirim file
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${ApiConstants.baseUrl}/checkout"),
    );

    // Tambahkan Headers
    request.headers.addAll(await _getHeaders());

    // Tambahkan Fields Teks
    request.fields['customer_name'] = customerName;
    request.fields['customer_phone'] = customerPhone;
    request.fields['delivery_type'] = deliveryType;
    request.fields['payment_method'] = paymentMethod;
    if (shippingAddress != null)
      request.fields['shipping_address'] = shippingAddress;
    if (pickupTime != null) request.fields['pickup_time'] = pickupTime;
    if (productId != null) request.fields['product_id'] = productId.toString();

    // Tambahkan File Gambar (Jika Ada)
    if (paymentProof != null) {
      request.files.add(
        await http.MultipartFile.fromPath('payment_proof', paymentProof.path),
      );
    }

    try {
      // Kirim Request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("CHECKOUT STATUS: ${response.statusCode}");
      print("CHECKOUT BODY: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Gagal memproses pesanan');
      }
    } catch (e) {
      rethrow;
    }
  }
}
