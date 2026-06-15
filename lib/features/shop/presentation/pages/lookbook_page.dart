import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/products_provider.dart';
import '../widgets/product_card.dart';
import 'package:bustedworld/features/cart/presentation/providers/cart_provider.dart';

class LookbookPage extends ConsumerStatefulWidget {
  const LookbookPage({super.key});

  @override
  ConsumerState<LookbookPage> createState() => _LookbookPageState();
}

class _LookbookPageState extends ConsumerState<LookbookPage> {
  String selectedCategory = 'ALL';

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cartItems = ref.watch(cartProvider);

    // Get unique categories from products
    final categories = ['ALL'];
    categories.addAll(products.map((p) => p.category.toUpperCase()).toSet().toList()..sort());

    final displayProducts = selectedCategory == 'ALL'
        ? products
        : products.where((p) => p.category.toUpperCase() == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'LOOKBOOK',
          style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Badge(
              label: Text(cartItems.length.toString()),
              isLabelVisible: cartItems.isNotEmpty,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            onPressed: () => context.push('/cart'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 2;
          if (constraints.maxWidth > 600) crossAxisCount = 3;
          if (constraints.maxWidth > 900) crossAxisCount = 4;

          return CustomScrollView(
            slivers: [
              // Category Filter Bar
              SliverToBoxAdapter(
                child: Container(
                  height: 60,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = category == selectedCategory;
                      return ActionChip(
                        label: Text(category, style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, color: isSelected ? cs.onPrimary : cs.onSurface)),
                        backgroundColor: isSelected ? cs.primary : Colors.transparent,
                        shape: BeveledRectangleBorder(
                          side: BorderSide(color: isSelected ? cs.primary : cs.outline, width: 2),
                        ),
                        onPressed: () {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
              // Products Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: displayProducts.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Text(
                              'No products found in this category.',
                              style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      )
                    : SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 24,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => ProductCard(product: displayProducts[index]),
                          childCount: displayProducts.length,
                        ),
                      ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 64)),
            ],
          );
        },
      ),
    );
  }
}
