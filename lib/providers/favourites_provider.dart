import 'package:flutter/foundation.dart';

import '../models/product.dart';

class Favourites extends ChangeNotifier {
  final List<Product> _items = [];

  // Read-only view of the saved products.
  List<Product> get items => List.unmodifiable(_items);

  int get count => _items.length;

  bool isSaved(int id) {
    return _items.any((product) => product.id == id);
  }

  // Save if not saved, remove if already saved.
  void toggle(Product product) {
    if (isSaved(product.id)) {
      _items.removeWhere((p) => p.id == product.id);
    } else {
      _items.add(product);
    }
    notifyListeners();
  }
}
