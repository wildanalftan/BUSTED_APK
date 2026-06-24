// Contributor: Farhanfzlwargzl
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("[Background FCM] Message received: ${message.messageId}");
  final notification = message.notification;
  if (notification != null) {
    debugPrint("[Background FCM] Title: ${notification.title}");
    debugPrint("[Background FCM] Body: ${notification.body}");
  }
}

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'order_updates_channel';
  static const String _channelName = 'Order Updates';
  static const String _channelDescription = 'Notifications for order status updates';

  static Future<void> init() async {
    if (kIsWeb) return;

    try {
      // 1. Setup Firebase Messaging Background Handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 2. Create Android Notification Channel explicitly (required Android 8+)
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            showBadge: true,
          ),
        );
        debugPrint('[LocalNotificationService] Notification channel created');
      }

      // 3. Initialize Local Notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      // 4. Force FCM to show notification even in foreground on Android
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 5. Listen to Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FCM] Foreground message received: ${message.messageId}');
        final notification = message.notification;
        if (notification != null) {
          showNotification(
            id: message.hashCode,
            title: notification.title ?? '',
            body: notification.body ?? '',
            payload: message.data['orderId'],
          );
        }
      });

      // 6. Request permissions
      await requestPermissions();
      debugPrint('[LocalNotificationService] Initialized successfully');
    } catch (e) {
      debugPrint('[LocalNotificationService] Error initializing notifications: $e');
    }
  }

  static Future<void> requestPermissions() async {
    try {
      // Request FCM permissions
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      debugPrint('[LocalNotificationService] FCM permission: ${settings.authorizationStatus}');

      // Request Android local notification permissions (Android 13+)
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        debugPrint('[LocalNotificationService] Android notif permission granted: $granted');
      }

      // Request iOS local notification permissions
      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      debugPrint('[LocalNotificationService] Error requesting permissions: $e');
    }
  }

  static Future<String?> getFcmToken() async {
    if (kIsWeb) return null;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint('[LocalNotificationService] FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('[LocalNotificationService] Error getting FCM Token: $e');
      return null;
    }
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) return;

    try {
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        ticker: title,
        styleInformation: BigTextStyleInformation(body),
        visibility: NotificationVisibility.public,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
      debugPrint('[LocalNotificationService] Showed notification: $title - $body');
    } catch (e) {
      debugPrint('[LocalNotificationService] Error showing notification: $e');
    }
  }
}
