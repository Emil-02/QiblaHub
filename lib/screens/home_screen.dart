/// ═══════════════════════════════════════════════════
/// QiblaHub — Beranda
/// ═══════════════════════════════════════════════════
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../utils/islamic_utils.dart';
import '../widgets/common.dart';
import 'prayer_screen.dart';
import 'qibla_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int) onNavigateTab;
  const HomeScreen({super.key, required this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  static const _monthsId = [
    '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  static const _monthsEn = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  String _gregDate(AppState app) {
    final now = DateTime.now();
    final months = app.lang == 'id' ? _monthsId : _monthsEn;
    return '${now.day} ${months[now.month]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final hijri = gregorianToHijri(DateTime.now());
    final status = app.prayerStatus();
    final hour = DateTime.now().hour;
    final greetSub = hour < 11
        ? app.t('greetingMorning')
        : hour < 18
            ? app.t('greetingAfternoon')
            : app.t('greetingEvening');

    final nextDef = prayerDefs.firstWhere((p) => p.key == status.next);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero header ──
          HeroCard(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 16, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18, color: QhColors.gold),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        app.locating ? app.t('detectingLocation') : app.locationName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final ok = await app.requestLocation();
                        if (context.mounted) {
                          showToast(context,
                              ok ? app.t('locationUpdated') : app.t('locationDenied'));
                        }
                      },
                      icon: const Icon(Icons.my_location, color: Colors.white, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "Assalamu'alaikum",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  greetSub,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _dateChip(Icons.calendar_today, app.t('gregorian'), _gregDate(app)),
                    const SizedBox(width: 12),
                    _dateChip(Icons.dark_mode, app.t('hijri'), hijri.format(),
                        gold: true),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Banner salat berikutnya ──
                Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PrayerScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(color: QhColors.gold, width: 4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label(app.t('nextPrayer')),
                                const SizedBox(height: 2),
                                Text(
                                  app.lang == 'id' ? nextDef.name : nextDef.nameEn,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    color: QhColors.primary,
                                  ),
                                ),
                                Text(
                                  fmtTime(status.nextTime),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _label(app.t('countdown')),
                              const SizedBox(height: 2),
                              Text(
                                fmtCountdown(status.remaining),
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: QhColors.gold,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SectionTitle(app.t('mainFeatures')),

                // ── Kartu fitur ──
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.25,
                  children: [
                    _featureCard(
                      context,
                      icon: Icons.explore,
                      color: QhColors.primary,
                      title: app.t('qiblaDirection'),
                      subtitle: app.t('qiblaDesc'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const QiblaScreen()),
                      ),
                    ),
                    _featureCard(
                      context,
                      icon: Icons.schedule,
                      color: QhColors.gold,
                      title: app.t('prayerTimes'),
                      subtitle: app.t('prayerDesc'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PrayerScreen()),
                      ),
                    ),
                    _featureCard(
                      context,
                      icon: Icons.mosque,
                      color: const Color(0xFF00897B),
                      title: app.t('nearbyMosques'),
                      subtitle: app.t('mosquesDesc'),
                      onTap: () => widget.onNavigateTab(1),
                    ),
                    _featureCard(
                      context,
                      icon: Icons.event,
                      color: const Color(0xFF7E57C2),
                      title: app.t('hijriCalendar'),
                      subtitle: app.t('calendarDesc'),
                      onTap: () => widget.onNavigateTab(2),
                    ),
                  ],
                ),

                SectionTitle(app.t('todaySchedule')),

                // ── Mini jadwal salat ──
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    child: Column(
                      children: [
                        for (final p in prayerDefs.where((p) => !p.info))
                          _miniPrayerRow(context, app, p,
                              isCurrent: status.current == p.key),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateChip(IconData icon, String label, String value, {bool gold = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: gold ? QhColors.gold : Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: Colors.grey.shade500,
        ),
      );

  Widget _featureCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SoftIcon(icon, color: color),
              const Spacer(),
              Text(title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniPrayerRow(BuildContext context, AppState app, PrayerInfo p,
      {required bool isCurrent}) {
    final color = isCurrent
        ? QhColors.primary
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Icon(p.icon, size: 19, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              app.lang == 'id' ? p.name : p.nameEn,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
          ),
          Text(
            fmtTime(app.prayerTimes!.byKey(p.key)),
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w700,
              color: isCurrent
                  ? QhColors.primary
                  : Theme.of(context).colorScheme.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
