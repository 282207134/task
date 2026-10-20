import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow/main.dart' as app;
import 'package:taskflow/data/app_store.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Five screens, create, edit, checklist, profile, persistence', (
    tester,
  ) async {
    Future<void> capture(String name) async {
      FocusManager.instance.primaryFocus?.unfocus();
      ScaffoldMessenger.of(
        tester.element(find.byType(Scaffold).last),
      ).clearSnackBars();
      await tester.pumpAndSettle();
      // Allow the native iOS compositor to commit the final Flutter frame.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 600)),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final client = HttpClient();
        try {
          final request = await client.getUrl(
            Uri.parse('http://127.0.0.1:52837/$name'),
          );
          final response = await request.close();
          expect(response.statusCode, HttpStatus.ok);
          await response.drain<void>();
        } finally {
          client.close();
        }
      });
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppStore.storageKey);
    await app.main();
    await tester.pumpAndSettle();
    await capture('01_boards');
    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();
    await capture('10_menu');
    await tester.tap(find.text('Boards').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Create new card'));
    await tester.pumpAndSettle();
    await capture('02_create_card');
    await tester.enterText(find.byKey(const Key('card-title')), '');
    await tester.tap(find.byTooltip('Save card'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a title'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('card-title')),
      'Launch Design Review',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('start-date')));
    await tester.pumpAndSettle();
    await capture('11_date_picker');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Design').first);
    await tester.ensureVisible(find.byTooltip('Add members'));
    await tester.tap(find.byTooltip('Add members'));
    await tester.pumpAndSettle();
    await capture('12_member_picker');
    await tester.tap(find.text('Taylor Reed'));
    await tester.tap(find.text('Done').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Save card'));
    await tester.tap(find.byTooltip('Save card'));
    await tester.pumpAndSettle();
    expect((await AppStore.load()).cards.single.members.length, 4);

    await tester.enterText(find.byKey(const Key('board-search')), 'Launch');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Launch Design Review'));
    await tester.tap(find.text('Launch Design Review'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('card-title')),
      'Launch Design Review Updated',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.tap(find.byTooltip('Save card'));
    await tester.pumpAndSettle();
    expect(
      (await AppStore.load()).cards.single.title,
      'Launch Design Review Updated',
    );
    await tester.enterText(find.byKey(const Key('board-search')), '');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open task calendar'));
    await tester.pumpAndSettle();
    await capture('03_task_detail');
    await tester.tap(find.byKey(const Key('day-1')));
    await tester.pumpAndSettle();
    expect(find.text('Design Review'), findsOneWidget);
    await tester.tap(find.byKey(const Key('day-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Meeting'));
    await tester.pumpAndSettle();
    await capture('04_progress');
    await tester.tap(find.byKey(const Key('agenda-1')));
    await tester.pumpAndSettle();
    expect((await AppStore.load()).checked[1], isTrue);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await capture('13_agenda_editor');
    await tester.enterText(
      find.byKey(const Key('agenda-editor')),
      'Review layout\nReview navigation',
    );
    await tester.tap(find.text('Save').last);
    await tester.pumpAndSettle();
    expect((await AppStore.load()).agenda.length, 2);
    await tester.tap(find.byTooltip('Profile').last);
    await tester.pumpAndSettle();
    await capture('05_profile');
    await tester.tap(find.text('Message'));
    await tester.pumpAndSettle();
    await capture('14_messages');
    await tester.tapAt(const Offset(200, 200));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Contacts'));
    await tester.pumpAndSettle();
    expect(find.text('Alex Morgan'), findsOneWidget);
    await capture('06_contacts');
    await tester.tap(find.text('About you'));
    await tester.pumpAndSettle();
    await capture('07_about');
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await capture('08_settings');
    await tester.enterText(find.byType(TextField).first, 'Quiche Designer');
    await tester.tap(find.text('Save').last);
    await tester.pumpAndSettle();
    expect((await AppStore.load()).name, 'Quiche Designer');
    await tester.tap(find.byTooltip('Back').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();
    await capture('09_notifications');
    expect(tester.takeException(), isNull);
    // Leave a clean demo workspace when the test completes.
    await prefs.remove(AppStore.storageKey);
  });
}
