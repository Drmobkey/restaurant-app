import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:math';
import '../models/restaurant.dart';
import 'api_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
      
  }

  static Future<void> scheduleDaily() async {
  await _notifications.zonedSchedule(
    0,
    'Waktunya Makan Siang! 🍽️',
    'Jangan lupa makan siang hari ini!',
    _nextInstanceOf11AM(),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reminder',
        'Daily Reminder',
        channelDescription: 'Notifikasi pengingat makan siang harian',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

static tz.TZDateTime _nextInstanceOf11AM() {
  final now = tz.TZDateTime.now(tz.local);
  var scheduledDate = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    11, // jam 11 siang
  );

  // Jika sekarang sudah lewat jam 11, jadwalkan untuk besok
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }

  return scheduledDate;
}

  static Duration _getInitialDelay() {
    final now = DateTime.now();
    final scheduledTime = DateTime(now.year, now.month, now.day, 11, 0);
    
    if (scheduledTime.isBefore(now)) {
      return scheduledTime.add(const Duration(days: 1)).difference(now);
    }
    return scheduledTime.difference(now);
  }

  static Future<void> cancelDaily() async {
    await Workmanager().cancelByUniqueName('daily-reminder');
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily Reminder',
      channelDescription: 'Daily restaurant reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'dailyReminderTask') {
      try {
        final apiService = ApiService();
        final restaurants = await apiService.getRestaurants();
        
        if (restaurants.isNotEmpty) {
          final random = Random();
          final randomRestaurant = restaurants[random.nextInt(restaurants.length)];
          
          await NotificationService.showNotification(
            title: 'Waktunya Makan Siang! 🍽️',
            body: 'Coba ${randomRestaurant.name} di ${randomRestaurant.city} dengan rating ${randomRestaurant.rating}⭐',
          );
        }
      } catch (e) {
        await NotificationService.showNotification(
          title: 'Waktunya Makan Siang! 🍽️',
          body: 'Jangan lupa makan siang hari ini!',
        );
      }
    }
    return Future.value(true);
  });
}