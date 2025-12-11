import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:panganku_mobile/core/constants/api_constants.dart';
import 'package:panganku_mobile/data/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  List<dynamic> _categories = [];
  bool _isLoading = false;

  // State Filter
  String _searchQuery = "";
  String _selectedCategory = "Semua";

  List<ProductModel> get products => _products;
  List<dynamic> get categories => _categories;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  // 1. Fetch Produk (Filter Logic)
  Future<void> fetchProducts({String query = "", String category = ""}) async {
    _isLoading = true;

    // Update state filter jika ada perubahan
    if (query.isNotEmpty || query == "") _searchQuery = query;
    if (category.isNotEmpty) _selectedCategory = category;

    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // Bangun URL
      // Base: /api/products?search=...
      String url = "${ApiConstants.baseUrl}/products?search=$_searchQuery";

      // Tambah kategori jika bukan 'Semua'
      // Pastikan backend Anda menerima parameter 'category' (slug atau nama)
      if (_selectedCategory != "Semua") {
        // Cari slug dari list categories berdasarkan nama, atau kirim namanya langsung
        // Asumsi backend menerima slug/nama via param 'category'
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

        // Handle format response (kadang data dibungkus 'data' lagi jika paginate)
        List<dynamic> productList = [];
        if (data['data'] is List) {
          productList = data['data'];
        } else if (data['data']['data'] is List) {
          productList = data['data']['data'];
        }

        _products = productList
            .map((json) => ProductModel.fromJson(json))
            .toList();
      } else {
        _products = [];
      }
    } catch (e) {
      print("Error fetching products: $e");
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Fetch Kategori
  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/categories"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> catList = data['data'];

        // Reset dan isi ulang agar tidak duplikat
        _categories = [
          {'name': 'Semua', 'slug': 'all', 'icon': null},
        ];
        _categories.addAll(catList);

        notifyListeners();
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }
}
