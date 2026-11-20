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

  // Search: the controller is owned by this screen, so we dispose it.
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    debugPrint('HomeScreen: initState');
    _loadProducts(); // one-time setup, NOT in build()
  }

  @override
  void dispose() {
    debugPrint('HomeScreen: dispose');
    _searchController.dispose(); // we created it, so we must dispose it
    super.dispose();
  }

  // Products whose title contains the search text.
  List<Product> get _visibleProducts {
    final q = _query.toLowerCase();
    return _products
        .where((p) => p.title.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _api.fetchProducts();
      if (!mounted) return; // screen closed while waiting? stop.
      setState(() {
        _products = products; // replace, never add -> no duplicates
        _error = null; // a refresh after an error clears it
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

  // Pull-to-refresh must return a Future.
  Future<void> _refresh() async {
    await _loadProducts();
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
            TextField(
              controller: _searchController,
              onChanged: (value) {
                // Search text is local UI state -> setState.
                setState(() {
                  _query = value.trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF3F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
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
                  '${_visibleProducts.length} items',
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

    final visible = _visibleProducts;
    if (visible.isEmpty) {
      return StatusView(
        icon: Icons.search_off,
        message: 'No products match "$_query"',
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: visible.length,
        itemBuilder: (context, index) {
          return ProductCard(product: visible[index]);
        },
      ),
    );
  }
}
