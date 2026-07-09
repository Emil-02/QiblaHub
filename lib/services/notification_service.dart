/// ═══════════════════════════════════════════════════
/// QiblaHub — Layanan Notifikasi Adzan
/// Menjadwalkan notifikasi lokal pada setiap waktu salat
/// ═══════════════════════════════════════════════════
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  /// Inisialisasi plugin, zona waktu, dan izin (dipanggil sekali saat start)
  static Future<void> init() async {
    if (_ready) return;
    try {
      tzdata.initializeTimeZones();
      try {
        final name = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(name.identifier));
      } catch (_) {
        // biarkan tz.local default (UTC) bila gagal — jarang terjadi
      }

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      await _plugin.initialize(
        settings: const InitializationSettings(android: androidInit),
      );

      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.requestNotificationsPermission();
      await android?.requestExactAlarmsPermission();
      // Hapus channel lama (tanpa suara adzan) agar tidak dipakai lagi
      await android?.deleteNotificationChannel(channelId: 'adhan_channel');

      _ready = true;
    } catch (err) {
      debugPrint('QH: notification init error → $err');
    }
  }

  // Catatan: channel ID diganti (v2) karena Android menyimpan pengaturan
  // suara channel lama secara permanen — channel baru memakai suara adzan.
  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'adhan_channel_v2',
      'Alarm Adzan',
      channelDescription: 'Alarm adzan ketika waktu salat tiba',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('adzan'),
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''),
    ),
  );

  /// Jadwalkan notifikasi adzan.
  /// [schedule] = daftar (namaSalat, waktu) — hanya waktu mendatang yang dijadwalkan.
  static Future<void> scheduleAdhan(
    List<(String name, DateTime time)> schedule,
  ) async {
    if (!_ready) await init();
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
      var id = 100;
      final now = DateTime.now();
      for (final (name, time) in schedule) {
        if (time.isBefore(now)) continue;
        final hh = time.hour.toString().padLeft(2, '0');
        final mm = time.minute.toString().padLeft(2, '0');
        await _plugin.zonedSchedule(
          id: id++,
          title: '🕌 Waktu Salat $name',
          body:
              'Telah masuk waktu salat $name pukul $hh:$mm — mari tunaikan salat.',
          scheduledDate: tz.TZDateTime.from(time, tz.local),
          notificationDetails: _details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
      debugPrint('QH: scheduled ${id - 100} adhan notifications');
    } catch (err) {
      debugPrint('QH: schedule adhan error → $err');
    }
  }

  /// Batalkan semua notifikasi adzan
  static Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }
}
