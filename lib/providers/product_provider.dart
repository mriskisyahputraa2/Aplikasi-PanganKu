import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:panganku_mobile/core/constants/api_constants.dart';
import 'package:panganku_mobile/data/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  List<dynamic> _categories = []; // [BARU] Simpan data kategori
  bool _isLoading = false;

  // State Filter
  String _searchQuery = "";
  String _selectedCategory = "Semua"; // Default 'Semua'

  List<ProductModel> get products => _products;
  List<dynamic> get categories => _categories;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  // 1. Fetch Produk (Bisa dengan Filter)
  Future<void> fetchProducts({String query = "", String category = ""}) async {
    _isLoading = true;
    _searchQuery = query;
    if (category.isNotEmpty) _selectedCategory = category;

    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // Susun URL dengan Query Params
      // Contoh: /api/products?search=ayam&category=ayam-potong
      String url = "${ApiConstants.baseUrl}/products?search=$_searchQuery";

      if (_selectedCategory != "Semua") {
        url += "&category=$_selectedCategory";
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> productList = data['data'];
        _products = productList
            .map((json) => ProductModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      print("Error fetching products: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. [BARU] Fetch Kategori
  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/categories"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _categories = data['data'];

        // Tambahkan opsi "Semua" di awal secara manual
        _categories.insert(0, {'name': 'Semua', 'slug': 'all', 'icon': null});

        notifyListeners();
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }
}
