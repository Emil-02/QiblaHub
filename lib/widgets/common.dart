/// ═══════════════════════════════════════════════════
/// QiblaHub — Widget & helper bersama
/// ═══════════════════════════════════════════════════
library;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Definisi waktu salat + ikon
class PrayerInfo {
  final String key;
  final String name;
  final String nameEn;
  final IconData icon;
  final bool info; // bukan waktu salat

  const PrayerInfo(this.key, this.name, this.nameEn, this.icon,
      {this.info = false});
}

const List<PrayerInfo> prayerDefs = [
  PrayerInfo('fajr', 'Subuh', 'Fajr', Icons.wb_twilight),
  PrayerInfo('sunrise', 'Terbit', 'Sunrise', Icons.wb_sunny_outlined, info: true),
  PrayerInfo('dhuhr', 'Zuhur', 'Dhuhr', Icons.light_mode),
  PrayerInfo('asr', 'Asar', 'Asr', Icons.wb_cloudy_outlined),
  PrayerInfo('maghrib', 'Magrib', 'Maghrib', Icons.brightness_4_outlined),
  PrayerInfo('isha', 'Isya', 'Isha', Icons.bedtime_outlined),
];

String fmtCountdown(Duration d) {
  final h = d.inHours.toString().padLeft(2, '0');
  final m = (d.inMinutes % 60).toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}

String fmtDistance(double km) =>
    km < 1 ? '${(km * 1000).round()} m' : '${km.toStringAsFixed(1)} km';

/// Judul bagian
class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 12),
        child: Text(
          text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      );
}

/// Motif geometris Islami (bintang 8) untuk latar hero
class GeometricPattern extends StatelessWidget {
  final double opacity;
  const GeometricPattern({super.key, this.opacity = 0.10});

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: CustomPaint(
          painter: _StarPatternPainter(opacity: opacity),
        ),
      );
}

class _StarPatternPainter extends CustomPainter {
  final double opacity;
  const _StarPatternPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const cell = 72.0;
    for (double x = 0; x < size.width + cell; x += cell) {
      for (double y = 0; y < size.height + cell; y += cell) {
        _drawStar(canvas, Offset(x + cell / 2, y + cell / 2), 26, paint);
        canvas.drawCircle(Offset(x + cell / 2, y + cell / 2), 6, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    // Bintang 4-titik sederhana (diamond star)
    path.moveTo(c.dx, c.dy - r);
    path.lineTo(c.dx + r * 0.28, c.dy - r * 0.28);
    path.lineTo(c.dx + r, c.dy);
    path.lineTo(c.dx + r * 0.28, c.dy + r * 0.28);
    path.lineTo(c.dx, c.dy + r);
    path.lineTo(c.dx - r * 0.28, c.dy + r * 0.28);
    path.lineTo(c.dx - r, c.dy);
    path.lineTo(c.dx - r * 0.28, c.dy - r * 0.28);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StarPatternPainter old) => old.opacity != opacity;
}

/// Kartu hero hijau bergradasi dengan motif
class HeroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;

  const HeroCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: borderRadius,
        child: Container(
          decoration: const BoxDecoration(gradient: QhColors.heroGradient),
          child: Stack(
            children: [
              const GeometricPattern(),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      );
}

/// Ikon berlatar lembut (untuk kartu fitur / daftar)
class SoftIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const SoftIcon(this.icon, {super.key, required this.color, this.size = 46});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(size * 0.3),
        ),
        child: Icon(icon, color: color, size: size * 0.52),
      );
}

/// SnackBar singkat
void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        duration: const Duration(seconds: 2),
      ),
    );
}
