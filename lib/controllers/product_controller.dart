import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductController extends ChangeNotifier {
  List<ProductModel> _products = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  // ─── Fetch all products ─────────────────────────────────────────────────
  Future<void> fetchProducts(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await ApiService.getProducts(token);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── Add product ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> addProduct(
    String token,
    String name,
    int price,
    String description,
  ) async {
    _isSubmitting = true;
    notifyListeners();

    final result = await ApiService.addProduct(token, name, price, description);

    if (result['success'] == true) {
      await fetchProducts(token); // refresh list
    }

    _isSubmitting = false;
    notifyListeners();
    return result;
  }

  // ─── Submit Tugas ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> submitTugas(
    String token,
    String name,
    int price,
    String description,
    String githubUrl,
  ) async {
    _isSubmitting = true;
    notifyListeners();

    final result = await ApiService.submitTugas(
      token,
      name,
      price,
      description,
      githubUrl,
    );

    _isSubmitting = false;
    notifyListeners();
    return result;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}