/// ═══════════════════════════════════════════════════
/// QiblaHub — Layar Kalender Hijriah
/// ═══════════════════════════════════════════════════
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/app_data.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../utils/islamic_utils.dart';
import '../widgets/common.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late int _hijriYear;
  late int _hijriMonth;

  @override
  void initState() {
    super.initState();
    _goToToday();
  }

  void _goToToday() {
    final h = gregorianToHijri(DateTime.now());
    _hijriYear = h.year;
    _hijriMonth = h.month;
  }

  void _shiftMonth(int delta) {
    setState(() {
      _hijriMonth += delta;
      if (_hijriMonth > 12) {
        _hijriMonth = 1;
        _hijriYear++;
      } else if (_hijriMonth < 1) {
        _hijriMonth = 12;
        _hijriYear--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final now = DateTime.now();
    final todayHijri = gregorianToHijri(now);

    return Scaffold(
      appBar: AppBar(
        title: Text(app.t('hijriCalendar')),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () => setState(_goToToday),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Kartu hari ini ──
              Card(
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
                            Text(
                              app.t('todayHijri').toUpperCase(),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              todayHijri.format(),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: QhColors.primary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${now.day}/${now.month}/${now.year}',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SoftIcon(Icons.dark_mode,
                          color: QhColors.gold, size: 52),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Kalender bulanan ──
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () => _shiftMonth(-1),
                          ),
                          Text(
                            '${hijriMonths[_hijriMonth]} $_hijriYear H',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () => _shiftMonth(1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _weekdayHeader(context),
                      const SizedBox(height: 6),
                      _monthGrid(context, todayHijri),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _legendDot(QhColors.primary, app.t('today')),
                          const SizedBox(width: 18),
                          _legendDot(QhColors.gold, app.t('holiday')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SectionTitle(app.t('islamicHolidays')),

              // ── Daftar hari besar ──
              for (final h in islamicHolidays) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: QhColors.gold.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${h.day}',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: QhColors.gold,
                                ),
                              ),
                              Text(
                                hijriMonths[h.month].substring(0, 3).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: QhColors.gold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app.lang == 'id' ? h.name : h.nameEn,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                '${h.day} ${hijriMonths[h.month]}',
                                style: TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _weekdayHeader(BuildContext context) {
    const days = ['Ahd', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    return Row(
      children: [
        for (int i = 0; i < 7; i++)
          Expanded(
            child: Text(
              days[i],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: i == 5 ? QhColors.primary : Colors.grey.shade500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _monthGrid(BuildContext context, HijriDate todayHijri) {
    final start = hijriToGregorian(_hijriYear, _hijriMonth, 1);
    final length = hijriMonthLength(_hijriYear, _hijriMonth);
    final startWeekday = start.weekday % 7; // 0 = Ahad

    final cells = <Widget>[];
    for (int i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }

    final isTodayMonth =
        todayHijri.year == _hijriYear && todayHijri.month == _hijriMonth;

    for (int d = 1; d <= length; d++) {
      final gDate = start.add(Duration(days: d - 1));
      final isToday = isTodayMonth && todayHijri.day == d;
      final isHoliday = islamicHolidays
          .any((h) => h.day == d && h.month == _hijriMonth);
      final isFriday = gDate.weekday == DateTime.friday;

      cells.add(
        Container(
          decoration: isToday
              ? BoxDecoration(
                  color: QhColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: QhColors.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$d',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isToday
                      ? Colors.white
                      : isFriday
                          ? QhColors.primary
                          : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                '${gDate.day}/${gDate.month}',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  color: isToday
                      ? Colors.white.withValues(alpha: 0.8)
                      : Colors.grey.shade500,
                ),
              ),
              if (isHoliday)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: QhColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: cells,
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
      ],
    );
  }
}
