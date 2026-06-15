import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../orders/presentation/providers/orders_provider.dart';

class AdminOrdersPage extends ConsumerWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('MANAGE ORDERS', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: orders.isEmpty
          ? Center(child: Text('No orders yet.', style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.bold)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders.reversed.toList()[index];

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
                    side: BorderSide(color: cs.outline.withOpacity(0.3), width: 1.5),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    title: Text('ORDER #${order.id.substring(0, 8).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text('STATUS: ${order.status.toUpperCase()}', style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                    trailing: Icon(Icons.edit_note, color: cs.primary),
                    onTap: () {
                      _showStatusDialog(context, ref, order.id, order.status);
                    },
                  ),
                );
              },
            ),
    );
  }

  void _showStatusDialog(BuildContext context, WidgetRef ref, String orderId, String currentStatus) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('UPDATE STATUS'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Pending'),
                leading: Radio<String>(
                  value: 'Pending',
                  groupValue: currentStatus,
                  onChanged: (value) {
                    ref.read(ordersProvider.notifier).updateOrderStatus(orderId, value!);
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('Processing'),
                leading: Radio<String>(
                  value: 'Processing',
                  groupValue: currentStatus,
                  onChanged: (value) {
                    ref.read(ordersProvider.notifier).updateOrderStatus(orderId, value!);
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('Shipped'),
                leading: Radio<String>(
                  value: 'Shipped',
                  groupValue: currentStatus,
                  onChanged: (value) {
                    ref.read(ordersProvider.notifier).updateOrderStatus(orderId, value!);
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('Completed'),
                leading: Radio<String>(
                  value: 'Completed',
                  groupValue: currentStatus,
                  onChanged: (value) {
                    ref.read(ordersProvider.notifier).updateOrderStatus(orderId, value!);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
