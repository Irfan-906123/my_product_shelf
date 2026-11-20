import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/favourites_provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  static const Color _primary = Color(0xFF3B5BDB);

  @override
  Widget build(BuildContext context) {
    // watch: rebuild this card when favourites change.
    final isSaved = context.watch<Favourites>().isSaved(product.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(isSaved),
          const SizedBox(width: 16),
          // Expanded: details take only the remaining width (no overflow).
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Saved products from storage have no category.
                if (product.category.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
                const SizedBox(height: 8),
                // Row for price + action.
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    FilledButton.tonal(
                      // read: we only call a method, no need to listen here.
                      onPressed: () =>
                          context.read<Favourites>().toggle(product),
                      child: Text(isSaved ? 'Saved' : '+ Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(bool isSaved) {
    const placeholder = Icon(
      Icons.image_not_supported_outlined,
      color: Colors.grey,
    );

    // Stack + Positioned: saved badge on top of the image.
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 90,
            height: 90,
            color: const Color(0xFFE3E8F2),
            child: product.thumbnail.isEmpty
                ? placeholder
                : Image.network(
                    product.thumbnail,
                    fit: BoxFit.cover,
                    // Broken URL or offline -> show the placeholder.
                    errorBuilder: (context, error, stackTrace) => placeholder,
                  ),
          ),
        ),
        if (isSaved)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bookmark, size: 16, color: _primary),
            ),
          ),
      ],
    );
  }
}
