import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _notifications.initialize(settings);
    log('NotificationService initialized');
  }

  // Show upload progress
  Future<void> showUploadProgress({
    required String id,
    required String title,
    required int progress,
    required int maxProgress,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'upload_channel',
      'Uploads',
      channelDescription: 'Upload progress notifications',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: maxProgress,
      progress: progress,
      ongoing: true,
      onlyAlertOnce: true,
    );

    await _notifications.show(
      id.hashCode,
      title,
      'Uploading... ${(progress / maxProgress * 100).toInt()}%',
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
    final androidDetails = AndroidNotificationDetails(
      'download_channel',
      'Downloads',
      channelDescription: 'Download progress notifications',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: maxProgress,
      progress: progress,
      ongoing: true,
      onlyAlertOnce: true,
    );

    await _notifications.show(
      id.hashCode,
      title,
      'Downloading... ${(progress / maxProgress * 100).toInt()}%',
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
      DateTime.now().millisecondsSinceEpoch,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }

  // Cancel notification
  Future<void> cancel(String id) async {
    await _notifications.cancel(id.hashCode);
  }
}
