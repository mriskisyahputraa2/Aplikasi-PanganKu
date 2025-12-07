class OrderModel {
  final int id;
  final String orderNumber;
  final int totalAmount;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final String? paymentProofUrl; // [BARU]
  final String deliveryType;
  final String? shippingAddress;
  final String? pickupTime;
  final String? trackingNumber;
  final String createdAtFormatted;
  final String createdAtRaw; // [BARU] Untuk Timer
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    this.paymentMethod = '',
    this.paymentProofUrl,
    this.deliveryType = '',
    this.shippingAddress,
    this.pickupTime,
    this.trackingNumber,
    required this.createdAtFormatted,
    this.createdAtRaw = '',
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
      paymentMethod: json['payment_method'] ?? '',
      paymentProofUrl: json['payment_proof_url'],
      deliveryType: json['delivery_type'] ?? '',
      shippingAddress: json['shipping_address'],
      pickupTime: json['pickup_time'],
      trackingNumber: json['tracking_number'],
      createdAtFormatted: json['created_at_formatted'] ?? '-',
      createdAtRaw: json['created_at_raw'] ?? '',
      items: itemsList,
    );
  }
}

class OrderItemModel {
  final String productName;
  final int quantity;
  final int price;
  final String? imageUrl;

  OrderItemModel({
    required this.productName,
    this.quantity = 0,
    this.price = 0,
    this.imageUrl,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productName: json['product_name'] ?? 'Produk',
      quantity: json['quantity'] ?? 0,
      price: json['price'] ?? 0,
      imageUrl: json['image_url'],
    );
  }
}
