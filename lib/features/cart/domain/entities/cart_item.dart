import '../../../shop/domain/entities/product.dart';

class CartItem {
  final Product product;
  final String selectedSize;
  int quantity;

  CartItem({required this.product, required this.selectedSize, this.quantity = 1});

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'selectedSize': selectedSize,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      selectedSize: json['selectedSize'] as String,
      quantity: json['quantity'] as int,
    );
  }
}
