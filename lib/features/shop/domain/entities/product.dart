class Product {
  final String id;
  final String title;
  final double price;
  final String imageUrl;
  final String category;
  final String description;
  final double rating;
  final Map<String, int> stockPerSize;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.description,
    required this.rating,
    required this.stockPerSize,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'description': description,
      'rating': rating,
      'stockPerSize': stockPerSize,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      rating: (json['rating'] as num).toDouble(),
      stockPerSize: Map<String, int>.from(json['stockPerSize'] as Map),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(), // Fallback for old products
    );
  }
}
