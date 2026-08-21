import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum NotificationServiceIdType { upload, download, store }

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static const int _maxAndroidNotificationId = 0x7fffffff;

  int _normalizeNotificationId(int raw) => raw & _maxAndroidNotificationId;

  int _idFromType(NotificationServiceIdType type) =>
      _normalizeNotificationId(type.name.hashCode);

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const macOS = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: android,
      iOS: ios,
      macOS: macOS,
    );

    await _notifications.initialize(settings: settings);

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    log('NotificationService initialized');
  }

  Future<void> showUploadProgress({
    required NotificationServiceIdType idType,
    required String title,
    required int progress,
    required int maxProgress,
  }) async {
    final safeMax = maxProgress <= 0 ? 100 : maxProgress;
    final safeProgress = progress.clamp(0, safeMax);
    final percent = ((safeProgress / safeMax) * 100).toInt();

    final androidDetails = AndroidNotificationDetails(
      'upload_channel',
      'Uploads',
      channelDescription: 'Upload progress notifications',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: safeMax,
      progress: safeProgress,
      ongoing: true,
      onlyAlertOnce: true,
    );

    await _notifications.show(
      id: _idFromType(idType),
      title: title,
      body: 'Uploading... $percent%',
      notificationDetails: NotificationDetails(android: androidDetails),
    );
  }

  Future<void> showDownloadProgress({
    required NotificationServiceIdType idType,
    required String title,
    required int progress,
    required int maxProgress,
  }) async {
    final safeMax = maxProgress <= 0 ? 100 : maxProgress;
    final safeProgress = progress.clamp(0, safeMax);
    final percent = ((safeProgress / safeMax) * 100).toInt();

    final androidDetails = AndroidNotificationDetails(
      'download_channel',
      'Downloads',
      channelDescription: 'Download progress notifications',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: safeMax,
      progress: safeProgress,
      ongoing: true,
      onlyAlertOnce: true,
    );

    await _notifications.show(
      id: _idFromType(idType),
      title: title,
      body: 'Downloading... $percent%',
      notificationDetails: NotificationDetails(android: androidDetails),
    );
  }

  Future<void> showStoreProgress({
    required NotificationServiceIdType idType,
    required String title,
    required double progress,
  }) async {
    final safeProgress = progress.clamp(0.0, 1.0);
    final percent = (safeProgress * 100).round();

    final androidDetails = AndroidNotificationDetails(
      'store_channel',
      'Store',
      channelDescription: 'Store/import progress notifications',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: 100,
      progress: percent,
      ongoing: true,
      playSound: false,
      enableVibration: false,
      onlyAlertOnce: true,
    );

    await _notifications.show(
      id: _idFromType(idType),
      title: title,
      body: 'Storing... $percent%',
      notificationDetails: NotificationDetails(android: androidDetails),
    );
  }

  Future<void> showCompletion({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'completion_channel',
      'Completions',
      channelDescription: 'Sync completion notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _notifications.show(
      id: _normalizeNotificationId(DateTime.now().microsecondsSinceEpoch),
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: androidDetails),
    );
  }

  Future<void> cancel(NotificationServiceIdType idType) async {
    await _notifications.cancel(id: _idFromType(idType));
  }

  Future<void> cancelWithType(NotificationServiceIdType idType) async {
    await cancel(idType);
  }
}
