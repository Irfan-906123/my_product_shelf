class Product {
  final int id;
  final String title;
  final String category;
  final double price;
  final String thumbnail;

  const Product({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.thumbnail,
  });

  // API / storage JSON  ->  Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      // Saved data has no category, so fall back to an empty string.
      category: json['category'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      thumbnail: json['thumbnail'] as String? ?? '',
    );
  }

  // Product  ->  JSON (for shared_preferences).
  // Only id, title, price and thumbnail are stored, as the assignment says.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'thumbnail': thumbnail,
    };
  }
}
