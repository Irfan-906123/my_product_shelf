import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';

// All shared_preferences code lives here, so widgets never touch it directly.
class StorageService {
  static const String _nameKey = 'display_name';
  static const String _savedKey = 'saved_products';

  Future<String> loadName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey) ?? '';
  }

  Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  // Saved products are stored as one JSON string:
  // [{"id":1,"title":"...","price":9.99,"thumbnail":"..."}, ...]
  Future<List<Product>> loadSavedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_savedKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Stored data is unreadable -> start with an empty list, do not crash.
      return [];
    }
  }

  Future<void> saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(products.map((p) => p.toJson()).toList());
    await prefs.setString(_savedKey, raw);
  }
}
