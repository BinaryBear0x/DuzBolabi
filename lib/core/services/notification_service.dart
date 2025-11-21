import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../constants/app_constants.dart';
import '../../data/models/product.dart';
import '../../data/models/product_status.dart';
import '../../data/repositories/product_repository.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(initSettings);

    const androidChannel = AndroidNotificationChannel(
      'expiry_reminders',
      'Son Tüketim Tarihi Hatırlatıcıları',
      description: 'Ürünlerin son tüketim tarihleri için bildirimler',
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Sabah 10:00 kırmızı alarm bildirimi için channel
    const alarmChannel = AndroidNotificationChannel(
      'red_alarm',
      'Kırmızı Alarm',
      description: 'Acil durumdaki ürünler için sabah bildirimleri',
      importance: Importance.max,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(alarmChannel);

    // Sabah alarmını schedule et
    await scheduleMorningAlarm();
  }

  static Future<void> scheduleProductNotifications(Product product) async {
    final now = DateTime.now();
    final expiryDate = product.expiryDate;
    final daysUntilExpiry = expiryDate.difference(now).inDays;

    // Cancel existing notifications for this product
    await cancelProductNotifications(product.id);

    // Schedule 7 days before
    if (daysUntilExpiry >= AppConstants.notificationDays7) {
      final notificationDate7 = expiryDate.subtract(
        const Duration(days: AppConstants.notificationDays7),
      );
      if (notificationDate7.isAfter(now)) {
        await _scheduleNotification(
          id: _getNotificationId(product.id, 7),
          title: 'Ürün Hatırlatıcısı',
          body: '${product.name} için 7 gün kaldı!',
          scheduledDate: notificationDate7,
        );
      }
    }

    // Schedule 3 days before
    if (daysUntilExpiry >= AppConstants.notificationDays3) {
      final notificationDate3 = expiryDate.subtract(
        const Duration(days: AppConstants.notificationDays3),
      );
      if (notificationDate3.isAfter(now)) {
        await _scheduleNotification(
          id: _getNotificationId(product.id, 3),
          title: 'Ürün Hatırlatıcısı',
          body: '${product.name} için 3 gün kaldı!',
          scheduledDate: notificationDate3,
        );
      }
    }

    // Schedule 1 day before
    if (daysUntilExpiry >= AppConstants.notificationDays1) {
      final notificationDate1 = expiryDate.subtract(
        const Duration(days: AppConstants.notificationDays1),
      );
      if (notificationDate1.isAfter(now)) {
        await _scheduleNotification(
          id: _getNotificationId(product.id, 1),
          title: 'Ürün Hatırlatıcısı',
          body: '${product.name} için 1 gün kaldı!',
          scheduledDate: notificationDate1,
        );
      }
    }
  }

  static Future<void> cancelProductNotifications(String productId) async {
    await _notifications.cancel(_getNotificationId(productId, 7));
    await _notifications.cancel(_getNotificationId(productId, 3));
    await _notifications.cancel(_getNotificationId(productId, 1));
  }

  static int _getNotificationId(String productId, int days) {
    // 32-bit integer sınırları içinde kalması için hash kullan
    // productId.hashCode zaten int döner (negatif olabilir)
    // days değeri 1-7 arası olduğu için hash ile birleştirirken
    // 32-bit sınırlarını aşmamak için mod alıyoruz
    final hash = productId.hashCode.abs(); // Negatif değerleri pozitife çevir
    // Hash'i mod ile küçült, sonra days ile birleştir
    // 32-bit max: 2147483647
    // Hash'in ilk 6 hanesini al, sonra days ekle (max 1 haneli)
    final baseId = hash % 100000; // 0-99999 arası
    final combined = baseId * 10 + days; // 0-999997 arası (days 1-7)
    // 32-bit max'tan küçük olduğundan emin ol
    return combined % 2147483647;
  }

  // Sabah 10:00 kırmızı alarm bildirimi
  static Future<void> scheduleMorningAlarm() async {
    // Önceki alarm bildirimini iptal et
    await _notifications.cancel(99999);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Bugün 10:00'ı geçtiyse yarın 10:00'ı schedule et
    final alarmTime = today.add(const Duration(hours: 10));
    final scheduledTime = alarmTime.isBefore(now) 
        ? alarmTime.add(const Duration(days: 1))
        : alarmTime;

    // Önce kontrol et ve bildirim içeriğini hazırla
    final alarmBody = await _getMorningAlarmBody();

    await _notifications.zonedSchedule(
      99999, // Sabit ID - her gün aynı bildirim
      'Kırmızı Alarm 🔴',
      alarmBody,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'red_alarm',
          'Kırmızı Alarm',
          channelDescription: 'Acil durumdaki ürünler için sabah bildirimleri',
          importance: Importance.max,
          priority: Priority.max,
          color: Color(0xFFFF6B6B),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Her gün aynı saatte tekrarla
    );
  }

  // Sabah alarmı için bildirim içeriğini hazırla
  static Future<String> _getMorningAlarmBody() async {
    try {
      final repository = ProductRepository();
      final allProducts = await repository.getAllProducts();
      
      // Kırmızı durumda (danger) aktif ürünleri say
      int redProductsCount = 0;
      for (final product in allProducts) {
        if (product.statusColor == 'danger' && product.status == ProductStatus.added) {
          redProductsCount++;
        }
      }

      if (redProductsCount > 0) {
        return 'Buzdolabında $redProductsCount ürün acil durumda! Hemen kontrol et.';
      } else {
        return 'Buzdolabında acil durumda ürün yok.';
      }
    } catch (e) {
      debugPrint('Morning alarm body error: $e');
      return 'Buzdolabını kontrol et.';
    }
  }


  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'expiry_reminders',
          'Son Tüketim Tarihi Hatırlatıcıları',
          channelDescription: 'Ürünlerin son tüketim tarihleri için bildirimler',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

