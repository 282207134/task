import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../shared/widgets.dart';
import '../editor/card_editor_page.dart';
import '../profile/profile_page.dart';
import 'progress_page.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key, required this.store});
  final AppStore store;
  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  int selectedDay = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: AppColors.purple,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TopBar(
                'Task Detail',
                leading: SmallButton(
                  label: 'Back to boards',
                  onTap: () => Navigator.popUntil(context, (r) => r.isFirst),
                  child: const DesignIcon('Icon15', size: 22),
                ),
                trailing: SmallButton(
                  label: 'View profile',
                  color: AppColors.avatar,
                  width: 30,
                  height: 30,
                  child: const SizedBox.shrink(),
                  onTap: () =>
                      openPage(context, ProfilePage(store: widget.store)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 33, 14, 14),
                child: Text(
                  'Today, ${2 + selectedDay < 10 ? '0' : ''}${2 + selectedDay} May 2020',
                  style: type(
                    size: 13.6,
                    color: Colors.white,
                    weight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < 7; i++)
                    Expanded(
                      child: InkWell(
                        key: Key('day-$i'),
                        onTap: () => setState(() => selectedDay = i),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            children: [
                              Text(
                                [
                                  'Mon',
                                  'Tue',
                                  'Wed',
                                  'Thu',
                                  'Fri',
                                  'Sat',
                                  'Sun',
                                ][i],
                                style: type(
                                  size: 13.6,
                                  color: selectedDay == i
                                      ? Colors.white
                                      : const Color(0xFFB89BDD),
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                '${i + 2}',
                                style: type(
                                  size: 13.6,
                                  color: Colors.white,
                                  weight: FontWeight.bold,
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
        Expanded(
          child: ListenableBuilder(
            listenable: widget.store,
            builder: (context, _) => ListView(
              padding: const EdgeInsets.fromLTRB(14, 36, 14, 32),
              children: [
                if (selectedDay == 0) ...[
                  timelineCard(
                    'Wakeup',
                    '08:00 AM',
                    'Donec malesuada tempus erat, vitae placerat neque hendrerit et...',
                    height: 92,
                  ),
                  timelineCard(
                    'Breakfast',
                    '09:00 AM',
                    'Duis libero quam, egestas id turpis sed, tincidunt tempus dui...',
                    height: 92,
                  ),
                  timelineCard(
                    'Meeting',
                    '10:30 AM',
                    'Lorem ipsum dolor sit amet, consectetur tellus at acium elit...',
                    active: true,
                    height: 148,
                  ),
                  timelineCard(
                    'Dashboard Design',
                    '13:00 PM',
                    'Etiam scelerisque suscipit tortor, sed porta odio consectetur in...',
                    last: true,
                    height: 92,
                  ),
                ] else ...[
                  timelineCard(
                    'Design Review',
                    '09:00 AM',
                    'Review this week’s work with the team.',
                    height: 92,
                  ),
                  timelineCard(
                    'Focus Time',
                    '11:00 AM',
                    'A little room to make something great.',
                    active: true,
                    last: true,
                    height: 148,
                  ),
                ],
                for (final card in widget.store.cards)
                  Padding(
                    padding: const EdgeInsets.only(left: 50, top: 16),
                    child: ListTile(
                      tileColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      title: Text(card.title, style: type(size: 14)),
                      subtitle: Text(
                        '${shortDate(card.start)} – ${shortDate(card.end)}',
                        style: type(size: 12, color: AppColors.muted),
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
        ),
      ],
    ),
    bottomNavigationBar: BottomBar(store: widget.store, selected: 0),
  );

  Widget timelineCard(
    String title,
    String time,
    String description, {
    bool active = false,
    bool last = false,
    required double height,
  }) => SizedBox(
    height: height + (last ? 0 : 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 50,
          child: Column(
            children: [
              Container(
                width: active ? 26 : 16,
                height: active ? 26 : 16,
                decoration: BoxDecoration(
                  color: active ? const Color(0xFFF2EAFF) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.purple, width: 2),
                ),
                child: active
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.purple,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              if (!last)
                Expanded(
                  child: Container(
                    width: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    color: AppColors.purple,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: Material(
            color: active ? AppColors.purple : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () => openPage(context, ProgressPage(store: widget.store)),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: height,
                padding: const EdgeInsets.fromLTRB(18, 15, 18, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: type(
                              weight: FontWeight.w500,
                              color: active ? Colors.white : AppColors.ink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          time,
                          style: type(
                            size: 13.6,
                            color: active ? Colors.white : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: type(
                        size: 11.6,
                        height: 1.65,
                        color: active ? Colors.white : AppColors.muted,
                      ),
                    ),
                    if (active) ...[
                      const Spacer(),
                      Row(
                        children: [
                          for (final name in widget.store.participants.take(3))
                            Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: Avatar(size: 30, name: name),
                            ),
                          const Spacer(),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: const DesignIcon('loader', size: 22),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
