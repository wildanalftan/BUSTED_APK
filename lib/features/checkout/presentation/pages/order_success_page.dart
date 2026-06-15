import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

class OrderSuccessPage extends ConsumerStatefulWidget {
  const OrderSuccessPage({super.key});

  @override
  ConsumerState<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends ConsumerState<OrderSuccessPage> {
  @override
  void initState() {
    super.initState();
    // Clear cart upon successful order
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(cartProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: ShapeDecoration(
                  shape: const BeveledRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  color: cs.primary.withOpacity(0.15),
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 100,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'ORDER PLACED!',
                style: tt.displayLarge?.copyWith(fontSize: 32, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              Text(
                'Your payment was successful and your order is being processed.',
                textAlign: TextAlign.center,
                style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('BACK TO HOME'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
