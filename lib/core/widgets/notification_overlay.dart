import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bustedworld/core/providers/notification_provider.dart';

class NotificationOverlay extends ConsumerWidget {
  final Widget child;

  const NotificationOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);

    return Stack(
      children: [
        child,
        if (notifications.isNotEmpty)
          Positioned(
            top: 20,
            right: 20,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: notifications.map((n) => _NotificationTile(notification: n)).toList(),
              ),
            ),
          ),
      ],
    );
  }
}

class _NotificationTile extends ConsumerStatefulWidget {
  final AppNotification notification;

  const _NotificationTile({required this.notification});

  @override
  ConsumerState<_NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends ConsumerState<_NotificationTile> {
  @override
  void initState() {
    super.initState();
    // Auto dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        ref.read(notificationProvider.notifier).dismiss(widget.notification.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.3),
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.notifications_active, color: cs.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.notification.title.toUpperCase(),
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        fontSize: 13,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.notification.message,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 18, color: cs.onSurface),
                onPressed: () {
                  ref.read(notificationProvider.notifier).dismiss(widget.notification.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
