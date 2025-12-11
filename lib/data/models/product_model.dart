import 'package:panganku_mobile/core/constants/api_constants.dart';

class ProductModel {
  final int id;
  final String name;
  final int price;
  final int stock;
  final String description;
  final String category;
  final String? imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.description,
    required this.category,
    this.imageUrl,
  });

  // Parsing dari JSON Laravel
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // ---------------------------------------------------------
    // 1. LOGIKA FIX URL GAMBAR (Agar muncul di HP Fisik)
    // ---------------------------------------------------------
    String? finalImageUrl;

    // Cek key JSON: bisa 'image_url' atau 'image' (tergantung backend)
    var rawImage = json['image_url'] ?? json['image'];

    if (rawImage != null) {
      String urlString = rawImage.toString();

      if (urlString.startsWith('http')) {
        // Jika backend kirim full URL (http://...)
        finalImageUrl = urlString;
      } else {
        // Jika backend kirim path relatif (misal: "products/ayam.jpg")
        // Kita harus gabungkan dengan IP Laptop

        // Ambil Base URL (http://192.168.1.x:8000/api) -> Hapus '/api'
        String baseUrl = ApiConstants.baseUrl.replaceAll('/api', '');

        // Hapus slash di akhir jika ada (untuk mencegah double slash)
        if (baseUrl.endsWith('/')) {
          baseUrl = baseUrl.substring(0, baseUrl.length - 1);
        }

        // Gabungkan: Base URL + /storage/ + Nama File
        finalImageUrl = "$baseUrl/storage/$urlString";
      }
    }

    return ProductModel(
      id: json['id'],
      name: json['name'],

      // 2. Parsing Harga (Aman untuk format "15000.00")
      price: double.parse(json['price'].toString()).toInt(),

      // 3. Parsing Stok (Aman jika null)
      stock: int.tryParse(json['stock'].toString()) ?? 0,

      description: json['description'] ?? '',

      // 4. Parsing Kategori (Handle String atau Object)
      category: json['category'] is Map
          ? json['category']['name'] // Jika object, ambil namanya
          : (json['category'] ?? 'Umum'), // Jika string/null, pakai langsung

      imageUrl: finalImageUrl,
    );
  }
}
