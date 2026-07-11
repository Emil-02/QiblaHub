/// ═══════════════════════════════════════════════════
/// QiblaHub — Layar Arah Kiblat (kompas)
/// ═══════════════════════════════════════════════════
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/geomag_service.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../utils/islamic_utils.dart';
import '../widgets/common.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  StreamSubscription<CompassReading>? _sub;

  bool _hasCompass = true;
  bool _gotReading = false;

  /// Status kalibrasi sensor (0=unreliable … 3=tinggi), -1 = tak diketahui.
  int _status = -1;

  // Penghalusan sirkular (komponen vektor agar aman melewati 0°/360°)
  double _sx = 0, _sy = 0;
  bool _first = true;

  /// Heading utara-sejati yang sudah dihaluskan (0–360).
  double _smooth = 0;

  /// Sudut kumulatif tanpa wrap — mencegah piringan berputar ~360°
  /// ke arah salah saat melewati utara.
  double _display = 0;

  @override
  void initState() {
    super.initState();
    _sub = GeomagService.compass.listen(
      _onCompass,
      onError: (_) => setState(() => _hasCompass = false),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onCompass(CompassReading reading) {
    // Koreksi deklinasi: heading magnetik → utara sejati (WMM).
    final decl = context.read<AppState>().magneticDeclination;
    final trueHeading = fixAngle(reading.azimuth + decl);

    // Low-pass filter pada komponen sin/cos (aman terhadap wrap).
    // Sensor fusi sudah stabil — alpha cukup ringan agar tetap responsif.
    const alpha = 0.35;
    final rad = trueHeading * math.pi / 180;
    if (_first) {
      _sx = math.cos(rad);
      _sy = math.sin(rad);
      _first = false;
    } else {
      _sx += alpha * (math.cos(rad) - _sx);
      _sy += alpha * (math.sin(rad) - _sy);
    }
    final smoothed = fixAngle(_deg(math.atan2(_sy, _sx)));

    // Delta terpendek → sudut kumulatif untuk animasi.
    var delta = smoothed - _smooth;
    if (delta > 180) delta -= 360;
    if (delta < -180) delta += 360;

    // Hindari setState berlebihan untuk perubahan < 0.2°.
    if (_gotReading && delta.abs() < 0.2 && reading.status == _status) return;

    setState(() {
      _hasCompass = true;
      _gotReading = true;
      _status = reading.status;
      _smooth = smoothed;
      _display += delta;
    });
  }

  static double _deg(double r) => r * 180 / math.pi;

  /// Sensor butuh kalibrasi? (status magnetometer unreliable/rendah)
  bool get _needsCalibration => _gotReading && _status >= 0 && _status <= 1;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final numberFmt = app.lang == 'id' ? '.' : ',';
    final distance = app.kaabaDistance.round().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => numberFmt,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(app.t('qiblaDirection')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshLocation(app),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            children: [
              // ── Kompas ──
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: _Compass(
                  heading: _smooth,
                  displayAngle: _display,
                  qibla: app.qibla,
                ),
              ),
              const SizedBox(height: 10),

              // ── Status sensor & deklinasi ──
              _StatusPill(
                needsCalibration: _needsCalibration,
                declination: app.magneticDeclination,
                live: _hasCompass && _gotReading,
                app: app,
              ),
              const SizedBox(height: 14),

              // ── Statistik ──
              Row(
                children: [
                  _statCard(
                    app.t('qiblaBearing'),
                    '${app.qibla.toStringAsFixed(1)}°',
                  ),
                  const SizedBox(width: 12),
                  _statCard(app.t('heading'), '${_smooth.round() % 360}°'),
                  const SizedBox(width: 12),
                  _statCard(app.t('distanceKaaba'), '$distance km'),
                ],
              ),
              const SizedBox(height: 18),

              // ── Peringatan kalibrasi ──
              if (_needsCalibration) ...[
                Card(
                  color: Colors.amber.withValues(alpha: 0.14),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.vibration, color: Colors.amber),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${app.t('calibrationNeeded')} — ${app.t('calibrationHint')}',
                            style: const TextStyle(fontSize: 13, height: 1.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // ── Instruksi ──
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: QhColors.gold),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _hasCompass && _gotReading
                              ? app.t('qiblaInstruction')
                              : '${app.t('qiblaInstruction')}\n\n(Sensor kompas tidak terdeteksi — arah ditampilkan dari utara.)',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.55,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // ── Tombol perbarui lokasi ──
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _refreshLocation(app),
                  icon: const Icon(Icons.my_location, size: 20),
                  label: Text(app.t('refreshLocation')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshLocation(AppState app) async {
    final ok = await app.requestLocation();
    if (mounted) {
      showToast(
        context,
        ok ? app.t('locationUpdated') : app.t('locationDenied'),
      );
    }
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: QhColors.primary,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ─────────── Pil status sensor ───────────
class _StatusPill extends StatelessWidget {
  final bool needsCalibration;
  final bool live;
  final double declination;
  final AppState app;

  const _StatusPill({
    required this.needsCalibration,
    required this.live,
    required this.declination,
    required this.app,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = !live
        ? Colors.grey
        : needsCalibration
        ? Colors.amber.shade700
        : QhColors.primary;
    final String text = !live
        ? app.t('sensorOff')
        : needsCalibration
        ? app.t('calibrationNeeded')
        : '${app.t('trueNorthActive')} · ${app.t('declination')} ${declination >= 0 ? '+' : ''}${declination.toStringAsFixed(1)}°';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            !live
                ? Icons.explore_off_outlined
                : needsCalibration
                ? Icons.vibration
                : Icons.explore_outlined,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────── Widget kompas ───────────
class _Compass extends StatelessWidget {
  /// Heading ternormalisasi (0–360) — untuk ikon Ka'bah tetap tegak.
  final double heading;

  /// Sudut kumulatif tanpa wrap — untuk rotasi piringan yang mulus.
  final double displayAngle;
  final double qibla;

  const _Compass({
    required this.heading,
    required this.displayAngle,
    required this.qibla,
  });

  @override
  Widget build(BuildContext context) {
    final size = math.min(MediaQuery.of(context).size.width * 0.78, 300.0);
    final surface = Theme.of(context).colorScheme.surface;

    return SizedBox(
      width: size,
      height: size + 10,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cincin gradasi luar
          Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const SweepGradient(
                colors: [QhColors.gold, QhColors.primary, QhColors.gold],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipOval(
              child: Container(
                color: surface,
                // Piringan kompas — berputar berlawanan heading
                child: AnimatedRotation(
                  turns: -displayAngle / 360,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: Size(size, size),
                        painter: _DialPainter(
                          tickColor: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.35),
                        ),
                      ),
                      // Huruf mata angin
                      _cardinal('N', Alignment.topCenter, QhColors.primary),
                      _cardinal(
                        'S',
                        Alignment.bottomCenter,
                        null,
                        context: context,
                      ),
                      _cardinal(
                        'E',
                        Alignment.centerRight,
                        null,
                        context: context,
                      ),
                      _cardinal(
                        'W',
                        Alignment.centerLeft,
                        null,
                        context: context,
                      ),
                      // Jarum kiblat
                      Transform.rotate(
                        angle: qibla * math.pi / 180,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 30),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Ikon Ka'bah tetap tegak
                                Transform.rotate(
                                  angle: -(qibla - heading) * math.pi / 180,
                                  child: const Text(
                                    '🕋',
                                    style: TextStyle(fontSize: 26),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 4,
                                  height: size * 0.16,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        QhColors.gold,
                                        QhColors.gold.withValues(alpha: 0),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Pusat kompas
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: QhColors.primary,
              boxShadow: [
                BoxShadow(
                  color: QhColors.primary.withValues(alpha: 0.45),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.navigation, color: Colors.white, size: 28),
          ),
          // Penanda atas (segitiga emas)
          Positioned(
            top: 0,
            child: CustomPaint(
              size: const Size(20, 16),
              painter: _TrianglePainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardinal(
    String letter,
    Alignment alignment,
    Color? color, {
    BuildContext? context,
  }) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color:
                color ??
                Theme.of(
                  context!,
                ).colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  final Color tickColor;
  const _DialPainter({required this.tickColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = tickColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 72; i += 6) {
      final angle = i * 5 * math.pi / 180;
      final isMajor = i % 18 == 0;
      final outer = radius - 18;
      final inner = outer - (isMajor ? 12 : 7);
      canvas.drawLine(
        center + Offset(math.cos(angle), math.sin(angle)) * inner,
        center + Offset(math.cos(angle), math.sin(angle)) * outer,
        paint..strokeWidth = isMajor ? 2.5 : 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) => old.tickColor != tickColor;
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawShadow(path, Colors.black45, 2, false);
    canvas.drawPath(path, Paint()..color = QhColors.gold);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
