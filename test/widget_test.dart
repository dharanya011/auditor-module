// This is a basic Flutter widget test for the KSRCE ERP Auditor Module.

import 'package:flutter_test/flutter_test.dart';

import 'package:ksrce_auditor/main.dart';

void main() {
  testWidgets('KSRCE Auditor app renders dashboard', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KSRCEAuditorApp());

    // Verify the app shell renders with the sidebar and header.
    expect(find.text('KSRCE ERP'), findsOneWidget);
    expect(find.text('Auditor Module'), findsOneWidget);
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Welcome back, Auditor'), findsOneWidget);
  });
}