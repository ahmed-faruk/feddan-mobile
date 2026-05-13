import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level handler required by firebase_messaging for background messages.
/// Must be annotated and outside any class.
@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  // Firebase is already initialized. The OS auto-displays the notification;
  // we only need this handler if we want background data processing.
  if (kDebugMode) debugPrint('[FCM] Background: ${message.messageId}');
}

class NotificationService {
  NotificationService._();

  static const _channelId = 'feddan_tasks';
  static const _channelName = 'مهام المزرعة';
  static const _channelDesc = 'تنبيهات المهام اليومية من فدان';

  static final _local = FlutterLocalNotificationsPlugin();

  /// Call once in main() after Firebase.initializeApp().
  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // iOS: show notification banner even when app is in foreground
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // flutter_local_notifications init (used for Android foreground display)
    await _local.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );

    // Android notification channel (required for Android 8+)
    if (Platform.isAndroid) {
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              _channelName,
              description: _channelDesc,
              importance: Importance.high,
              playSound: true,
            ),
          );
    }

    // Foreground message → show local notification (Android only;
    // iOS is handled by setForegroundNotificationPresentationOptions above)
    FirebaseMessaging.onMessage.listen(_onForeground);

    // App opened via notification tap
    FirebaseMessaging.onMessageOpenedApp.listen(_onTap);

    // Check if app was launched from a terminated-state notification
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _onTap(initial);
  }

  /// Request OS permission and save FCM token to Firestore.
  /// Call after the user authenticates.
  static Future<void> requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await _refreshAndSaveToken();
      FirebaseMessaging.instance.onTokenRefresh.listen(_saveToken);
    }
  }

  static Future<void> _refreshAndSaveToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await _saveToken(token);
  }

  static Future<void> _saveToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {
          'fcmToken': token,
          'platform': Platform.isAndroid ? 'android' : 'ios',
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      if (kDebugMode) debugPrint('[FCM] Token saved for $uid');
    } catch (e) {
      if (kDebugMode) debugPrint('[FCM] Token save failed: $e');
    }
  }

  static void _onForeground(RemoteMessage message) {
    final n = message.notification;
    if (n == null || !Platform.isAndroid) return;

    _local.show(
      message.hashCode,
      n.title,
      n.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
        ),
      ),
    );
  }

  static void _onTap(RemoteMessage message) {
    // Navigation on notification tap — handled by the router;
    // data payload can carry route hints in future.
    if (kDebugMode) debugPrint('[FCM] Tapped: ${message.data}');
  }
}
