import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../utils/app_navigator.dart';

class FirebaseNotificationService {
  FirebaseNotificationService._();

  static final _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[FCM] permission: ${settings.authorizationStatus}');

    // Show foreground notifications as heads-up on iOS
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _messaging.getToken();
    debugPrint('[FCM] device token: $token');

    // Foreground — app is open
    FirebaseMessaging.onMessage.listen((message) {
      _log('foreground', message);
      _showSnackbar(message);
    });

    // Background — app was open but in background, user tapped notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _log('background-tap', message);
      _onNotificationTap(message);
    });

    // Terminated — app was closed, user tapped notification to open it
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _log('terminated-tap', initialMessage);
      _onNotificationTap(initialMessage);
    }
  }

  static void _showSnackbar(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final context = AppNavigator.navigatorKey.currentContext;
    if (context == null) {
      debugPrint('[FCM] no context for snackbar');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: ZienaColors.black,
        duration: const Duration(seconds: 5),
        content: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: ZienaColors.primary,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/images/white_logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notification.title != null)
                    Text(
                      notification.title!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  if (notification.body != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      notification.body!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _onNotificationTap(RemoteMessage message) {
    // Navigate based on message.data payload.
    // e.g.:  final bookingId = message.data['booking_id'];
    debugPrint('[FCM] tap handled — data: ${message.data}');
  }

  static void _log(String source, RemoteMessage message) {
    debugPrint('━━━━━━━━━━━━ [FCM] $source ━━━━━━━━━━━━');
    debugPrint('[FCM] message id  : ${message.messageId}');
    debugPrint('[FCM] title       : ${message.notification?.title}');
    debugPrint('[FCM] body        : ${message.notification?.body}');
    debugPrint('[FCM] data        : ${message.data}');
    debugPrint('[FCM] sent time   : ${message.sentTime}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }
}

/// Top-level handler required by Firebase for background/terminated messages.
/// Must be a top-level function annotated with @pragma('vm:entry-point').
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('━━━━━━━━━━━━ [FCM] background-silent ━━━━━━━━━━━━');
  debugPrint('[FCM] message id  : ${message.messageId}');
  debugPrint('[FCM] title       : ${message.notification?.title}');
  debugPrint('[FCM] body        : ${message.notification?.body}');
  debugPrint('[FCM] data        : ${message.data}');
  debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
}
