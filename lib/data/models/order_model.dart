class OrderModel {
  final int id;
  final String orderNumber;
  final int totalAmount;
  final String status;
  final String paymentStatus;
  final String createdAtFormatted; // Tanggal cantik
  final List<OrderItemModel> items; // Daftar barang

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.createdAtFormatted,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List? ?? [];
    List<OrderItemModel> itemsList = list
        .map((i) => OrderItemModel.fromJson(i))
        .toList();

    return OrderModel(
      id: json['id'],
      orderNumber: json['order_number'] ?? '-',
      totalAmount: json['total_amount'] ?? 0,
      status: json['status'] ?? 'pending',
      paymentStatus: json['payment_status'] ?? 'pending',
      createdAtFormatted: json['created_at_formatted'] ?? '-',
      items: itemsList,
    );
  }
}

class OrderItemModel {
  final int id;
  final String productName;
  final int quantity;
  final int price;
  final String? imageUrl;

  OrderItemModel({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      productName: json['product_name'] ?? 'Produk',
      quantity: json['quantity'] ?? 0,
      price: json['price'] ?? 0,
      imageUrl: json['image_url'],
    );
  }
}
