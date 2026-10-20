import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow/data/app_store.dart';
import 'package:taskflow/data/models.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'Task edits, agenda, participants and settings survive reload',
    () async {
      final store = await AppStore.load();
      final card = TaskCard(
        id: 'test',
        title: 'Test task',
        description: 'Details',
        start: DateTime(2026, 10, 21),
        end: DateTime(2026, 10, 22),
        category: 'Design',
        members: ['Alex Morgan'],
      );
      await store.saveCard(card);
      await store.saveCard(
        TaskCard(
          id: 'test',
          title: 'Updated task',
          description: card.description,
          start: card.start,
          end: card.end,
          category: card.category,
          members: card.members,
        ),
      );
      await store.toggleAgenda(1);
      await store.updateAgenda([...store.agenda, 'New agenda item']);
      await store.setParticipants(['Alex Morgan']);
      await store.updateProfile('Test User', 'Designer', false);
      final restored = await AppStore.load();
      expect(restored.cards.single.title, 'Updated task');
      expect(restored.checked, [true, true, false, false, false, false]);
      expect(restored.participants, ['Alex Morgan']);
      expect(restored.name, 'Test User');
      expect(restored.notifications, isFalse);
      expect(restored.error, isNull);
    },
  );

  test('Rapid checklist changes are saved in order', () async {
    final store = await AppStore.load();
    await Future.wait([
      store.toggleAgenda(1),
      store.toggleAgenda(2),
      store.toggleAgenda(1),
    ]);
    expect((await AppStore.load()).checked, [true, false, true, false, false]);
  });

  test('Invalid stored data safely falls back to the demo workspace', () async {
    SharedPreferences.setMockInitialValues({AppStore.storageKey: '{invalid'});
    final store = await AppStore.load();
    expect(store.cards, isEmpty);
    expect(store.checked, [true, false, false, false, false]);
    expect(store.error, isNotNull);
  });
}
