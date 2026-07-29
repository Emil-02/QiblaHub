import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qiblahub/data/app_data.dart';
import 'package:qiblahub/data/team_data.dart';
import 'package:qiblahub/theme.dart';
import 'package:qiblahub/widgets/development_team_card.dart';
import 'package:qiblahub/widgets/development_team_sheet.dart';

String _translate(String language, String key) =>
    i18n[language]?[key] ?? i18n['id']?[key] ?? key;

Widget _testApp(Widget child, {ThemeMode themeMode = ThemeMode.light}) {
  return MaterialApp(
    theme: qhTheme(Brightness.light),
    darkTheme: qhTheme(Brightness.dark),
    themeMode: themeMode,
    home: Scaffold(body: child),
  );
}

void main() {
  test('team data contains the lecturer and six unique students', () {
    expect(TeamData.lecturer, 'Dr. ALAMSYAH, S.Pd. I., M.H');
    expect(TeamData.members, hasLength(6));
    expect(
      TeamData.members.map((member) => member.studentId).toSet(),
      hasLength(6),
    );
    expect(
      TeamData.members
          .map((member) => '${member.name}|${member.studentId}')
          .toList(),
      [
        'Dwi Azzahra Sasqila Fitri|105841118724',
        'Wuri Satya Natama|105841118824',
        'Emil Rahmat|105841119124',
        'Tyara Ayuliansyah|105841119524',
        'Gefira Nur Fatima|105841120124',
        'Muh Rafly Aprial Ridho|105841112524',
      ],
    );
    expect(
      TeamData.downloadUri.toString(),
      'https://github.com/Emil-02/QiblaHub/releases/latest',
    );
  });

  testWidgets('development team card is responsive and tappable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    var tapped = false;
    await tester.pumpWidget(
      _testApp(
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: DevelopmentTeamCard(
            translate: (key) => _translate('id', key),
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Tim Pengembang QiblaHub'), findsOneWidget);
    expect(find.text('6 Anggota Mahasiswa'), findsOneWidget);
    expect(find.text(TeamData.lecturer), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Lihat Tim'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lihat Tim'));
    expect(tapped, isTrue);
  });

  testWidgets('team sheet shows members and closes from its close button', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        Builder(
          builder: (context) => Center(
            child: FilledButton(
              onPressed: () => showDevelopmentTeamSheet(
                context,
                translate: (key) => _translate('en', key),
              ),
              child: const Text('Open team'),
            ),
          ),
        ),
        themeMode: ThemeMode.dark,
      ),
    );

    await tester.tap(find.text('Open team'));
    await tester.pumpAndSettle();

    expect(find.text('QiblaHub Development Team'), findsOneWidget);
    expect(find.text('SUPERVISING LECTURER'), findsOneWidget);
    expect(find.text(TeamData.lecturer), findsOneWidget);
    expect(find.text(TeamData.members.first.name), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('QiblaHub Development Team'), findsNothing);
  });

  testWidgets('failed APK launch displays a localized message', (tester) async {
    Uri? requestedUri;
    await tester.pumpWidget(
      _testApp(
        Builder(
          builder: (context) => Center(
            child: FilledButton(
              onPressed: () => showDevelopmentTeamSheet(
                context,
                translate: (key) => _translate('id', key),
                externalUrlLauncher: (uri) async {
                  requestedUri = uri;
                  return false;
                },
              ),
              child: const Text('Buka tim'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Buka tim'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Download QiblaHub APK'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Download QiblaHub APK'));
    await tester.pump();

    expect(requestedUri, TeamData.downloadUri);
    expect(find.text('Tidak dapat membuka halaman download'), findsOneWidget);
  });
}
