import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/users_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(
                    bottom: BorderSide(
                        color: cs.primary.withValues(alpha: 0.4), width: 1.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: cs.primary,
                    child: const Icon(Icons.person, size: 30, color: Colors.white),
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
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            _DrawerTile(
              icon: Icons.shopping_bag_outlined,
              label: 'Store',
              onTap: () => context.pop(),
            ),
            _DrawerTile(
              icon: Icons.history_rounded,
              label: 'Order History',
              onTap: () {
                context.pop();
                context.push('/order_history');
              },
            ),
            if (currentUser?.isAdmin ?? false) ...[
              Divider(color: cs.outline.withValues(alpha: 0.3)),
              _DrawerTile(
                icon: Icons.admin_panel_settings_outlined,
                label: 'Admin Access',
                color: cs.tertiary,
                onTap: () {
                  context.pop();
                  context.push('/admin');
                },
              ),
            ],
            Divider(color: cs.outline.withValues(alpha: 0.3)),
            _DrawerTile(
              icon: Icons.logout_rounded,
              label: 'Logout',
              color: cs.error,
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
                      color: cs.onPrimary.withValues(alpha: 0.9),
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ),
            TextButton(
              onPressed: () => context.push('/shop'),
              child: Text('SHOP',
                  style: TextStyle(
                      color: cs.onPrimary.withValues(alpha: 0.6),
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
              icon: Icon(Icons.logout_rounded, color: cs.onPrimary, size: 20),
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
                // ── Hero Section ──────────────────────────────────────
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
                                    color: cs.primary.withValues(alpha: 0.3)),
                                Shadow(
                                    offset: const Offset(2, -2),
                                    color: cs.primary.withValues(alpha: 0.3)),
                                Shadow(
                                    offset: const Offset(2, 2),
                                    color: cs.primary.withValues(alpha: 0.3)),
                                Shadow(
                                    offset: const Offset(-2, 2),
                                    color: cs.primary.withValues(alpha: 0.3)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // ── Animated Foreground ──────────────────────────
                      FadeTransition(
                        opacity: _fade,
                        child: SlideTransition(
                          position: _slide,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: cs.primary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
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
                                        color:
                                            cs.onSurface.withValues(alpha: 0.5),
                                        width: 1.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
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
                                      onPressed: () =>
                                          context.push('/lookbook'),
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

// ─── Drawer Tile Helper ───────────────────────────────────────────────────────
class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final c = color ?? cs.onSurface;
    return ListTile(
      leading: Icon(icon, color: c, size: 22),
      title: Text(label,
          style:
              tt.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: c)),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      horizontalTitleGap: 8,
      onTap: onTap,
    );
  }
}
