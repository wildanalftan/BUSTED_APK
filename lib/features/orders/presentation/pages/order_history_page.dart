import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/orders_provider.dart';
import 'package:bustedworld/core/utils/currency_formatter.dart';

class OrderHistoryPage extends ConsumerWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final userOrders = orders.where((o) => o.userId == firebaseUser?.uid).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ORDER HISTORY'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: userOrders.isEmpty
          ? Center(
              child: Text(
                'No orders found.',
                style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: userOrders.length,
              itemBuilder: (context, index) {
                final order = userOrders.reversed.toList()[index];
                
                Color statusColor = Colors.orange; // Pending
                if (order.status == 'Processing') statusColor = Colors.cyan;
                if (order.status == 'Shipped') statusColor = Colors.green;
                if (order.status == 'Completed') statusColor = Colors.blue;
                if (order.status == 'Cancelled') statusColor = Colors.red;
                
                final cardShape = const BeveledRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: cardShape.copyWith(
                    side: BorderSide(color: cs.outline.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ORDER #${order.id.substring(0, 8).toUpperCase()}',
                              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                border: Border.all(color: statusColor, width: 1.5),
                              ),
                              child: Text(
                                order.status.toUpperCase(),
                                style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('MMM dd, yyyy - HH:mm').format(order.date),
                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        Divider(color: cs.outline.withValues(alpha: 0.2), height: 24),
                        
                        // List items in the order
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: order.items.length,
                          itemBuilder: (context, itemIndex) {
                            final item = order.items[itemIndex];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: cs.outline.withValues(alpha: 0.2), width: 1),
                                    ),
                                    child: item.product.imageUrl.startsWith('data:image') 
                                        ? Image.memory(base64Decode(item.product.imageUrl.split(',').last), fit: BoxFit.cover, errorBuilder: (_,_,_) => const Icon(Icons.error, size: 16))
                                        : Image.network(item.product.imageUrl, fit: BoxFit.cover, errorBuilder: (_,_,_) => const Icon(Icons.error, size: 16)),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.title.toUpperCase(),
                                          style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'SIZE: ${item.selectedSize} | QTY: ${item.quantity}',
                                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    formatRupiah(item.product.price * item.quantity),
                                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        
                        Divider(color: cs.outline.withValues(alpha: 0.2), height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL (incl. Rp 15.000 shipping):',
                              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              formatRupiah(order.totalAmount),
                              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: cs.primary),
                            ),
                          ],
                        ),
                        
                        if (order.status != 'Completed' && order.status != 'Shipped' && order.status != 'Cancelled') ...[
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: const BeveledRectangleBorder(
                                    side: BorderSide(color: Colors.red, width: 2),
                                  ),
                                  title: const Text('CANCEL ORDER', style: TextStyle(fontWeight: FontWeight.w900)),
                                  content: const Text('Are you sure you want to cancel this order? Items will be returned to stock.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('NO', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('YES, CANCEL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await ref.read(ordersProvider.notifier).cancelOrder(order);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Order has been cancelled and stock restored.')),
                                );
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: cs.error,
                              side: BorderSide(color: cs.error, width: 1.5),
                              shape: const BeveledRectangleBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Center(
                              child: Text(
                                'CANCEL ORDER',
                                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
