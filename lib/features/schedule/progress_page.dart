import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/app_store.dart';
import '../../shared/widgets.dart';
import '../profile/profile_page.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key, required this.store});
  final AppStore store;

  Future<void> editAgenda(BuildContext context) async {
    final controller = TextEditingController(text: store.agenda.join('\n'));
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Agenda'),
        content: SizedBox(
          width: 360,
          child: TextField(
            key: const Key('agenda-editor'),
            controller: controller,
            minLines: 5,
            maxLines: 10,
            style: type(size: 14, height: 1.7),
            decoration: const InputDecoration(helperText: 'One item per line'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    // Dispose after the dialog route has completed its exit animation.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    controller.dispose();
    if (result != null) {
      final values = result
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      await store.updateAgenda(values);
      if (context.mounted) showNotice(context, store.error ?? 'Agenda updated');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.purple,
    body: ListenableBuilder(
      listenable: store,
      builder: (context, _) => Column(
        children: [
          TopBar(
            'Progress',
            trailing: SmallButton(
              label: 'View profile',
              color: AppColors.avatar,
              width: 30,
              height: 30,
              child: const SizedBox.shrink(),
              onTap: () => openPage(context, ProfilePage(store: store)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 43, 14, 40),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.yellow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.white,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'Monday, May 02\n10:00 - 11:00',
                  style: type(
                    size: 13.6,
                    color: Colors.white,
                    weight: FontWeight.bold,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(38)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 66, 14, 54),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionLabel(
                              'Participants (${store.participants.length})',
                            ),
                            const SizedBox(height: 22),
                            MemberRow(
                              members: store.participants,
                              onAdd: () async {
                                final members = await chooseMembers(
                                  context,
                                  store.participants,
                                );
                                if (members != null) {
                                  await store.setParticipants(members);
                                }
                                if (context.mounted && store.error != null) {
                                  showNotice(context, store.error!);
                                }
                              },
                            ),
                            const SizedBox(height: 36),
                            const SectionLabel('Agenda'),
                            const SizedBox(height: 14),
                            for (var i = 0; i < store.agenda.length; i++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: InkWell(
                                  key: Key('agenda-$i'),
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () async {
                                    await store.toggleAgenda(i);
                                    if (context.mounted &&
                                        store.error != null) {
                                      showNotice(context, store.error!);
                                    }
                                  },
                                  child: Semantics(
                                    checked: store.checked[i],
                                    enabled: true,
                                    label: store.agenda[i],
                                    child: SizedBox(
                                      height: 34,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: store.checked[i]
                                                  ? AppColors.yellow
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: store.checked[i]
                                                  ? null
                                                  : Border.all(
                                                      color: const Color(
                                                        0xFFCFD2D5,
                                                      ),
                                                    ),
                                            ),
                                            alignment: Alignment.center,
                                            child: store.checked[i]
                                                ? const DesignIcon(
                                                    'Icon0',
                                                    size: 15,
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              store.agenda[i],
                                              style: type(size: 13.6).copyWith(
                                                decoration: store.checked[i]
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 32),
                            const Spacer(),
                            PrimaryButton(
                              'Edit',
                              onPressed: () => editAgenda(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: BottomBar(store: store),
  );
}
