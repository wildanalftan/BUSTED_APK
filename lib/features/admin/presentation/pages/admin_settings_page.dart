import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../shop/presentation/providers/products_provider.dart';
import '../../../auth/presentation/providers/users_provider.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

class AdminSettingsPage extends ConsumerWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final activeTheme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('ADMIN SETTINGS',
            style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w900, letterSpacing: 2)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Section: General ───────────────────────────────────────────
          _sectionLabel(context, 'GENERAL'),
          const SizedBox(height: 8),
          _buildTile(
            context,
            icon: Icons.notifications_active_outlined,
            title: 'Notification Preferences',
            subtitle: 'Configure system push alerts',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Notification preferences saved successfully!')),
            ),
          ),
          _buildTile(
            context,
            icon: Icons.security_outlined,
            title: 'Security & Encryption',
            subtitle: 'Check local storage key credentials',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Secure Storage is active on your Windows workspace.')),
            ),
          ),

          const SizedBox(height: 24),

          // ── Section: Theme Customization ───────────────────────────────
          _sectionLabel(context, 'THEME CUSTOMIZATION'),
          const SizedBox(height: 8),
          _ThemeSwitcherPanel(activeTheme: activeTheme),

          const SizedBox(height: 24),

          // ── Section: Danger Zone ───────────────────────────────────────
          _sectionLabel(context, 'DANGER ZONE', color: cs.error),
          const SizedBox(height: 8),
          _DangerTile(
            onTap: () => _confirmReset(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label,
      {Color? color}) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        label,
        style: TextStyle(
          color: color ?? cs.onSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outline.withOpacity(0.3), width: 1),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: cs.primary, size: 26),
        title: Text(title,
            style: tt.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        trailing:
            Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 20),
        onTap: onTap,
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Theme.of(ctx).colorScheme.error),
            const SizedBox(width: 8),
            const Text('Reset System?',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
            'This will delete all modified and custom data. The application will restart to initial factory default state. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await StorageService.clearAll();
              ref.read(productsProvider.notifier).build();
              ref.read(usersProvider.notifier).clearAllUsers();
              ref.read(ordersProvider.notifier).clearAllOrders();
              ref.read(cartProvider.notifier).clearCart();
              ref.read(currentUserProvider.notifier).logout();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All databases reset to default state!'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.go('/login');
              }
            },
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );
  }
}

// ─── Theme Switcher Panel ─────────────────────────────────────────────────────
class _ThemeSwitcherPanel extends ConsumerWidget {
  final AppThemeMode activeTheme;

  const _ThemeSwitcherPanel({required this.activeTheme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outline.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined, color: cs.primary, size: 22),
              const SizedBox(width: 10),
              Text('Select Theme',
                  style: tt.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Changes apply instantly across the entire app.',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 16),

          // Theme option cards
          Row(
            children: AppThemeMode.values.map((mode) {
              final isActive = mode == activeTheme;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right:
                          mode == AppThemeMode.values.last ? 0 : 12),
                  child: _ThemeCard(
                    mode: mode,
                    isActive: isActive,
                    onTap: () =>
                        ref.read(themeProvider.notifier).setTheme(mode),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),
          // Active badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                color: cs.primary,
                child: Text(
                  'ACTIVE: ${activeTheme.displayName.toUpperCase()}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Individual Theme Preview Card ────────────────────────────────────────────
class _ThemeCard extends StatelessWidget {
  final AppThemeMode mode;
  final bool isActive;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.mode,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Color swatches per theme
    final (bg, surf, pri, acc) = switch (mode) {
      AppThemeMode.dark => (
          AppTheme.background,
          AppTheme.surface,
          AppTheme.primary,
          AppTheme.secondary,
        ),
      AppThemeMode.streetMural => (
          AppTheme.muralBackground,
          AppTheme.muralSurface,
          AppTheme.muralPrimary,
          AppTheme.muralAccent,
        ),
    };

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(
            color: isActive ? cs.primary : cs.outline.withOpacity(0.4),
            width: isActive ? 2.5 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: cs.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(2, 4))
                ]
              : [],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mini UI preview
            Row(
              children: [
                Container(width: 32, height: 8, color: pri),
                const SizedBox(width: 4),
                Container(width: 16, height: 8, color: acc),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              height: 40,
              color: surf,
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 36, height: 4, color: pri.withOpacity(0.8)),
                  const SizedBox(height: 3),
                  Container(
                      width: 52,
                      height: 3,
                      color: acc.withOpacity(0.6)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mode.displayName.toUpperCase(),
              style: TextStyle(
                color: isActive ? cs.primary : cs.onSurface,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            Text(
              mode.description,
              style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 9,
                  letterSpacing: 0.3),
            ),
            if (isActive) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check_box, color: cs.primary, size: 12),
                  const SizedBox(width: 2),
                  Text('Active',
                      style: TextStyle(
                          color: cs.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Danger Tile ──────────────────────────────────────────────────────────────
class _DangerTile extends StatelessWidget {
  final VoidCallback onTap;

  const _DangerTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.error.withOpacity(0.07),
        border: Border.all(color: cs.error, width: 1.5),
      ),
      child: ListTile(
        leading: Icon(Icons.delete_forever, color: cs.error, size: 28),
        title: Text('RESET SYSTEM DATABASES',
            style: tt.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.error,
                letterSpacing: 1)),
        subtitle: Text(
            'Deletes all local users, products, cart and orders history.',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        onTap: onTap,
      ),
    );
  }
}
