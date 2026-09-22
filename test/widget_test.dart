import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystcrochet_planner/main.dart';
import 'package:mystcrochet_planner/services/localization.dart';

void main() {
  testWidgets('MystCrochetApp home screen smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MystCrochetApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify app title
    expect(find.text(t('app_title')), findsOneWidget);

    // Verify template cards are visible
    expect(find.text(t('template_sweater_title')), findsOneWidget);
    expect(find.text(t('template_blanket_title')), findsOneWidget);
    expect(find.text(t('template_tote_title')), findsOneWidget);
    expect(find.text(t('template_custom_title')), findsOneWidget);
    expect(find.text(t('template_freeform_title')), findsOneWidget);
  });
}
