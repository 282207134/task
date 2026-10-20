import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow/app.dart';
import 'package:taskflow/data/app_store.dart';
import 'package:taskflow/features/editor/card_editor_page.dart';
import 'package:taskflow/features/profile/profile_page.dart';
import 'package:taskflow/features/schedule/progress_page.dart';
import 'package:taskflow/features/schedule/schedule_page.dart';
import 'package:taskflow/core/theme.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Search and board filters show the right projects', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(TaskflowApp(store: await AppStore.load()));
    await tester.pumpAndSettle();
    expect(find.text('Social Media App'), findsOneWidget);
    await tester.tap(find.text('Teams'));
    await tester.pumpAndSettle();
    expect(find.text('Meditation App'), findsNothing);
    await tester.tap(find.text('Personal'));
    await tester.pumpAndSettle();
    expect(find.text('Social Media App'), findsNothing);
    await tester.enterText(find.byKey(const Key('board-search')), 'missing');
    await tester.pumpAndSettle();
    expect(find.text('No matching cards'), findsOneWidget);
  });

  for (final size in [
    const Size(390, 844),
    const Size(414, 896),
    const Size(360, 800),
  ]) {
    testWidgets('All five screens fit ${size.width} × ${size.height}', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = await AppStore.load();
      for (final page in [
        TaskflowApp(store: store),
        MaterialApp(
          theme: appTheme(),
          home: CardEditorPage(store: store),
        ),
        MaterialApp(
          theme: appTheme(),
          home: SchedulePage(store: store),
        ),
        MaterialApp(
          theme: appTheme(),
          home: ProgressPage(store: store),
        ),
        MaterialApp(
          theme: appTheme(),
          home: ProfilePage(store: store),
        ),
      ]) {
        await tester.pumpWidget(page);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }
}
