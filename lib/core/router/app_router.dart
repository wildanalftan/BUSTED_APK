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

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/order_history',
        name: 'order_history',
        builder: (context, state) => const OrderHistoryPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/shop',
        name: 'shop',
        builder: (context, state) => const ShopPage(),
      ),
      GoRoute(
        path: '/lookbook',
        name: 'lookbook',
        builder: (context, state) => const LookbookPage(),
      ),
      GoRoute(
        path: '/product/:id',
        name: 'product_detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailPage(id: id);
        },
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(
        path: '/order_success',
        name: 'order_success',
        builder: (context, state) => const OrderSuccessPage(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboardPage(),
        routes: [
          GoRoute(
            path: 'products',
            name: 'admin_products',
            builder: (context, state) => const AdminProductsPage(),
          ),
          GoRoute(
            path: 'users',
            name: 'admin_users',
            builder: (context, state) => const AdminUsersPage(),
          ),
          GoRoute(
            path: 'orders',
            name: 'admin_orders',
            builder: (context, state) => const AdminOrdersPage(),
          ),
          GoRoute(
            path: 'settings',
            name: 'admin_settings',
            builder: (context, state) => const AdminSettingsPage(),
          ),
        ],
      ),
    ],
  );
});
