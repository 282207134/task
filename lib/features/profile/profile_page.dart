import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../shared/widgets.dart';
import '../editor/card_editor_page.dart';
import '../schedule/progress_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.store});
  final AppStore store;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int tab = 0;

  Future<void> settings() async {
    final name = TextEditingController(text: widget.store.name);
    final role = TextEditingController(text: widget.store.role);
    var notifications = widget.store.notifications;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Profile Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              TextField(
                controller: role,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Notifications'),
                value: notifications,
                onChanged: (v) => setState(() => notifications = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (name.text.trim().isNotEmpty &&
                    role.text.trim().isNotEmpty) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (saved == true) {
      await widget.store.updateProfile(
        name.text.trim(),
        role.text.trim(),
        notifications,
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
    name.dispose();
    role.dispose();
    if (mounted && widget.store.error != null) {
      showNotice(context, widget.store.error!);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) => CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(
                  height: 253,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(height: 207, color: AppColors.purple),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: TopBar(
                          'Profil',
                          leading: SmallButton(
                            label: 'Back',
                            color: AppColors.purple,
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          trailing: SmallButton(
                            label: 'Settings',
                            color: AppColors.yellow,
                            onTap: settings,
                            child: const Icon(
                              Icons.settings_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 148,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Avatar(size: 100, name: widget.store.name),
                            ),
                            const Positioned(
                              right: 0,
                              bottom: 0,
                              child: DesignIcon('OnlineDots', size: 22),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(widget.store.name, style: type(weight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(
                  widget.store.role,
                  style: type(
                    size: 13.6,
                    color: AppColors.muted,
                    weight: FontWeight.w500,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 52, 14, 28),
                  child: Row(
                    children: [
                      Expanded(child: stat('Closed Task', '115')),
                      Expanded(
                        child: stat(
                          'Open Task',
                          '${23 + widget.store.cards.length}',
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 32,
                          child: PrimaryButton(
                            'Message',
                            color: AppColors.yellow,
                            onPressed: () => showModalBottomSheet<void>(
                              context: context,
                              showDragHandle: true,
                              builder: (context) => const SafeArea(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SectionLabel('Team Messages'),
                                      SizedBox(height: 20),
                                      Icon(
                                        Icons.chat_bubble_outline,
                                        size: 36,
                                        color: AppColors.purple,
                                      ),
                                      SizedBox(height: 16),
                                      Text('No messages yet'),
                                      SizedBox(height: 10),
                                      Text(
                                        'Messaging will be available when a team service is connected.',
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 20),
                                    ],
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Divider(height: 1),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30, bottom: 24),
                  child: Row(
                    children: [
                      for (var i = 0; i < 3; i++)
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => tab = i),
                            child: Column(
                              children: [
                                Text(
                                  ['Project Tasks', 'Contacts', 'About you'][i],
                                  style: type(
                                    color: AppColors.purple,
                                    weight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 9,
                                  height: 9,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: tab == i
                                        ? AppColors.purple
                                        : Colors.transparent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
            sliver: SliverList.list(
              children: [
                if (tab == 0) ...[
                  projectTask(
                    'Dashboard Design',
                    'In Progress',
                    '1d 4h',
                    5,
                    10,
                  ),
                  projectTask(
                    'Social Media App Design',
                    'In Progress',
                    '2d 6h',
                    11,
                    32,
                  ),
                  projectTask('Contact Page', 'Done', '5d', 33, 9),
                  for (final card in widget.store.cards)
                    projectTask(
                      card.title,
                      'To Do',
                      shortDate(card.end),
                      0,
                      0,
                      card: card,
                    ),
                ] else if (tab == 1) ...[
                  for (final name in memberNames.skip(1))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: ListTile(
                        leading: Avatar(size: 42, name: name),
                        title: Text(name, style: type(size: 14)),
                        subtitle: Text(
                          'Design Team',
                          style: type(size: 12, color: AppColors.muted),
                        ),
                      ),
                    ),
                ] else
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionLabel('About you'),
                        const SizedBox(height: 16),
                        Text(
                          '${widget.store.name}\n${widget.store.role}',
                          style: type(height: 1.8),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Thoughtful design. Meaningful collaboration.',
                          style: type(
                            size: 13.6,
                            height: 1.8,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget stat(String label, String value) => Column(
    children: [
      Text(label, style: type(size: 11.6, color: AppColors.muted)),
      const SizedBox(height: 4),
      Text(value, style: type(size: 13.6)),
    ],
  );

  Widget projectTask(
    String title,
    String status,
    String time,
    int comments,
    int attachments, {
    TaskCard? card,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 35,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => openPage(
            context,
            card == null
                ? ProgressPage(store: widget.store)
                : CardEditorPage(store: widget.store, card: card),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 15, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      status,
                      style: type(
                        color: status == 'In Progress'
                            ? AppColors.red
                            : AppColors.purple,
                      ),
                    ),
                    const Spacer(),
                    Text(time, style: type(size: 13.6, color: AppColors.muted)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(title, style: type(size: 13.6)),
                const SizedBox(height: 19),
                Row(
                  children: [
                    const DesignIcon('Icon5', size: 17),
                    const SizedBox(width: 6),
                    Text('$comments', style: type(size: 13.6)),
                    const SizedBox(width: 30),
                    const DesignIcon('Icon6', size: 17),
                    const SizedBox(width: 6),
                    Text('$attachments', style: type(size: 13.6)),
                    const Spacer(),
                    for (var i = 0; i < 3; i++)
                      Padding(
                        padding: EdgeInsets.only(left: i == 0 ? 0 : 10),
                        child: Avatar(size: 30, name: memberNames[i]),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
