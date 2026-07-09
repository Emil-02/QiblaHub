// Uji dasar: memastikan splash screen QiblaHub tampil.

import 'package:flutter_test/flutter_test.dart';

import 'package:qiblahub/main.dart';

void main() {
  testWidgets('Splash screen shows app name', (WidgetTester tester) async {
    await tester.pumpWidget(const QiblaHubApp());
    expect(find.text('QiblaHub'), findsOneWidget);
  });
}
