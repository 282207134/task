import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../shared/widgets.dart';
import '../editor/card_editor_page.dart';
import '../profile/profile_page.dart';
import '../schedule/schedule_page.dart';
import '../schedule/progress_page.dart';

class BoardsPage extends StatefulWidget {
  const BoardsPage({super.key, required this.store});
  final AppStore store;
  @override
  State<BoardsPage> createState() => _BoardsPageState();
}

class _BoardsPageState extends State<BoardsPage> {
  int tab = 0;
  String query = '';
  final search = TextEditingController();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(
              'Taskflow',
              style: type(
                size: 26,
                color: AppColors.purple,
                weight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('A little focus. A lot of progress.', style: type(size: 12)),
            const SizedBox(height: 32),
            for (final (icon, title, page) in [
              (Icons.dashboard_outlined, 'Boards', null),
              (
                Icons.calendar_today_outlined,
                'Task Detail',
                SchedulePage(store: widget.store),
              ),
              (
                Icons.checklist_outlined,
                'Progress',
                ProgressPage(store: widget.store),
              ),
              (
                Icons.person_outline,
                'Profile',
                ProfilePage(store: widget.store),
              ),
              (
                Icons.notifications_none,
                'Notifications',
                NotificationsPage(store: widget.store),
              ),
            ])
              ListTile(
                leading: Icon(icon, color: AppColors.purple),
                title: Text(title),
                onTap: () {
                  Navigator.pop(context);
                  if (page != null) openPage(context, page);
                },
              ),
          ],
        ),
      ),
    ),
    body: ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final visible = projects
            .where(
              (p) =>
                  (tab == 0 || (tab == 2) == p.personal) &&
                  p.title.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
        final cards = widget.store.cards
            .where(
              (c) =>
                  (tab != 1) &&
                  '${c.title} ${c.category}'.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.purple,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    TopBar(
                      'Boards',
                      leading: Builder(
                        builder: (context) => SmallButton(
                          label: 'Menu',
                          onTap: () => Scaffold.of(context).openDrawer(),
                          child: const DesignIcon('Icon15', size: 22),
                        ),
                      ),
                      trailing: SmallButton(
                        label: 'Create new card',
                        color: AppColors.yellow,
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 25,
                        ),
                        onTap: () => openPage(
                          context,
                          CardEditorPage(store: widget.store),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 34, 14, 0),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF621CCD),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          key: const Key('board-search'),
                          controller: search,
                          style: type(size: 13.6, color: Colors.white),
                          onChanged: (value) => setState(() => query = value),
                          decoration: InputDecoration(
                            hintText: 'Search cards...',
                            hintStyle: type(
                              size: 13.6,
                              color: const Color(0xFFB996E8),
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFFB996E8),
                              size: 21,
                            ),
                            suffixIcon: query.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear search',
                                    icon: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      search.clear();
                                      setState(() => query = '');
                                    },
                                  ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    Row(
                      children: [
                        for (var i = 0; i < 3; i++)
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => tab = i),
                              child: SizedBox(
                                height: 64,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 12),
                                    Text(
                                      ['All Boards', 'Teams', 'Personal'][i],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: type(
                                        color: Colors.white,
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
                                            ? Colors.white
                                            : Colors.transparent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 36, 14, 30),
              sliver: SliverList.list(
                children: [
                  if (widget.store.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        widget.store.error!,
                        style: type(size: 12, color: AppColors.red),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SectionLabel('My Tasks'),
                      SmallButton(
                        label: 'Open task calendar',
                        color: AppColors.purple,
                        child: const Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.white,
                          size: 19,
                        ),
                        onTap: () => openPage(
                          context,
                          SchedulePage(store: widget.store),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  for (final (title, subtitle, color, icon) in [
                    (
                      'To Do',
                      '${8 + widget.store.cards.length} Task Now - 2 Started',
                      AppColors.red,
                      Icons.access_time,
                    ),
                    (
                      'In Progress',
                      '3 Task Now - 1 Started',
                      AppColors.yellow,
                      Icons.wb_sunny_outlined,
                    ),
                    (
                      'Done',
                      '24 Task Now - 12 Started',
                      AppColors.purple,
                      null,
                    ),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 22),
                      child: InkWell(
                        onTap: () => openPage(
                          context,
                          title == 'In Progress'
                              ? ProgressPage(store: widget.store)
                              : SchedulePage(store: widget.store),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                              ),
                              child: icon == null
                                  ? null
                                  : Icon(icon, color: Colors.white, size: 21),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: type(weight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: type(
                                      size: 13.6,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 13),
                  const SectionLabel('Active Projects'),
                  const SizedBox(height: 20),
                  if (visible.isEmpty && cards.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.search_off,
                            color: AppColors.muted,
                            size: 36,
                          ),
                          const SizedBox(height: 12),
                          Text('No matching cards', style: type()),
                          const SizedBox(height: 8),
                          Text(
                            'Try another title or board.',
                            style: type(size: 13, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: visible.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 186 / 146,
                        ),
                    itemBuilder: (context, index) {
                      final project = visible[index];
                      return Material(
                        color: Color(project.color),
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => openPage(
                            context,
                            ProgressPage(store: widget.store),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 22,
                              horizontal: 8,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  project.title,
                                  style: type(
                                    size: 13.6,
                                    color: Colors.white,
                                    weight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                Text(
                                  '${project.percent}%',
                                  style: type(
                                    size: 29.6,
                                    color: Colors.white,
                                    weight: FontWeight.bold,
                                    spacing: 2.14,
                                  ),
                                ),
                                Text(
                                  'complated',
                                  style: type(
                                    size: 13.6,
                                    color: Colors.white.withValues(
                                      alpha: index == 0 ? 1 : .45,
                                    ),
                                    weight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  for (final card in cards)
                    Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        tileColor: AppColors.surface,
                        title: Text(card.title, style: type(size: 14)),
                        subtitle: Text(
                          '${card.category} · ${shortDate(card.start)}',
                          style: type(size: 12, color: AppColors.muted),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.purple,
                        ),
                        onTap: () => openPage(
                          context,
                          CardEditorPage(store: widget.store, card: card),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}
