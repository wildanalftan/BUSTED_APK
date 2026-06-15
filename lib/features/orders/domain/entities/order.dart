import 'package:uuid/uuid.dart';
import '../../../cart/domain/entities/cart_item.dart';

class Order {
  final String id;
  final String userId;
  final String customerName;
  final String address;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime date;
  String status;

  Order({
    String? id,
    required this.userId,
    required this.customerName,
    required this.address,
    required this.items,
    required this.totalAmount,
    DateTime? date,
    this.status = 'Pending',
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'customerName': customerName,
      'address': address,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'date': date.toIso8601String(),
      'status': status,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      customerName: json['customerName'] as String,
      address: json['address'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
    );
  }
}
