import 'package:panganku_mobile/data/models/product_model.dart';

class CartItemModel {
  final int id;
  final int quantity;
  // [PERBAIKAN] Menyimpan Objek Product Utuh
  final ProductModel product;

  CartItemModel({
    required this.id,
    required this.quantity,
    required this.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? 0,
      quantity: int.tryParse(json['quantity'].toString()) ?? 1,
      // [PERBAIKAN] Parsing nested object 'product' dari JSON Laravel
      product: ProductModel.fromJson(json['product'] ?? {}),
    );
  }

  // Helper untuk update state lokal (Optimistic Update)
  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      id: id,
      quantity: quantity ?? this.quantity,
      product: product,
    );
  }
}
