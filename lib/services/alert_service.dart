import 'dart:typed_data'; // ADD THIS IMPORT

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FreeAlertService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // For iOS (if needed)
    final DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {},
    );

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        // Handle notification tap
      },
    );
  }

  Future<void> showLeftoverAlert({
    required String restaurantName,
    required String foodType,
    required double quantity,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'leftover_channel', // channel id
      'Leftover Food Alerts', // channel name
      channelDescription: 'Alerts for leftover food',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      0,
      '🍽️ Food Available!',
      '$restaurantName has ${quantity.toStringAsFixed(1)} kg of $foodType',
      platformChannelSpecifics,
    );
  }

  Future<void> showEmergencyAlert({
    String? volunteerName,
    String? location,
  }) async {
    // Create vibration pattern
    Int64List vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 500;
    vibrationPattern[3] = 1000;

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'emergency_channel',
      'Emergency Alerts',
      channelDescription: 'Emergency alerts for volunteers',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: vibrationPattern,
    );

    final NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    String body = volunteerName != null
        ? 'Volunteer $volunteerName needs assistance'
        : 'Volunteer needs assistance';

    if (location != null) {
      body += ' at $location';
    }

    await _notificationsPlugin.show(
      1,
      '🚨 Emergency!',
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> showDonationAlert({
    required String donorName,
    required String foodType,
    required String pickupTime,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'donation_channel',
      'Donation Alerts',
      channelDescription: 'Alerts for new food donations',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      2,
      '🎁 New Donation!',
      '$donorName donated $foodType. Pickup by $pickupTime',
      platformChannelSpecifics,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }
}