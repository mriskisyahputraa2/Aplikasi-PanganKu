import 'package:flutter/material.dart';
import 'package:panganku_mobile/data/models/order_model.dart';
import 'package:panganku_mobile/data/services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _service = OrderService();

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String _currentStatus = 'all';

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String get currentStatus => _currentStatus;

  Future<void> fetchOrders({String status = 'all'}) async {
    _isLoading = true;
    _currentStatus = status;
    notifyListeners();

    try {
      _orders = await _service.getOrders(status: status);
    } catch (e) {
      print("Error fetching orders: $e");
      _orders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
