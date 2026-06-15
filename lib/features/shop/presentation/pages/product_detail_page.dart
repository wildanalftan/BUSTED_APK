import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/products_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import 'package:bustedworld/core/utils/currency_formatter.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final String id;

  const ProductDetailPage({super.key, required this.id});

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  String? selectedSize;

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final index = products.indexWhere((p) => p.id == widget.id);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    
    if (index == -1) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text("Product not found.")),
      );
    }
    final product = products[index];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          color: cs.surface.withOpacity(0.7),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: cs.onSurface),
            onPressed: () => context.pop(),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
      bottomNavigationBar: Container(
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
                    Text('TOTAL PRICE', style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    Text(
                      formatRupiah(product.price),
                      style: tt.headlineSmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedSize == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: const Text('SELECT SIZE FIRST!'), backgroundColor: cs.error, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                    );
                    return;
                  }
                  ref.read(cartProvider.notifier).addProduct(product, selectedSize!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                           const Icon(Icons.check, color: Colors.white),
                           const SizedBox(width: 8),
                           Text('${product.title.toUpperCase()} (SIZE $selectedSize) COPPED!'),
                        ]
                      ),
                      backgroundColor: cs.primary,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                ),
                child: const Text('COP NOW', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2)),
              ),
            ],
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth > 900;

          Widget content = Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    border: Border.all(color: cs.onPrimary, width: 1.5),
                  ),
                  child: Text(
                    product.category.toUpperCase(),
                    style: TextStyle(color: cs.onPrimary, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  product.title.toUpperCase(),
                  style: tt.headlineMedium?.copyWith(
                    letterSpacing: 2,
                    fontSize: isDesktop ? 40 : 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(border: Border.all(color: cs.outline, width: 1.5)),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: cs.primary, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${product.rating}',
                            style: TextStyle(color: cs.onSurface, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.local_shipping_outlined, color: cs.onSurfaceVariant, size: 20),
                    const SizedBox(width: 8),
                    Text('FREE SHIPPING', style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
                const SizedBox(height: 32),
                Text('SELECT SIZE', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: cs.onSurface, letterSpacing: 2)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: ['S', 'M', 'L', 'XL'].map((size) {
                    final stock = product.stockPerSize[size] ?? 0;
                    final isAvailable = stock > 0;
                    final isSelected = selectedSize == size;
                    
                    return GestureDetector(
                      onTap: () {
                          if (isAvailable) {
                          setState(() { selectedSize = size; });
                        }
                      },
                      child: Opacity(
                        opacity: isAvailable ? 1.0 : 0.4,
                        child: Container(
                          width: 70,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? cs.primary : Colors.transparent,
                            border: Border.all(color: isSelected ? cs.primary : cs.outline, width: 2),
                          ),
                          child: Column(
                            children: [
                              Text(size, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: isSelected ? cs.onPrimary : cs.onSurface)),
                              const SizedBox(height: 4),
                              Text('$stock LFT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? cs.onPrimary : cs.onSurfaceVariant, letterSpacing: 1)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
                Text(
                  'DETAILS',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: cs.onSurface, letterSpacing: 2),
                ),
                const SizedBox(height: 16),
                Text(
                  product.description,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );

          if (isDesktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 1,
                  child: Hero(
                    tag: 'image_${product.id}',
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(color: cs.outline, width: 2)),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: product.imageUrl.startsWith('data:image') 
                              ? MemoryImage(base64Decode(product.imageUrl.split(',').last)) as ImageProvider
                              : NetworkImage(product.imageUrl),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(child: content),
                ),
              ],
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Hero(
                    tag: 'image_${product.id}',
                    child: Container(
                      height: 500,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: cs.outline, width: 2)),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: product.imageUrl.startsWith('data:image') 
                              ? MemoryImage(base64Decode(product.imageUrl.split(',').last)) as ImageProvider
                              : NetworkImage(product.imageUrl),
                        ),
                      ),
                    ),
                  ),
                  content,
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
