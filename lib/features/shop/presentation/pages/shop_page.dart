import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/products_provider.dart';
import '../widgets/product_card.dart';
import 'package:bustedworld/features/shop/domain/entities/product.dart';

class ShopPage extends ConsumerWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'SHOP DROP',
          style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, size: 20),
            onPressed: () => context.push('/cart'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 2;
          if (constraints.maxWidth > 1200) {
            crossAxisCount = 5;
          } else if (constraints.maxWidth > 900) {
            crossAxisCount = 4;
          } else if (constraints.maxWidth > 600) {
            crossAxisCount = 3;
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'NEW ARRIVALS',
                    style: tt.headlineMedium?.copyWith(
                      fontSize: constraints.maxWidth < 600 ? 20 : 28,
                      letterSpacing: 2.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: products.isEmpty 
                    ? Padding(
                        padding: const EdgeInsets.all(32), 
                        child: Center(
                          child: Text(
                            'No products available.', 
                            style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    : Builder(
                        builder: (context) {
                          List<Product> displayProducts = products.where((p) => DateTime.now().difference(p.createdAt).inDays <= 7).toList();
                          if (displayProducts.isEmpty) {
                            displayProducts = List.from(products)..sort((a,b) => b.createdAt.compareTo(a.createdAt));
                            if (displayProducts.length > 10) displayProducts = displayProducts.sublist(0, 10);
                          } else {
                            displayProducts.sort((a,b) => b.createdAt.compareTo(a.createdAt));
                          }
                          
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 24,
                            ),
                            itemCount: displayProducts.length,
                            itemBuilder: (context, index) {
                              return ProductCard(product: displayProducts[index]);
                            },
                          );
                        }
                      ),
                ),
                const SizedBox(height: 64),
              ],
            ),
          );
        },
      ),
    );
  }
}
