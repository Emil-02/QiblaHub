/// ═══════════════════════════════════════════════════
/// QiblaHub — Layar Arah Kiblat (kompas)
/// ═══════════════════════════════════════════════════
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double _heading = 0;
  bool _hasCompass = true;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final numberFmt = app.lang == 'id' ? '.' : ',';
    final distance = app.kaabaDistance
        .round()
        .toString()
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => numberFmt);

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
          child: StreamBuilder<CompassEvent>(
            stream: FlutterCompass.events,
            builder: (context, snapshot) {
              if (snapshot.hasError) _hasCompass = false;
              final heading = snapshot.data?.heading;
              if (heading != null) _heading = heading;

              return Column(
                children: [
                  // ── Kompas ──
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: _Compass(heading: _heading, qibla: app.qibla),
                  ),
                  const SizedBox(height: 18),

                  // ── Statistik ──
                  Row(
                    children: [
                      _statCard(app.t('qiblaBearing'),
                          '${app.qibla.toStringAsFixed(1)}°'),
                      const SizedBox(width: 12),
                      _statCard(app.t('heading'), '${_heading.round()}°'),
                      const SizedBox(width: 12),
                      _statCard(app.t('distanceKaaba'), '$distance km'),
                    ],
                  ),
                  const SizedBox(height: 18),

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
                              _hasCompass && snapshot.data?.heading != null
                                  ? app.t('qiblaInstruction')
                                  : '${app.t('qiblaInstruction')}\n\n(Sensor kompas tidak terdeteksi — arah ditampilkan dari utara.)',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.55,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.7),
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
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _refreshLocation(AppState app) async {
    final ok = await app.requestLocation();
    if (mounted) {
      showToast(context, ok ? app.t('locationUpdated') : app.t('locationDenied'));
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

/// ─────────── Widget kompas ───────────
class _Compass extends StatelessWidget {
  final double heading;
  final double qibla;

  const _Compass({required this.heading, required this.qibla});

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
                  turns: -heading / 360,
                  duration: const Duration(milliseconds: 250),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: Size(size, size),
                        painter: _DialPainter(
                          tickColor: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.35),
                        ),
                      ),
                      // Huruf mata angin
                      _cardinal('N', Alignment.topCenter, QhColors.primary),
                      _cardinal('S', Alignment.bottomCenter, null, context: context),
                      _cardinal('E', Alignment.centerRight, null, context: context),
                      _cardinal('W', Alignment.centerLeft, null, context: context),
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
                                  child: const Text('🕋',
                                      style: TextStyle(fontSize: 26)),
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

  Widget _cardinal(String letter, Alignment alignment, Color? color,
      {BuildContext? context}) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color ??
                Theme.of(context!).colorScheme.onSurface.withValues(alpha: 0.55),
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
