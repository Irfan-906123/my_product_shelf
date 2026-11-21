import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ApiService {
  static const String _baseUrl = 'https://dummyjson.com';
  static const Duration _timeout = Duration(seconds: 10);

  // GET 12 products from the API.
  Future<List<Product>> fetchProducts() {
    return _guard(() async {
      final uri = Uri.parse('$_baseUrl/products?limit=12');
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw ApiException('Server error (${response.statusCode})');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = data['products'] as List<dynamic>;

      return list
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }

  // POST a demo product. Returns the id the server sends back.
  Future<int> addProduct({required String title, required double price}) {
    return _guard(() async {
      final uri = Uri.parse('$_baseUrl/products/add');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'title': title, 'price': price}),
          )
          .timeout(_timeout);

      // DummyJSON answers 201 Created; accept any 2xx as success.
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException('Server error (${response.statusCode})');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final id = data['id'];
      if (id is! int) {
        throw ApiException('Invalid server response. Please try again.');
      }
      return id;
    });
  }

  // Runs a request and turns low-level errors into friendly ApiExceptions.
  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on SocketException {
      throw ApiException('No internet connection');
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.');
    } on http.ClientException {
      throw ApiException('Network error. Please try again.');
    } on FormatException {
      throw ApiException('Invalid server response. Please try again.');
    } on TypeError {
      // JSON was valid but not the shape we expected.
      throw ApiException('Invalid server response. Please try again.');
    }
  }
}

// Our own error type with a friendly message for the UI.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
