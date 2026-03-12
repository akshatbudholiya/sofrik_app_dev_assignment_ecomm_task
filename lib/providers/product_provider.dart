import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/product_service.dart';

enum ProductLoadingState { idle, loading, loaded, error }

class ProductProvider extends ChangeNotifier {
  final ProductService _service;

  ProductLoadingState _state = ProductLoadingState.idle;

  List<Product> _products = [];
  String _errorMessage = '';

  String _selectedCategory = 'All';
  String _searchQuery = '';

  Timer? _debounce;

  ProductProvider({ProductService? service})
      : _service = service ?? ProductService();

  ProductLoadingState get state => _state;
  String get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;

  /// FILTERED PRODUCTS (CATEGORY + SEARCH)
  List<Product> get products {
    List<Product> filtered = _products;

    /// CATEGORY FILTER
    if (_selectedCategory != 'All') {
      filtered =
          filtered.where((p) => p.category == _selectedCategory).toList();
    }

    /// SEARCH FILTER
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) {
        final title = p.title.toLowerCase();
        final category = p.category.toLowerCase();

        return title.contains(_searchQuery) ||
            category.contains(_searchQuery);
      }).toList();
    }

    return List.unmodifiable(filtered);
  }

  /// PRODUCT CATEGORIES
  List<String> get categories {
    final cats = _products.map((p) => p.category).toSet().toList()..sort();
    return ['All', ...cats];
  }

  bool get isLoading => _state == ProductLoadingState.loading;
  bool get hasError => _state == ProductLoadingState.error;
  bool get hasData => _state == ProductLoadingState.loaded;

  /// LOAD PRODUCTS
  Future<void> loadProducts() async {
    if (_state == ProductLoadingState.loading) return;

    _state = ProductLoadingState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _products = await _service.fetchProducts();
      _state = ProductLoadingState.loaded;
    } on ProductServiceException catch (e) {
      _errorMessage = e.message;
      _state = ProductLoadingState.error;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      _state = ProductLoadingState.error;
    } finally {
      notifyListeners();
    }
  }

  /// SET CATEGORY
  void setCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  /// DEBOUNCED SEARCH
  void searchProducts(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchQuery = query.toLowerCase();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _service.dispose();
    super.dispose();
  }
}