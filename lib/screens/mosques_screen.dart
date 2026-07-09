/// ═══════════════════════════════════════════════════
/// QiblaHub — Layar Masjid Terdekat
/// ═══════════════════════════════════════════════════
library;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/app_data.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'mosque_detail_screen.dart';

Future<void> openInMaps(double lat, double lon) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
  );
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<void> openRoute(double lat, double lon) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon',
  );
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class MosquesScreen extends StatefulWidget {
  const MosquesScreen({super.key});

  @override
  State<MosquesScreen> createState() => _MosquesScreenState();
}

class _MosquesScreenState extends State<MosquesScreen> {
  String _query = '';
  final _mapController = MapController();
  double? _lastLat, _lastLon;

  @override
  void initState() {
    super.initState();
    // Muat masjid sekitar saat layar dibuka bila belum ada hasil
    // (tunggu dulu bila GPS masih mencari lokasi)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final app = context.read<AppState>();
      if (app.nearbyMosques.isEmpty && !app.loadingMosques && !app.locating) {
        app.fetchNearbyMosques();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final items = app.mosquesByDistance(_query);

    // Pindahkan peta bila lokasi pengguna berubah
    if (_lastLat != app.lat || _lastLon != app.lon) {
      final firstCenter = _lastLat == null;
      _lastLat = app.lat;
      _lastLon = app.lon;
      if (!firstCenter) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            _mapController.move(LatLng(app.lat, app.lon), 14.5);
          } catch (_) {}
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(app.t('nearbyMosques')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: app.loadingMosques
                ? null
                : () => app.fetchNearbyMosques(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Pencarian ──
              TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: app.t('searchPlaceholder'),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 16),

              // ── Indikator memuat masjid sekitar ──
              if (app.loadingMosques) ...[
                Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: QhColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      app.t('loadingMosques'),
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // ── Peta interaktif ──
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  height: 220,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(app.lat, app.lon),
                      initialZoom: 11.5,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.qiblahub.qiblahub',
                      ),
                      MarkerLayer(
                        markers: [
                          // Masjid (terdekat = pin emas lebih besar)
                          for (final (i, (m, _)) in items.indexed)
                            Marker(
                              point: LatLng(m.lat, m.lon),
                              width: i == 0 ? 48 : 40,
                              height: i == 0 ? 48 : 40,
                              alignment: Alignment.topCenter,
                              child: GestureDetector(
                                onTap: () => _openDetail(m),
                                child: Icon(
                                  Icons.location_on,
                                  color: i == 0
                                      ? QhColors.gold
                                      : QhColors.primary,
                                  size: i == 0 ? 46 : 36,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black45,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          // Posisi pengguna (di atas pin masjid)
                          Marker(
                            point: LatLng(app.lat, app.lon),
                            width: 44,
                            height: 44,
                            child: const Icon(
                              Icons.person_pin_circle,
                              color: Colors.blueAccent,
                              size: 40,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── Judul daftar ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SectionTitle(app.t('mosqueList')),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: QhColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${items.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: QhColors.primary,
                      ),
                    ),
                  ),
                ],
              ),

              // ── Daftar masjid ──
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.mosque,
                          size: 44,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          app.t('noMosque'),
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                for (final (i, (m, dist)) in items.indexed) ...[
                  _mosqueCard(context, app, m, dist, isNearest: i == 0),
                  const SizedBox(height: 12),
                ],
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(Mosque m) {
    final app = context.read<AppState>();
    final dist = app.mosquesByDistance().firstWhere((e) => e.$1.id == m.id).$2;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MosqueDetailScreen(mosque: m, distance: dist),
      ),
    );
  }

  Widget _mosqueCard(
    BuildContext context,
    AppState app,
    Mosque m,
    double dist, {
    bool isNearest = false,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openDetail(m),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: QhColors.heroGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: QhColors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.mosque,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isNearest) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: QhColors.gold,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              app.t('nearest').toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: QhColors.goldDark,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        Text(
                          m.name,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          m.address,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.45,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: QhColors.gold.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      fmtDistance(dist),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: QhColors.gold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => openInMaps(m.lat, m.lon),
                      icon: const Icon(Icons.map_outlined, size: 17),
                      label: Text(
                        app.t('openMaps'),
                        style: const TextStyle(fontSize: 12.5),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => openRoute(m.lat, m.lon),
                      icon: const Icon(Icons.near_me, size: 17),
                      label: Text(
                        app.t('navigate'),
                        style: const TextStyle(fontSize: 12.5),
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
