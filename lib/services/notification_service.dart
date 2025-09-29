import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/constants.dart';

class PushNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await flutterLocalNotificationsPlugin.initialize(settings);
  }

  Future<void> showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      'Video Call Notifications',
      channelDescription: 'Incoming call & app notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const platform = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(0, title, body, platform);
  }
}
