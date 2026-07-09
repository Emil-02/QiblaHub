/// ═══════════════════════════════════════════════════
/// QiblaHub — Aplikasi Pendamping Ibadah Digital
/// Titik masuk aplikasi
/// ═══════════════════════════════════════════════════
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'state/app_state.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  NotificationService.init(); // siapkan notifikasi adzan
  runApp(const QiblaHubApp());
}

class QiblaHubApp extends StatelessWidget {
  const QiblaHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, app, _) => MaterialApp(
          title: 'QiblaHub',
          debugShowCheckedModeBanner: false,
          theme: qhTheme(Brightness.light),
          darkTheme: qhTheme(Brightness.dark),
          themeMode: app.themeMode,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
