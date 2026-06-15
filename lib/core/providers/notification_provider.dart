import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

enum NotificationType { success, info, warning, error }

class NotificationNotifier extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() => [];

  void add(AppNotification notification) {
    state = [...state, notification];
  }

  void dismiss(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  void clear() {
    state = [];
  }
}

final notificationProvider =
    NotifierProvider<NotificationNotifier, List<AppNotification>>(
  NotificationNotifier.new,
);
