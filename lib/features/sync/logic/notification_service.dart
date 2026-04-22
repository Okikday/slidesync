import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static const int _maxAndroidNotificationId = 0x7fffffff;

  int _normalizeNotificationId(int raw) => raw & _maxAndroidNotificationId;

  int _idFromString(String seed) => _normalizeNotificationId(seed.hashCode);

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _notifications.initialize(settings);

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    log('NotificationService initialized');
  }

  // Show upload progress
  Future<void> showUploadProgress({
    required String id,
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
      _idFromString('upload:$id'),
      title,
      'Uploading... $percent%',
      NotificationDetails(android: androidDetails),
    );
  }

  // Show download progress
  Future<void> showDownloadProgress({
    required String id,
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
      _idFromString('download:$id'),
      title,
      'Downloading... $percent%',
      NotificationDetails(android: androidDetails),
    );
  }

  // Show completion
  Future<void> showCompletion({required String title, required String body}) async {
    const androidDetails = AndroidNotificationDetails(
      'completion_channel',
      'Completions',
      channelDescription: 'Sync completion notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _notifications.show(
      _normalizeNotificationId(DateTime.now().microsecondsSinceEpoch),
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }

  // Cancel notification
  Future<void> cancel(String id) async {
    await _notifications.cancel(_idFromString('download:$id'));
  }
}
