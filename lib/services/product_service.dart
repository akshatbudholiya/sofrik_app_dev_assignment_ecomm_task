import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductServiceException implements Exception {
  final String message;
  final int? statusCode;

  const ProductServiceException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

class ProductService {
  static const String _baseUrl = 'https://fakestoreapi.com';
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;

  ProductService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/products'))
          .timeout(_timeout);

      return _parseProducts(response);
    } on SocketException {
      throw const ProductServiceException(
        message: 'No internet connection. Please check your network.',
      );
    } on HttpException {
      throw const ProductServiceException(
        message: 'Failed to reach the server. Please try again.',
      );
    } on FormatException catch (e) {
      throw ProductServiceException(
        message: 'Invalid data received: ${e.message}',
      );
    } catch (e) {
      if (e is ProductServiceException) rethrow;
      throw ProductServiceException(
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  Future<Product> fetchProductById(int id) async {
    if (id <= 0) {
      throw const ProductServiceException(message: 'Invalid product ID');
    }

    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/products/$id'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return Product.fromJson(json);
      } else {
        throw ProductServiceException(
          message: 'Product not found.',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw const ProductServiceException(
        message: 'No internet connection. Please check your network.',
      );
    } catch (e) {
      if (e is ProductServiceException) rethrow;
      throw ProductServiceException(message: 'An unexpected error occurred: $e');
    }
  }

  List<Product> _parseProducts(http.Response response) {
    if (response.statusCode == 200) {
      final List<dynamic> jsonList =
          jsonDecode(response.body) as List<dynamic>;

      return jsonList
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 404) {
      throw const ProductServiceException(message: 'Products endpoint not found.');
    } else if (response.statusCode >= 500) {
      throw ProductServiceException(
        message: 'Server error (${response.statusCode}). Please try again later.',
        statusCode: response.statusCode,
      );
    } else {
      throw ProductServiceException(
        message: 'Request failed with status: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  void dispose() {
    _client.close();
  }
}