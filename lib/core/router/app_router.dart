import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/shop/presentation/pages/home_page.dart';
import '../../features/shop/presentation/pages/shop_page.dart';
import '../../features/shop/presentation/pages/lookbook_page.dart';
import '../../features/shop/presentation/pages/product_detail_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/checkout/presentation/pages/checkout_page.dart';
import '../../features/checkout/presentation/pages/order_success_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_products_page.dart';
import '../../features/admin/presentation/pages/admin_users_page.dart';
import '../../features/admin/presentation/pages/admin_orders_page.dart';
import '../../features/admin/presentation/pages/admin_settings_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/orders/presentation/pages/order_history_page.dart';

/// Smooth fade + slight upward slide transition
CustomTransitionPage<void> _buildPage(
    BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fadeAnim = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      );
      final slideAnim = Tween<Offset>(
        begin: const Offset(0, 0.04),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

      return FadeTransition(
        opacity: fadeAnim,
        child: SlideTransition(position: slideAnim, child: child),
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (c, s) => _buildPage(c, s, const LoginPage()),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (c, s) => _buildPage(c, s, const RegisterPage()),
      ),
      GoRoute(
        path: '/order_history',
        name: 'order_history',
        pageBuilder: (c, s) => _buildPage(c, s, const OrderHistoryPage()),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        pageBuilder: (c, s) => _buildPage(c, s, const HomePage()),
      ),
      GoRoute(
        path: '/shop',
        name: 'shop',
        pageBuilder: (c, s) => _buildPage(c, s, const ShopPage()),
      ),
      GoRoute(
        path: '/lookbook',
        name: 'lookbook',
        pageBuilder: (c, s) => _buildPage(c, s, const LookbookPage()),
      ),
      GoRoute(
        path: '/product/:id',
        name: 'product_detail',
        pageBuilder: (c, s) {
          final id = s.pathParameters['id']!;
          return _buildPage(c, s, ProductDetailPage(id: id));
        },
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        pageBuilder: (c, s) => _buildPage(c, s, const CartPage()),
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        pageBuilder: (c, s) => _buildPage(c, s, const CheckoutPage()),
      ),
      GoRoute(
        path: '/order_success',
        name: 'order_success',
        pageBuilder: (c, s) => _buildPage(c, s, const OrderSuccessPage()),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        pageBuilder: (c, s) => _buildPage(c, s, const AdminDashboardPage()),
        routes: [
          GoRoute(
            path: 'products',
            name: 'admin_products',
            pageBuilder: (c, s) =>
                _buildPage(c, s, const AdminProductsPage()),
          ),
          GoRoute(
            path: 'users',
            name: 'admin_users',
            pageBuilder: (c, s) => _buildPage(c, s, const AdminUsersPage()),
          ),
          GoRoute(
            path: 'orders',
            name: 'admin_orders',
            pageBuilder: (c, s) =>
                _buildPage(c, s, const AdminOrdersPage()),
          ),
          GoRoute(
            path: 'settings',
            name: 'admin_settings',
            pageBuilder: (c, s) =>
                _buildPage(c, s, const AdminSettingsPage()),
          ),
        ],
      ),
    ],
  );
});
