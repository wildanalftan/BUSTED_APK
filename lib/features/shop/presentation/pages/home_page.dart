import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/users_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(
                    bottom: BorderSide(
                        color: cs.primary.withOpacity(0.5), width: 2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Angular avatar — square with primary bg (no circle)
                  Container(
                    width: 60,
                    height: 60,
                    color: cs.primary,
                    child: const Icon(Icons.person,
                        size: 34, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentUser != null
                        ? 'Welcome, ${currentUser.name}!'
                        : 'Welcome, Guest!',
                    style: tt.titleMedium?.copyWith(
                        color: cs.onSurface, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    currentUser != null
                        ? currentUser.email
                        : 'guest@bustedworld.com',
                    style:
                        tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            ListTile(
              leading:
                  Icon(Icons.shopping_bag_outlined, color: cs.onSurface),
              title: Text('Store',
                  style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold, color: cs.onSurface)),
              onTap: () => context.pop(),
            ),
            ListTile(
              leading: Icon(Icons.history, color: cs.onSurface),
              title: Text('Order History',
                  style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold, color: cs.onSurface)),
              onTap: () {
                context.pop();
                context.push('/order_history');
              },
            ),
            if (currentUser?.isAdmin ?? false) ...[
              Divider(color: cs.outline.withOpacity(0.3)),
              ListTile(
                leading: Icon(Icons.admin_panel_settings_outlined,
                    color: cs.tertiary),
                title: Text('Admin Access',
                    style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold, color: cs.onSurface)),
                onTap: () {
                  context.pop();
                  context.push('/admin');
                },
              ),
            ],
            Divider(color: cs.outline.withOpacity(0.3)),
            ListTile(
              leading: Icon(Icons.logout, color: cs.error),
              title: Text('Logout',
                  style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold, color: cs.error)),
              onTap: () {
                ref.read(currentUserProvider.notifier).logout();
                context.go('/login');
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'BUSTED',
          style: tt.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        actions: [
          if (MediaQuery.of(context).size.width > 600) ...[
            TextButton(
              onPressed: () => context.go('/home'),
              child: Text('HOME',
                  style: TextStyle(
                      color: cs.onPrimary.withOpacity(0.9),
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
            TextButton(
              onPressed: () => context.push('/shop'),
              child: Text('SHOP',
                  style: TextStyle(
                      color: cs.onPrimary.withOpacity(0.6),
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
            TextButton(
              onPressed: () => context.push('/order_history'),
              child: Text('HISTORY',
                  style: TextStyle(
                      color: cs.tertiary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
          ],
          IconButton(
            icon: Icon(Icons.shopping_bag_outlined,
                color: cs.onPrimary, size: 20),
            onPressed: () => context.push('/cart'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(Icons.logout, color: cs.onPrimary, size: 20),
              onPressed: () {
                ref.read(currentUserProvider.notifier).logout();
                context.go('/login');
              },
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 600;
          final double screenHeight = MediaQuery.of(context).size.height;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Hero Section ─────────────────────────────────────────
                Container(
                  height: screenHeight - kToolbarHeight,
                  width: double.infinity,
                  color: cs.surface,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Background ghost text
                      Positioned(
                        top: isMobile ? -20 : -50,
                        left: isMobile ? -20 : -50,
                        child: Transform.rotate(
                          angle: -0.1,
                          child: Text(
                            'URBAN\nCULTURE',
                            style: TextStyle(
                              fontSize: isMobile ? 80 : 140,
                              fontWeight: FontWeight.w900,
                              color: cs.surfaceContainerHighest,
                              height: 0.85,
                              letterSpacing: isMobile ? -2 : -5,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: isMobile ? -40 : -80,
                        right: isMobile ? -10 : -20,
                        child: Transform.rotate(
                          angle: 0.05,
                          child: Text(
                            'STREET',
                            style: TextStyle(
                              fontSize: isMobile ? 100 : 160,
                              fontWeight: FontWeight.w900,
                              color: Colors.transparent,
                              letterSpacing: isMobile ? -2 : -5,
                            ).copyWith(
                              shadows: [
                                Shadow(
                                    offset: const Offset(-2, -2),
                                    color: cs.primary.withOpacity(0.3)),
                                Shadow(
                                    offset: const Offset(2, -2),
                                    color: cs.primary.withOpacity(0.3)),
                                Shadow(
                                    offset: const Offset(2, 2),
                                    color: cs.primary.withOpacity(0.3)),
                                Shadow(
                                    offset: const Offset(-2, 2),
                                    color: cs.primary.withOpacity(0.3)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Foreground content
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              color: cs.primary,
                              child: const Text(
                                'SEASON 1 // 2025',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 2),
                              ),
                            ),
                            const SizedBox(height: 16),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                children: [
                                  Text(
                                    'BUSTED',
                                    style: TextStyle(
                                      fontSize: isMobile ? 60 : 100,
                                      fontWeight: FontWeight.w900,
                                      color: cs.onSurface,
                                      height: 1,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  Text(
                                    'WORLD',
                                    style: TextStyle(
                                      fontSize: isMobile ? 55 : 90,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.transparent,
                                      height: 1,
                                      letterSpacing: 5,
                                    ).copyWith(
                                      shadows: [
                                        Shadow(
                                            offset: const Offset(-2, -2),
                                            color: cs.onSurface),
                                        Shadow(
                                            offset: const Offset(2, -2),
                                            color: cs.onSurface),
                                        Shadow(
                                            offset: const Offset(2, 2),
                                            color: cs.onSurface),
                                        Shadow(
                                            offset: const Offset(-2, 2),
                                            color: cs.onSurface),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: cs.onSurface, width: 2)),
                              child: Text(
                                'REDEFINE YOUR REALITY.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: cs.onSurface,
                                  letterSpacing: isMobile ? 2 : 4,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 12 : 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 60),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                ElevatedButton(
                                  onPressed: () => context.push('/shop'),
                                  child: Text('SHOP DROP',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: isMobile ? 14 : 16,
                                          letterSpacing: 1)),
                                ),
                                OutlinedButton(
                                  onPressed: () => context.push('/lookbook'),
                                  child: Text('LOOKBOOK',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: isMobile ? 14 : 16,
                                          letterSpacing: 1)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
