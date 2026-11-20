import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/api_service.dart';
import '../widgets/product_card.dart';
import '../widgets/status_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();

  // Local UI state for this screen only (favourites stay in Provider).
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    debugPrint('HomeScreen: initState');
    _loadProducts(); // one-time setup, NOT in build()
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _api.fetchProducts();
      if (!mounted) return; // screen closed while waiting? stop.
      setState(() {
        _products = products; // replace, never add -> no duplicates
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('HomeScreen: build');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Shelf',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Explore products',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${_products.length} items',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Expanded gives the list a bounded height inside the Column.
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // Shows exactly one state: loading, error, empty or the list.
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return StatusView(
        icon: Icons.wifi_off,
        message: _error!,
        buttonText: 'Retry',
        onPressed: _retry,
      );
    }
    if (_products.isEmpty) {
      return const StatusView(
        icon: Icons.inventory_2_outlined,
        message: 'No products found',
      );
    }
    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: _products[index]);
      },
    );
  }
}
