import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bustedworld/features/orders/domain/entities/order.dart';
import 'package:bustedworld/core/providers/notification_provider.dart';
import 'package:bustedworld/features/shop/presentation/providers/products_provider.dart';
import 'package:bustedworld/core/services/notification_service.dart';
import 'package:bustedworld/core/services/fcm_sender_service.dart';

class OrdersNotifier extends Notifier<List<Order>> {
  @override
  List<Order> build() {
    _loadOrders();
    return [];
  }

  Future<void> _loadOrders() async {
    FirebaseFirestore.instance.collection('orders').snapshots().listen((snapshot) {
      final oldOrders = state;
      final newOrders = snapshot.docs.map((doc) {
        return Order.fromJson(doc.data());
      }).toList();

      if (oldOrders.isNotEmpty) {
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        for (var newOrder in newOrders) {
          final oldOrder = oldOrders.firstWhere(
            (o) => o.id == newOrder.id,
            orElse: () => Order(
              userId: '',
              customerName: '',
              address: '',
              items: [],
              totalAmount: 0,
              status: 'unknown',
            ),
          );

          if (oldOrder.status != 'unknown' && oldOrder.status != newOrder.status) {
            // Show notification to the customer whose order changed
            if (newOrder.userId == currentUserId) {
              LocalNotificationService.showNotification(
                id: newOrder.id.hashCode,
                title: 'ORDER UPDATED',
                body: 'Your order #${newOrder.id.substring(0, 8).toUpperCase()} is now ${newOrder.status.toUpperCase()}',
                payload: newOrder.id,
              );
            } else {
              // Also show confirmation to admin/current user who updated the status
              LocalNotificationService.showNotification(
                id: newOrder.id.hashCode ^ currentUserId.hashCode,
                title: '✅ ORDER STATUS UPDATED',
                body: 'Order #${newOrder.id.substring(0, 8).toUpperCase()} → ${newOrder.status.toUpperCase()} (notification sent to customer)',
                payload: newOrder.id,
              );
            }
          }
        }
      }

      state = newOrders;
    });
  }

  Future<void> addOrder(Order order) async {
    await FirebaseFirestore.instance.collection('orders').doc(order.id).set(order.toJson());
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final docRef = FirebaseFirestore.instance.collection('orders').doc(orderId);
    await docRef.update({'status': newStatus});

    // Send FCM push notification to the customer
    try {
      final orderSnapshot = await docRef.get();
      if (orderSnapshot.exists) {
        final orderData = orderSnapshot.data();
        final customerId = orderData?['userId'] as String?;
        if (customerId != null) {
          final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(customerId).get();
          if (userSnapshot.exists) {
            final userData = userSnapshot.data();
            final fcmToken = userData?['fcmToken'] as String?;
            if (fcmToken != null) {
              await FcmSenderService.sendNotification(
                recipientToken: fcmToken,
                title: 'ORDER UPDATED',
                body: 'Your order #${orderId.substring(0, 8).toUpperCase()} is now ${newStatus.toUpperCase()}',
                data: {
                  'orderId': orderId,
                },
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to send order status notification: $e');
    }

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

  Future<void> clearAllOrders() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('orders').get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      state = [];
    } catch (e) {
      debugPrint('Failed to clear orders: $e');
    }
  }
}

final ordersProvider = NotifierProvider<OrdersNotifier, List<Order>>(() {
  return OrdersNotifier();
});
