import 'package:panganku_mobile/data/models/product_model.dart';

class CartItemModel {
  final int id;
  final int quantity;
  final ProductModel product;

  CartItemModel({
    required this.id,
    required this.quantity,
    required this.product,
  });

  // Parsing dari JSON Laravel
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      quantity: json['quantity'],
      // Kita gunakan ProductModel yang sudah ada untuk parsing data produknya
      product: ProductModel.fromJson(json['product']),
    );
  }
}
