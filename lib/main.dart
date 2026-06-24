import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/widgets/notification_overlay.dart';
import 'core/services/storage_service.dart';
import 'core/services/firebase_service.dart';
import 'core/services/notification_service.dart';
import 'core/providers/theme_provider.dart';
import 'features/orders/presentation/providers/orders_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await FirebaseService.init();
  await LocalNotificationService.init();

  // Create a ProviderContainer early so we can load the saved theme
  // before the first frame renders.
  final container = ProviderContainer();
  await container.read(themeProvider.notifier).loadSaved();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const BustedWorldApp(),
    ),
  );
}

class BustedWorldApp extends ConsumerWidget {
  const BustedWorldApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final activeThemeMode = ref.watch(themeProvider);
    // Keep ordersProvider alive at app level so Firestore listener
    // is always active and can show local notifications on status change
    ref.watch(ordersProvider);

    return MaterialApp.router(
      title: 'BUSTEDWORLD',
      theme: AppTheme.streetMuralTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: activeThemeMode.flutterThemeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => NotificationOverlay(child: child!),
    );
  }
}
