import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:bustedworld/features/orders/domain/entities/order.dart';
import 'package:bustedworld/core/providers/notification_provider.dart';
import 'package:bustedworld/features/shop/presentation/providers/products_provider.dart';

class OrdersNotifier extends Notifier<List<Order>> {
  @override
  List<Order> build() {
    _loadOrders();
    return [];
  }

  Future<void> _loadOrders() async {
    FirebaseFirestore.instance.collection('orders').snapshots().listen((snapshot) {
      final orders = snapshot.docs.map((doc) {
        return Order.fromJson(doc.data());
      }).toList();
      state = orders;
    });
  }

  Future<void> addOrder(Order order) async {
    await FirebaseFirestore.instance.collection('orders').doc(order.id).set(order.toJson());
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final docRef = FirebaseFirestore.instance.collection('orders').doc(orderId);
    await docRef.update({'status': newStatus});

    ref.read(notificationProvider.notifier).add(
      AppNotification(
        id: const Uuid().v4(),
        title: 'ORDER UPDATED',
        message: 'Order #${orderId.substring(0, 8)} is now $newStatus',
        type: NotificationType.info,
      ),
    );
  }

  Future<void> cancelOrder(Order order) async {
    await updateOrderStatus(order.id, 'Cancelled');
    for (var item in order.items) {
      await ref.read(productsProvider.notifier).increaseStock(
        item.product.id,
        item.selectedSize,
        item.quantity,
      );
    }
  }

  void clearAllOrders() {
    // Unsupported in pure Firebase
  }
}

final ordersProvider = NotifierProvider<OrdersNotifier, List<Order>>(() {
  return OrdersNotifier();
});
