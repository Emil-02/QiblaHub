/// ═══════════════════════════════════════════════════
/// QiblaHub — Geomagnetik & kompas native
/// • Deklinasi magnetik (World Magnetic Model)
/// • Stream kompas dari sensor fusi Android
///   (TYPE_ROTATION_VECTOR: gyro+akselerometer+magnetometer)
/// ═══════════════════════════════════════════════════
library;

import 'package:flutter/services.dart';

/// Satu pembacaan kompas dari sensor fusi native.
class CompassReading {
  /// Heading magnetik (0–360, dari utara magnetik, searah jarum jam).
  final double azimuth;

  /// Status kalibrasi sensor (SensorManager):
  /// 0 = unreliable, 1 = rendah, 2 = sedang, 3 = tinggi.
  final int status;

  /// Estimasi akurasi heading dalam derajat (-1 = tidak diketahui).
  final double headingAccuracy;

  const CompassReading({
    required this.azimuth,
    required this.status,
    required this.headingAccuracy,
  });

  /// Perlu kalibrasi (gerakan angka 8)?
  bool get needsCalibration => status <= 1;
}

class GeomagService {
  static const _channel = MethodChannel('qiblahub/geomag');
  static const _compassChannel = EventChannel('qiblahub/compass');

  static Stream<CompassReading>? _compassStream;

  /// Stream kompas native (broadcast, dibagi antar pendengar).
  static Stream<CompassReading> get compass {
    _compassStream ??= _compassChannel.receiveBroadcastStream().map((raw) {
      final map = Map<Object?, Object?>.from(raw as Map);
      return CompassReading(
        azimuth: (map['azimuth'] as num?)?.toDouble() ?? 0,
        status: (map['status'] as num?)?.toInt() ?? -1,
        headingAccuracy: (map['headingAccuracy'] as num?)?.toDouble() ?? -1,
      );
    }).asBroadcastStream();
    return _compassStream!;
  }

  static double? _cached;
  static double? _cachedLat;
  static double? _cachedLon;

  /// Deklinasi magnetik (derajat) di posisi [lat],[lon].
  /// Positif = utara magnetik di timur utara sejati.
  /// Mengembalikan 0 bila platform tidak mendukung.
  static Future<double> declination(
    double lat,
    double lon, {
    double alt = 0,
  }) async {
    // Cache: deklinasi berubah sangat lambat terhadap posisi.
    if (_cached != null &&
        _cachedLat != null &&
        _cachedLon != null &&
        (lat - _cachedLat!).abs() < 0.05 &&
        (lon - _cachedLon!).abs() < 0.05) {
      return _cached!;
    }
    try {
      final value = await _channel.invokeMethod<double>('declination', {
        'lat': lat,
        'lon': lon,
        'alt': alt,
      });
      _cached = value ?? 0;
      _cachedLat = lat;
      _cachedLon = lon;
      return _cached!;
    } on PlatformException {
      return 0;
    } on MissingPluginException {
      return 0;
    }
  }
}
