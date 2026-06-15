import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';
import 'package:bustedworld/core/utils/currency_formatter.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CART // BAG', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
        elevation: 0,
      ),
      bottomNavigationBar: cartItems.isEmpty ? null : Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.outline, width: 2)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL (${cartItems.length} ITEMS)', style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    Text(
                      formatRupiah(cartNotifier.totalPrice),
                      style: tt.headlineSmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => context.push('/checkout'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                ),
                child: const Text('SECURE THE BAG', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5)),
              ),
            ],
          ),
        ),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Text(
                'YOUR CART IS EMPTY', 
                style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: BeveledRectangleBorder(
                    side: BorderSide(color: cs.outline, width: 2),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product name
                        Text(
                          item.product.title.toUpperCase(),
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Price + Size row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              color: cs.primary,
                              child: Text(
                                formatRupiah(item.product.price),
                                style: TextStyle(
                                  color: cs.onPrimary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(color: cs.outline, width: 2),
                              ),
                              child: Text(
                                'SIZE: ${item.selectedSize}',
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Category
                        Text(
                          item.product.category.toUpperCase(),
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 11,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Divider
                        Container(height: 1, color: cs.outline.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        // Qty controls + delete
                        Row(
                          children: [
                            Text('QTY:', style: tt.bodySmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1)),
                            const SizedBox(width: 12),
                            Container(
                              decoration: BoxDecoration(border: Border.all(color: cs.outline, width: 2)),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () => cartNotifier.updateQuantity(item.product.id, item.selectedSize, item.quantity - 1),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      child: Icon(Icons.remove, color: cs.onSurface, size: 16),
                                    ),
                                  ),
                                  Container(
                                    width: 36,
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${item.quantity}',
                                      style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => cartNotifier.updateQuantity(item.product.id, item.selectedSize, item.quantity + 1),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      child: Icon(Icons.add, color: cs.onSurface, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            // Subtotal
                            Text(
                              '= ${formatRupiah(item.product.price * item.quantity)}',
                              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: cs.error),
                              onPressed: () => cartNotifier.removeProduct(item.product.id, item.selectedSize),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
