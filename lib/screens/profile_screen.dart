/// ═══════════════════════════════════════════════════
/// QiblaHub — Layar Pengaturan
/// ═══════════════════════════════════════════════════
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: Text(app.t('profile'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Kartu profil ──
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: QhColors.heroGradient,
                            border: Border.all(color: QhColors.gold, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: QhColors.primary.withValues(alpha: 0.35),
                                blurRadius: 22,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.mosque,
                            size: 42,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          app.t('guestUser'),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: QhColors.gold,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              app.locationName,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              _sectionTitle(app.t('settings')),

              // ── Pengaturan ──
              Card(
                child: Column(
                  children: [
                    _settingRow(
                      context,
                      icon: Icons.dark_mode_outlined,
                      label: app.t('darkMode'),
                      trailing: Switch(
                        value: app.themeMode == ThemeMode.dark,
                        activeThumbColor: Colors.white,
                        activeTrackColor: QhColors.primary,
                        onChanged: (v) => app.setDarkMode(v),
                      ),
                    ),
                    const Divider(height: 1, indent: 70),
                    _settingRow(
                      context,
                      icon: Icons.notifications_active_outlined,
                      label: app.t('adhanAlarm'),
                      trailing: Switch(
                        value: app.adhanEnabled,
                        activeThumbColor: Colors.white,
                        activeTrackColor: QhColors.primary,
                        onChanged: (v) => app.setAdhanEnabled(v),
                      ),
                    ),
                    const Divider(height: 1, indent: 70),
                    _settingRow(
                      context,
                      icon: Icons.translate,
                      label: app.t('language'),
                      trailing: DropdownButton<String>(
                        value: app.lang,
                        underline: const SizedBox(),
                        borderRadius: BorderRadius.circular(12),
                        items: const [
                          DropdownMenuItem(
                            value: 'id',
                            child: Text('Indonesia'),
                          ),
                          DropdownMenuItem(value: 'en', child: Text('English')),
                        ],
                        onChanged: (v) {
                          if (v != null) app.setLang(v);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              _sectionTitle(app.t('about')),

              // ── Tentang ──
              Card(
                child: Column(
                  children: [
                    _settingRow(
                      context,
                      icon: Icons.info_outline,
                      label: app.t('aboutApp'),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                      onTap: () => _showInfoDialog(
                        context,
                        app.t('aboutApp'),
                        app.t('aboutBody'),
                      ),
                    ),
                    const Divider(height: 1, indent: 70),
                    _settingRow(
                      context,
                      icon: Icons.shield_outlined,
                      label: app.t('privacy'),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                      onTap: () => _showInfoDialog(
                        context,
                        app.t('privacy'),
                        app.t('privacyBody'),
                      ),
                    ),
                    const Divider(height: 1, indent: 70),
                    _settingRow(
                      context,
                      icon: Icons.tag,
                      label: app.t('version'),
                      trailing: Text(
                        '1.0.0',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),
              Center(
                child: Text(
                  'QiblaHub © 2026',
                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12),
    child: Text(
      text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    ),
  );

  Widget _settingRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: QhColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 21, color: QhColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String body) {
    final app = context.read<AppState>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        content: SingleChildScrollView(
          child: Text(
            body,
            style: const TextStyle(fontSize: 13.5, height: 1.65),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(app.t('close')),
          ),
        ],
      ),
    );
  }
}
