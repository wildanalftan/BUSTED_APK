import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shop/presentation/providers/products_provider.dart';
import '../../../auth/presentation/providers/users_provider.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import 'package:bustedworld/core/utils/currency_formatter.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final users = ref.watch(usersProvider);
    final orders = ref.watch(ordersProvider);

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Calculate dynamic stats
    final double totalRevenue = orders.fold(0.0, (sum, o) => sum + o.totalAmount);
    final int customerCount = users.where((u) => !u.isAdmin).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('ADMIN DASHBOARD', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: cs.onSurfaceVariant),
            tooltip: 'Logout',
            onPressed: () {
              ref.read(currentUserProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 600;
          final int crossAxisCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 3 : 2);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Stats Card - Beveled Brutalist with Gradient
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: ShapeDecoration(
                    gradient: LinearGradient(
                      colors: [cs.primary, cs.tertiary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: const BeveledRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TOTAL REVENUE', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      const SizedBox(height: 8),
                      Text(
                        formatRupiah(totalRevenue),
                        style: tt.displayMedium?.copyWith(
                          color: Colors.white,
                          fontSize: isMobile ? 28 : 34,
                          shadows: [],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Responsive Stat Row
                      Wrap(
                        spacing: 32,
                        runSpacing: 16,
                        children: [
                          _buildStatColumn('ORDERS', '${orders.length}'),
                          _buildStatColumn('CUSTOMERS', '$customerCount'),
                          _buildStatColumn('PRODUCTS', '${products.length}'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text('MANAGEMENT', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 2)),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: isMobile ? 1.1 : 1.3,
                  children: [
                    _buildActionCard(context, 'Products', Icons.inventory_2_outlined, cs.primary, 'admin_products'),
                    _buildActionCard(context, 'Users', Icons.people_outline, cs.secondary, 'admin_users'),
                    _buildActionCard(context, 'Orders', Icons.receipt_long_outlined, cs.tertiary, 'admin_orders'),
                    _buildActionCard(context, 'Settings', Icons.settings_outlined, cs.onSurfaceVariant, 'admin_settings'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, String routeName) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cardShape = const BeveledRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
    );

    return Container(
      decoration: ShapeDecoration(
        color: cs.surface,
        shape: cardShape.copyWith(
          side: BorderSide(color: cs.outline.withOpacity(0.3), width: 1.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: cardShape,
          onTap: () {
            context.goNamed(routeName);
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: ShapeDecoration(
                    color: color.withOpacity(0.15),
                    shape: const BeveledRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                Text(title.toUpperCase(), style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
