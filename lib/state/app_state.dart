/// ═══════════════════════════════════════════════════
/// QiblaHub — State Aplikasi (Provider / ChangeNotifier)
/// ═══════════════════════════════════════════════════
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_data.dart';
import '../services/geomag_service.dart';
import '../services/notification_service.dart';
import '../utils/islamic_utils.dart';

class AppState extends ChangeNotifier {
  double lat = DefaultLocation.lat;
  double lon = DefaultLocation.lon;
  String locationName = DefaultLocation.name;
  bool locating = false;

  String lang = 'id';
  ThemeMode themeMode = ThemeMode.light;
  bool adhanEnabled = true;

  /// Deklinasi magnetik (derajat) di lokasi saat ini — dari WMM Android.
  /// Dipakai untuk mengoreksi heading kompas ke utara sejati.
  double magneticDeclination = 0;

  PrayerTimes? prayerTimes;

  /// Masjid asli di sekitar pengguna (OpenStreetMap / Overpass).
  /// Kosong = memakai data statis sebagai cadangan.
  List<Mosque> nearbyMosques = [];
  bool loadingMosques = false;

  /// Jarak tempuh lewat jalan (km) per id masjid, dari OSRM.
  Map<int, double> roadKm = {};
  bool _enriching = false;

  AppState() {
    prayerTimes = computePrayerTimes(DateTime.now(), lat, lon);
    _loadPrefs();
    _refreshDeclination();
  }

  /// Terjemahan
  String t(String key) => i18n[lang]?[key] ?? i18n['id']![key] ?? key;

  double get qibla => qiblaBearing(lat, lon);
  double get kaabaDistance => haversine(lat, lon, Kaaba.lat, Kaaba.lon);

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    lang = prefs.getString('qh-lang') ?? 'id';
    themeMode = (prefs.getString('qh-theme') ?? 'light') == 'dark'
        ? ThemeMode.dark
        : ThemeMode.light;
    adhanEnabled = prefs.getBool('qh-adhan') ?? true;
    notifyListeners();
    if (adhanEnabled) scheduleAdhanNotifications();
  }

  Future<void> setLang(String value) async {
    lang = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('qh-lang', value);
  }

  Future<void> setDarkMode(bool dark) async {
    themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('qh-theme', dark ? 'dark' : 'light');
  }

  Future<void> setAdhanEnabled(bool value) async {
    adhanEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('qh-adhan', value);
    if (value) {
      await scheduleAdhanNotifications();
    } else {
      await NotificationService.cancelAll();
    }
  }

  /// Jadwalkan notifikasi adzan untuk hari ini (sisa) + besok
  Future<void> scheduleAdhanNotifications() async {
    if (!adhanEnabled) return;
    final names = lang == 'id'
        ? const {
            'fajr': 'Subuh',
            'dhuhr': 'Zuhur',
            'asr': 'Asar',
            'maghrib': 'Magrib',
            'isha': 'Isya',
          }
        : const {
            'fajr': 'Fajr',
            'dhuhr': 'Dhuhr',
            'asr': 'Asr',
            'maghrib': 'Maghrib',
            'isha': 'Isha',
          };

    final schedule = <(String, DateTime)>[];
    final now = DateTime.now();
    for (var day = 0; day < 2; day++) {
      final date = now.add(Duration(days: day));
      final pt = computePrayerTimes(date, lat, lon);
      for (final entry in names.entries) {
        final h = pt.byKey(entry.key);
        if (h.isNaN) continue;
        var hour = h.floor();
        var minute = ((h - hour) * 60).round();
        if (minute == 60) {
          minute = 0;
          hour = (hour + 1) % 24;
        }
        schedule.add((
          entry.value,
          DateTime(date.year, date.month, date.day, hour, minute),
        ));
      }
    }
    await NotificationService.scheduleAdhan(schedule);
  }

  /// Minta lokasi perangkat; kembalikan true jika berhasil
  Future<bool> requestLocation() async {
    locating = true;
    notifyListeners();
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _applyDefault();
        return false;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _applyDefault();
        return false;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      lat = pos.latitude;
      lon = pos.longitude;
      locationName = '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
      _recalculate();

      // Nama kota (reverse geocoding) — opsional, boleh gagal
      try {
        final places = await Geocoding().placemarkFromCoordinates(lat, lon);
        if (places.isNotEmpty) {
          final p = places.first;
          final parts = [
            p.locality?.isNotEmpty == true
                ? p.locality
                : p.subAdministrativeArea,
            p.administrativeArea,
          ].whereType<String>().where((s) => s.isNotEmpty).toList();
          if (parts.isNotEmpty) locationName = parts.join(', ');
        }
      } catch (_) {}

      locating = false;
      notifyListeners();
      fetchNearbyMosques(); // muat masjid sekitar lokasi baru
      scheduleAdhanNotifications(); // jadwal adzan mengikuti lokasi baru
      return true;
    } catch (_) {
      _applyDefault();
      return false;
    }
  }

  /// Ambil masjid terdekat dari OpenStreetMap (Overpass API).
  /// Jika gagal (offline dll.), daftar statis tetap dipakai.
  Future<void> fetchNearbyMosques() async {
    if (loadingMosques) return;
    loadingMosques = true;
    notifyListeners();

    // Koordinat saat request dimulai — untuk mendeteksi hasil usang
    final reqLat = lat, reqLon = lon;

    // nwr = node + way + relation; tanpa limit kecil agar masjid terdekat
    // tidak terpotong (urutan hasil server bukan berdasarkan jarak!)
    final query =
        '[out:json][timeout:40];('
        'nwr["amenity"="place_of_worship"]["religion"="muslim"](around:4000,$reqLat,$reqLon);'
        'nwr["building"="mosque"](around:4000,$reqLat,$reqLon);'
        ');out center 400;';

    // Beberapa server Overpass sebagai cadangan
    const endpoints = [
      'https://overpass-api.de/api/interpreter',
      'https://overpass.kumi.systems/api/interpreter',
      'https://maps.mail.ru/osm/tools/overpass/api/interpreter',
    ];

    for (final endpoint in endpoints) {
      try {
        final uri = Uri.parse(
          '$endpoint?data=${Uri.encodeQueryComponent(query)}',
        );
        debugPrint('QH: fetching mosques from $endpoint (lat=$lat lon=$lon)');
        final res = await http
            .get(
              uri,
              headers: {
                'User-Agent': 'QiblaHub/1.0 (academic project)',
                'Accept': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 45));

        debugPrint('QH: status=${res.statusCode} bytes=${res.body.length}');
        if (res.statusCode != 200) continue;

        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final elements = (data['elements'] as List?) ?? [];
        final seen = <int>{};
        final list = <Mosque>[];
        for (final e in elements) {
          final id = e['id'] as int;
          if (!seen.add(id)) continue;

          final tags = (e['tags'] as Map?)?.cast<String, dynamic>() ?? const {};
          final num? mLat = e['lat'] ?? e['center']?['lat'];
          final num? mLon = e['lon'] ?? e['center']?['lon'];
          if (mLat == null || mLon == null) continue;

          final name = (tags['name'] as String?)?.trim();
          final addrParts = [
            tags['addr:street'],
            tags['addr:subdistrict'] ?? tags['addr:village'],
            tags['addr:city'],
          ].whereType<String>().where((s) => s.trim().isNotEmpty).toList();

          list.add(
            Mosque(
              id: id,
              // Masjid tanpa nama tetap diambil — nama & alamat akan
              // dilengkapi otomatis lewat geocoder perangkat.
              name: (name == null || name.isEmpty) ? 'Masjid' : name,
              address: addrParts.isNotEmpty
                  ? addrParts.join(', ')
                  : t('noAddress'),
              lat: mLat.toDouble(),
              lon: mLon.toDouble(),
            ),
          );
        }

        debugPrint(
          'QH: parsed ${list.length} mosques from ${elements.length} elements',
        );
        if (list.isNotEmpty) {
          if (reqLat != lat || reqLon != lon) {
            // Lokasi sudah berubah saat request berjalan — hasil usang,
            // muat ulang dengan koordinat terbaru.
            debugPrint('QH: stale result, refetching with new location');
            loadingMosques = false;
            return fetchNearbyMosques();
          }
          // Urutkan berdasar jarak lalu ambil 100 terdekat
          list.sort(
            (a, b) => haversine(
              lat,
              lon,
              a.lat,
              a.lon,
            ).compareTo(haversine(lat, lon, b.lat, b.lon)),
          );
          nearbyMosques = list.take(100).toList();
          break; // berhasil — tidak perlu server cadangan
        }
      } catch (err) {
        debugPrint('QH: overpass error at $endpoint → $err');
        // coba server berikutnya
      }
    }

    loadingMosques = false;
    notifyListeners();

    if (nearbyMosques.isNotEmpty) {
      fetchRoadDistances(); // jarak lewat rute jalan (OSRM)
      _enrichMosqueDetails(); // lengkapi nama/alamat via geocoder perangkat
    }
  }

  /// Jarak tempuh lewat jalan (bukan garis lurus) via OSRM — gratis tanpa key.
  Future<void> fetchRoadDistances() async {
    final source = nearbyMosques.isNotEmpty ? nearbyMosques : mosques;
    if (source.isEmpty) return;
    try {
      final dest = source.take(80).toList();
      final coords = StringBuffer('$lon,$lat');
      for (final m in dest) {
        coords.write(';${m.lon},${m.lat}');
      }
      final uri = Uri.parse(
        'https://router.project-osrm.org/table/v1/driving/$coords'
        '?sources=0&annotations=distance',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 30));
      if (res.statusCode != 200) return;

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final distances = ((data['distances'] as List?)?.first as List?);
      if (distances == null) return;

      final map = <int, double>{};
      for (var i = 0; i < dest.length; i++) {
        final d = distances[i + 1];
        if (d is num) map[dest[i].id] = d / 1000.0;
      }
      roadKm = map;
      debugPrint('QH: road distances loaded for ${map.length} mosques');
      notifyListeners();
    } catch (err) {
      debugPrint('QH: osrm error → $err');
      // haversine tetap dipakai sebagai cadangan
    }
  }

  /// Lengkapi nama/alamat masjid yang kosong memakai geocoder perangkat
  /// (Android Geocoder — gratis, tanpa API key).
  Future<void> _enrichMosqueDetails() async {
    if (_enriching) return;
    _enriching = true;
    final geocoder = Geocoding();
    var failures = 0;

    for (var i = 0; i < nearbyMosques.length && i < 30 && failures < 3; i++) {
      final m = nearbyMosques[i];
      final needsAddr = m.address == t('noAddress');
      final needsName = m.name == 'Masjid';
      if (!needsAddr && !needsName) continue;

      try {
        final places = await geocoder.placemarkFromCoordinates(m.lat, m.lon);
        if (places.isEmpty) continue;
        final p = places.first;
        final street = (p.street ?? p.thoroughfare ?? '').trim();
        final parts = [
          street,
          p.subLocality,
          p.locality,
        ].whereType<String>().where((s) => s.trim().isNotEmpty).toList();

        nearbyMosques[i] = Mosque(
          id: m.id,
          name: needsName && street.isNotEmpty ? 'Masjid $street' : m.name,
          address: needsAddr && parts.isNotEmpty ? parts.join(', ') : m.address,
          lat: m.lat,
          lon: m.lon,
        );
        if (i % 5 == 4) notifyListeners(); // perbarui UI bertahap
      } catch (_) {
        failures++; // geocoder tidak tersedia — berhenti setelah 3 kegagalan
      }
    }

    _enriching = false;
    notifyListeners();
  }

  void _applyDefault() {
    if (locationName.isEmpty) {
      lat = DefaultLocation.lat;
      lon = DefaultLocation.lon;
      locationName = DefaultLocation.name;
    }
    _recalculate();
    locating = false;
    notifyListeners();
  }

  void _recalculate() {
    prayerTimes = computePrayerTimes(DateTime.now(), lat, lon);
    _refreshDeclination();
  }

  Future<void> _refreshDeclination() async {
    final d = await GeomagService.declination(lat, lon);
    if (d != magneticDeclination) {
      magneticDeclination = d;
      notifyListeners();
    }
  }

  /// Salat saat ini & berikutnya
  PrayerStatus prayerStatus() {
    final pt = prayerTimes!;
    final now = DateTime.now();
    final nowH = now.hour + now.minute / 60 + now.second / 3600;
    const order = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

    String? current;
    for (final k in order) {
      if (pt.byKey(k) <= nowH) current = k;
    }
    String nextKey = order.firstWhere(
      (k) => pt.byKey(k) > nowH,
      orElse: () => '',
    );

    double nextTime;
    if (nextKey.isEmpty) {
      // Setelah Isya → Subuh besok
      nextKey = 'fajr';
      final tomorrow = now.add(const Duration(days: 1));
      nextTime = computePrayerTimes(tomorrow, lat, lon).fajr + 24;
    } else {
      nextTime = pt.byKey(nextKey);
    }

    return PrayerStatus(
      current: current,
      next: nextKey,
      nextTime: nextTime % 24,
      remaining: Duration(
        seconds: ((nextTime - nowH) * 3600).round().clamp(0, 86400 * 2),
      ),
    );
  }

  /// Masjid diurutkan berdasar jarak dari lokasi pengguna.
  /// Jarak memakai rute jalan (OSRM) bila tersedia, jika tidak garis lurus.
  List<(Mosque, double)> mosquesByDistance([String query = '']) {
    final source = nearbyMosques.isNotEmpty ? nearbyMosques : mosques;
    final q = query.trim().toLowerCase();
    final list =
        source
            .map((m) => (m, roadKm[m.id] ?? haversine(lat, lon, m.lat, m.lon)))
            .where(
              (e) =>
                  q.isEmpty ||
                  e.$1.name.toLowerCase().contains(q) ||
                  e.$1.address.toLowerCase().contains(q),
            )
            .toList()
          ..sort((a, b) => a.$2.compareTo(b.$2));
    return list;
  }
}

class PrayerStatus {
  final String? current;
  final String next;
  final double nextTime;
  final Duration remaining;

  const PrayerStatus({
    required this.current,
    required this.next,
    required this.nextTime,
    required this.remaining,
  });
}
