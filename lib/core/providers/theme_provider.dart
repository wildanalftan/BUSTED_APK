import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

// ─── Enum ────────────────────────────────────────────────────────────────────
enum AppThemeMode { dark, streetMural }

extension AppThemeModeExt on AppThemeMode {
  String get storageKey => name; // 'dark' | 'streetMural'

  ThemeData get themeData {
    switch (this) {
      case AppThemeMode.dark:
        return AppTheme.darkTheme;
      case AppThemeMode.streetMural:
        return AppTheme.streetMuralTheme;
    }
  }

  ThemeMode get flutterThemeMode {
    switch (this) {
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.streetMural:
        return ThemeMode.light;
    }
  }

  String get displayName {
    switch (this) {
      case AppThemeMode.dark:
        return 'Street Dark';
      case AppThemeMode.streetMural:
        return 'Street Mural';
    }
  }

  String get description {
    switch (this) {
      case AppThemeMode.dark:
        return 'Brutalist pitch-black, neon red';
      case AppThemeMode.streetMural:
        return 'Concrete wall, spray-paint vivid';
    }
  }
}

// ─── Notifier ────────────────────────────────────────────────────────────────
class ThemeNotifier extends Notifier<AppThemeMode> {
  static const _storageKey = 'app_theme_mode';

  @override
  AppThemeMode build() {
    // Default dark; will be overridden by _loadSaved() called from main
    return AppThemeMode.dark;
  }

  /// Call once at startup after StorageService.init()
  Future<void> loadSaved() async {
    final saved = await StorageService.read(_storageKey);
    if (saved != null) {
      final found = AppThemeMode.values.where((m) => m.storageKey == saved);
      if (found.isNotEmpty) {
        state = found.first;
      }
    }
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;
    await StorageService.write(_storageKey, mode.storageKey);
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────
final themeProvider = NotifierProvider<ThemeNotifier, AppThemeMode>(
  ThemeNotifier.new,
);
