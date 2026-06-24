// Contributor: Farhanfzlwargzl
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bustedworld/core/providers/notification_provider.dart';

class NotificationOverlay extends ConsumerWidget {
  final Widget child;

  const NotificationOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);
    final mq = MediaQuery.of(context);

    // Responsive width: full width on small screens, capped on large screens
    final screenWidth = mq.size.width;
    final notifWidth = screenWidth < 480
        ? screenWidth - 32 // 16px margin each side on mobile
        : 380.0;

    // Top offset respects status bar height
    final topOffset = mq.padding.top + 8;

    return Stack(
      children: [
        child,
        if (notifications.isNotEmpty)
          Positioned(
            top: topOffset,
            right: 16,
            width: notifWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: notifications
                  .map((n) => _NotificationTile(notification: n))
                  .toList(),
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

class _NotificationTileState extends ConsumerState<_NotificationTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // Auto dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), _dismiss);
  }

  void _dismiss() {
    if (!mounted) return;
    _controller.reverse().then((_) {
      if (mounted) {
        ref
            .read(notificationProvider.notifier)
            .dismiss(widget.notification.id);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border.all(color: cs.primary, width: 1.5),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(Icons.notifications_active,
                        color: cs.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.notification.title.toUpperCase(),
                          style: tt.labelMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.notification.message,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.4,
                          ),
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _dismiss,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(Icons.close, size: 16, color: cs.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
