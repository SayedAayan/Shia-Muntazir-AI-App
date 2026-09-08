import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Global callback for when a notification is tapped
  static void Function(String? payload)? onNotificationTapped;

  /// Initialize local and push notifications
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Android Initialization Settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 2. Darwin (iOS) Initialization Settings
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (onNotificationTapped != null) {
          onNotificationTapped!(response.payload);
        }
      },
    );

    // 3. Create Android Notification Channel for Prayer Check-ins
    const prayerChannel = AndroidNotificationChannel(
      'prayer_checkins',
      'Prayer Check-In Reminders',
      description: 'Daily Shia prayer window check-in alerts and qadha tracking',
      importance: Importance.high,
      playSound: true,
    );

    final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(prayerChannel);
      // Request notification permission for Android 13+ (SDK 33+)
      await androidPlugin.requestNotificationsPermission();
    }

    // 4. Firebase Messaging setup (if available)
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('FCM Notification permission status: ${settings.authorizationStatus}');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        if (notification != null) {
          showGeneralNotification(
            title: notification.title ?? 'Muntazir',
            body: notification.body ?? '',
            payload: message.data['route'],
          );
        }
      });
    } catch (e) {
      debugPrint('FCM initialization note: $e');
    }

    _isInitialized = true;
  }

  /// Show a prayer check-in alert
  static Future<void> showPrayerCheckInNotification({
    required String prayerName,
    String? prayerTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'prayer_checkins',
      'Prayer Check-In Reminders',
      channelDescription: 'Daily Shia prayer window check-in alerts and qadha tracking',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Prayer Check-in',
      styleInformation: BigTextStyleInformation(''),
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    final id = prayerName.hashCode & 0x7FFFFFFF;
    await _localNotifications.show(
      id: id,
      title: 'Have you performed $prayerName?',
      body: prayerTime != null
          ? 'The window for $prayerName ($prayerTime) is open. Tap to confirm fulfillment.'
          : 'Tap to mark $prayerName as fulfilled or log for Qadha.',
      notificationDetails: notificationDetails,
      payload: 'prayer_checkin:$prayerName',
    );
  }

  /// Show a follow-up reminder before prayer window closes
  static Future<void> showFollowUpReminder({
    required String prayerName,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'prayer_checkins',
      'Prayer Check-In Reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    final id = (prayerName.hashCode + 100) & 0x7FFFFFFF;
    await _localNotifications.show(
      id: id,
      title: 'Gentle Reminder: $prayerName',
      body: 'The time for $prayerName will conclude soon. Tap to record your prayer.',
      notificationDetails: notificationDetails,
      payload: 'prayer_checkin:$prayerName',
    );
  }

  /// Show a general notification
  static Future<void> showGeneralNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'general',
      'General Announcements',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      id: DateTime.now().millisecond,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }
}
