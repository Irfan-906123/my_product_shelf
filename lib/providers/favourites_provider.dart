import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/storage_service.dart';

class Favourites extends ChangeNotifier {
  final StorageService _storage;

  Favourites(this._storage);

  final List<Product> _items = [];

  // Read-only view of the saved products.
  List<Product> get items => List.unmodifiable(_items);

  int get count => _items.length;

  bool isSaved(int id) {
    return _items.any((product) => product.id == id);
  }

  // Read the saved list from local storage (called once when the app starts).
  Future<void> load() async {
    try {
      final stored = await _storage.loadSavedProducts();
      _items
        ..clear()
        ..addAll(stored);
      notifyListeners();
    } catch (e) {
      debugPrint('Favourites: could not load saved products: $e');
    }
  }

  // Save if not saved, remove if already saved.
  Future<void> toggle(Product product) async {
    if (isSaved(product.id)) {
      _items.removeWhere((p) => p.id == product.id);
    } else {
      _items.add(product);
    }
    // Update the UI first, then write to storage in the background.
    notifyListeners();

    try {
      await _storage.saveProducts(_items);
    } catch (e) {
      debugPrint('Favourites: could not save products: $e');
    }
  }
}
