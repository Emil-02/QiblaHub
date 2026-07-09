/// ═══════════════════════════════════════════════════
/// QiblaHub — Utilitas Islami
/// Haversine, arah kiblat, waktu salat (MWL),
/// konversi kalender Hijriah (tabular)
/// ═══════════════════════════════════════════════════
library;

import 'dart:math' as math;

import '../data/app_data.dart';

double _rad(double d) => d * math.pi / 180;
double _deg(double r) => r * 180 / math.pi;
double fixAngle(double a) => ((a % 360) + 360) % 360;
double _fixHour(double h) => ((h % 24) + 24) % 24;

/// ─────────── Jarak haversine (km) ───────────
double haversine(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0;
  final dLat = _rad(lat2 - lat1);
  final dLon = _rad(lon2 - lon1);
  final a = math.pow(math.sin(dLat / 2), 2) +
      math.cos(_rad(lat1)) * math.cos(_rad(lat2)) * math.pow(math.sin(dLon / 2), 2);
  return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

/// ─────────── Arah kiblat (derajat dari utara) ───────────
double qiblaBearing(double lat, double lon) {
  final dLon = _rad(Kaaba.lon - lon);
  final y = math.sin(dLon);
  final x = math.cos(_rad(lat)) * math.tan(_rad(Kaaba.lat)) -
      math.sin(_rad(lat)) * math.cos(dLon);
  return fixAngle(_deg(math.atan2(y, x)));
}

/// ─────────── Waktu salat (Muslim World League) ───────────
class PrayerTimes {
  final double fajr, sunrise, dhuhr, asr, maghrib, isha;

  const PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  double byKey(String key) {
    switch (key) {
      case 'fajr':
        return fajr;
      case 'sunrise':
        return sunrise;
      case 'dhuhr':
        return dhuhr;
      case 'asr':
        return asr;
      case 'maghrib':
        return maghrib;
      default:
        return isha;
    }
  }
}

class _SunPosition {
  final double declination, equation;
  const _SunPosition(this.declination, this.equation);
}

_SunPosition _sunPosition(double jd) {
  final d = jd - 2451545.0;
  final g = fixAngle(357.529 + 0.98560028 * d);
  final q = fixAngle(280.459 + 0.98564736 * d);
  final l = fixAngle(q + 1.915 * math.sin(_rad(g)) + 0.02 * math.sin(_rad(2 * g)));
  final e = 23.439 - 0.00000036 * d;
  final ra =
      _deg(math.atan2(math.cos(_rad(e)) * math.sin(_rad(l)), math.cos(_rad(l)))) / 15;
  return _SunPosition(
    _deg(math.asin(math.sin(_rad(e)) * math.sin(_rad(l)))),
    q / 15 - _fixHour(ra),
  );
}

/// Jam matahari untuk sudut tertentu (positif = di bawah horizon)
double _hourAngle(double angle, double decl, double lat) {
  final cosH = (-math.sin(_rad(angle)) - math.sin(_rad(decl)) * math.sin(_rad(lat))) /
      (math.cos(_rad(decl)) * math.cos(_rad(lat)));
  if (cosH < -1 || cosH > 1) return double.nan;
  return _deg(math.acos(cosH)) / 15;
}

PrayerTimes computePrayerTimes(DateTime date, double lat, double lon) {
  final jdn = gregorianToJd(date.year, date.month, date.day);
  final sun = _sunPosition(jdn - lon / 360);
  final decl = sun.declination;
  final tz = date.timeZoneOffset.inMinutes / 60.0;

  final noon = _fixHour(12 - sun.equation); // waktu matahari lokal
  double toLocal(double h) => _fixHour(h - lon / 15 + tz);

  // Asar: panjang bayangan 1x (Syafi'i)
  final asrAlt =
      _deg(math.atan(1 / (1 + math.tan(_rad((lat - decl).abs())))));

  return PrayerTimes(
    fajr: toLocal(noon - _hourAngle(18, decl, lat)),
    sunrise: toLocal(noon - _hourAngle(0.833, decl, lat)),
    dhuhr: toLocal(noon + 2 / 60),
    asr: toLocal(noon + _hourAngle(-asrAlt, decl, lat)),
    maghrib: toLocal(noon + _hourAngle(0.833, decl, lat)),
    isha: toLocal(noon + _hourAngle(17, decl, lat)),
  );
}

String fmtTime(double hours) {
  if (hours.isNaN) return '--:--';
  var h = hours.floor();
  var m = ((hours - h) * 60).round();
  if (m == 60) {
    m = 0;
    h = (h + 1) % 24;
  }
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

/// ─────────── Kalender Hijriah (algoritme tabular) ───────────
class HijriDate {
  final int year, month, day;
  const HijriDate(this.year, this.month, this.day);

  String format() => '$day ${hijriMonths[month]} $year H';
}

int gregorianToJd(int y, int m, int d) {
  final a = (14 - m) ~/ 12;
  final yy = y + 4800 - a;
  final mm = m + 12 * a - 3;
  return d +
      ((153 * mm + 2) ~/ 5) +
      365 * yy +
      yy ~/ 4 -
      yy ~/ 100 +
      yy ~/ 400 -
      32045;
}

DateTime jdToGregorian(int jd) {
  final a = jd + 32044;
  final b = (4 * a + 3) ~/ 146097;
  final c = a - (146097 * b) ~/ 4;
  final dd = (4 * c + 3) ~/ 1461;
  final e = c - (1461 * dd) ~/ 4;
  final m = (5 * e + 2) ~/ 153;
  final day = e - ((153 * m + 2) ~/ 5) + 1;
  final month = m + 3 - 12 * (m ~/ 10);
  final year = 100 * b + dd - 4800 + m ~/ 10;
  return DateTime(year, month, day);
}

HijriDate gregorianToHijri(DateTime date) {
  final jd = gregorianToJd(date.year, date.month, date.day);
  var l = jd - 1948440 + 10632;
  final n = (l - 1) ~/ 10631;
  l = l - 10631 * n + 354;
  final j = ((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719) +
      (l ~/ 5670) * ((43 * l) ~/ 15238);
  l = l -
      ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) -
      (j ~/ 16) * ((15238 * j) ~/ 43) +
      29;
  final m = (24 * l) ~/ 709;
  final d = l - (709 * m) ~/ 24;
  final y = 30 * n + j - 30;
  return HijriDate(y, m, d);
}

DateTime hijriToGregorian(int y, int m, int d) {
  final jd = ((11 * y + 3) ~/ 30) +
      354 * y +
      30 * m -
      ((m - 1) ~/ 2) +
      d +
      1948440 -
      385;
  return jdToGregorian(jd);
}

/// Jumlah hari dalam bulan Hijriah
int hijriMonthLength(int y, int m) {
  final start = hijriToGregorian(y, m, 1);
  final next = m == 12 ? hijriToGregorian(y + 1, 1, 1) : hijriToGregorian(y, m + 1, 1);
  return next.difference(start).inDays;
}
