import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favourites_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/status_view.dart';

class SavedScreen extends StatelessWidget {
  // Called when "Browse products" is tapped (MainShell switches to Home).
  final VoidCallback onBrowse;

  const SavedScreen({super.key, required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    // watch: rebuild when a product is saved or removed.
    final favourites = context.watch<Favourites>();
    final items = favourites.items;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saved products',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Your favourites, in one place.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            // "N saved" chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EDFF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${favourites.count} saved',
                style: const TextStyle(
                  color: Color(0xFF3B5BDB),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: items.isEmpty
                  ? StatusView(
                      icon: Icons.bookmark_border,
                      message: 'No saved products yet',
                      buttonText: 'Browse products',
                      onPressed: onBrowse,
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return ProductCard(product: items[index]);
                      },
                    ),
            ),
            if (items.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Tap Saved to remove an item.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
