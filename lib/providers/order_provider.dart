import 'dart:io';
import 'package:flutter/material.dart';
import 'package:panganku_mobile/data/models/order_model.dart';
import 'package:panganku_mobile/data/services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _service = OrderService();

  List<OrderModel> _orders = [];
  OrderModel? _selectedOrder; // Menyimpan detail pesanan yang sedang dibuka

  bool _isLoading = false;
  bool _isLoadMoreRunning = false;
  int _page = 1;
  bool _hasMore = true;
  String _currentStatus = 'all';
  String? _errorMessage;

  // Getters
  List<OrderModel> get orders => _orders;
  OrderModel? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  bool get isLoadMoreRunning => _isLoadMoreRunning;
  String get currentStatus => _currentStatus;
  String? get errorMessage => _errorMessage;

  // 1. Fetch List Pesanan (untuk load awal, refresh, atau ganti filter)
  Future<void> fetchOrders({String status = 'all'}) async {
    _isLoading = true;
    _currentStatus = status;
    _page = 1;
    _hasMore = true;
    notifyListeners();

    try {
      // Hapus list lama sebelum fetch data baru
      _orders.clear();
      final result = await _service.getOrders(status: status, page: _page);
      _orders.addAll(result.orders);
      _hasMore = result.hasMore;
    } catch (e) {
      print("Error fetching orders: $e");
      _errorMessage = e.toString();
      _orders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method baru untuk load more
  Future<void> loadMoreOrders() async {
    if (_isLoadMoreRunning || !_hasMore || _isLoading) return;

    _isLoadMoreRunning = true;
    notifyListeners();

    _page++;
    try {
      final result =
          await _service.getOrders(status: _currentStatus, page: _page);
      _orders.addAll(result.orders);
      _hasMore = result.hasMore;
    } catch (e) {
      print("Error loading more orders: $e");
      _page--; // Kembalikan page jika error
      _errorMessage = e.toString();
    } finally {
      _isLoadMoreRunning = false;
      notifyListeners();
    }
  }

  // 2. Fetch Detail Pesanan
  Future<void> fetchOrderDetail(int id) async {
    _isLoading = true;
    _selectedOrder = null; // Reset agar loading terlihat
    notifyListeners();

    try {
      _selectedOrder = await _service.getOrderDetail(id);
    } catch (e) {
      _errorMessage = e.toString();
      print("Error detail: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. Upload Bukti
  Future<bool> uploadProof(int orderId, File file) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.uploadProof(orderId, file);
      // Refresh detail setelah upload sukses
      await fetchOrderDetail(orderId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 4. Terima Pesanan
  Future<bool> completeOrder(int orderId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.completeOrder(orderId);
      // Refresh detail untuk update status jadi 'selesai'
      await fetchOrderDetail(orderId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 5. Batalkan Pesanan
  Future<bool> cancelOrder(int orderId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.cancelOrder(orderId);
      // Refresh detail untuk update status jadi 'dibatalkan'
      await fetchOrderDetail(orderId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
