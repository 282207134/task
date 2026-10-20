import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/theme.dart';
import '../data/app_store.dart';
import '../data/models.dart';
import '../features/profile/profile_page.dart';
import '../features/schedule/schedule_page.dart';

void openPage(BuildContext context, Widget page) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

void showNotice(BuildContext context, String message) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );

class DesignIcon extends StatelessWidget {
  const DesignIcon(this.asset, {super.key, this.size = 22, this.color});
  final String asset;
  final double size;
  final Color? color;
  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'assets/images/$asset.svg',
    width: size,
    height: size,
    colorFilter: color == null
        ? null
        : ColorFilter.mode(color!, BlendMode.srcIn),
  );
}

class SmallButton extends StatelessWidget {
  const SmallButton({
    super.key,
    required this.child,
    required this.onTap,
    required this.label,
    this.color,
    this.width = 32,
    this.height = 32,
    this.outlined = false,
  });
  final Widget child;
  final VoidCallback onTap;
  final String label;
  final Color? color;
  final double width, height;
  final bool outlined;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: Tooltip(
      message: label,
      child: Material(
        color: color ?? Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: outlined ? Border.all(color: AppColors.purple) : null,
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    ),
  );
}

class TopBar extends StatelessWidget {
  const TopBar(this.title, {super.key, this.leading, this.trailing});
  final String title;
  final Widget? leading, trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      14,
      math.max(46, MediaQuery.paddingOf(context).top - 14),
      14,
      0,
    ),
    child: SizedBox(
      height: 32,
      child: Row(
        children: [
          SizedBox(
            width: 67,
            child: Align(
              alignment: Alignment.centerLeft,
              child:
                  leading ??
                  Tooltip(
                    message: 'Back',
                    child: Semantics(
                      button: true,
                      label: 'Back',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.pop(context),
                        child: const SizedBox(
                          width: 32,
                          height: 32,
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: type(color: Colors.white, weight: FontWeight.w600),
            ),
          ),
          SizedBox(
            width: 67,
            child: Align(
              alignment: Alignment.centerRight,
              child: trailing ?? const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    ),
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.color = AppColors.purple,
  });
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 51,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: type(size: 12, weight: FontWeight.w700),
      ),
      child: Text(label),
    ),
  );
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) =>
      Text(text, style: type(size: 13.6, weight: FontWeight.w700));
}

class Avatar extends StatelessWidget {
  const Avatar({super.key, this.size = 50, this.name});
  final double size;
  final String? name;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: name ?? 'Team member',
    child: Semantics(
      label: name ?? 'Team member',
      image: true,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.avatar,
          borderRadius: BorderRadius.circular(size > 80 ? 20 : 8),
        ),
      ),
    ),
  );
}

class MemberRow extends StatelessWidget {
  const MemberRow({super.key, required this.members, required this.onAdd});
  final List<String> members;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        for (final name in members)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Avatar(name: name),
          ),
        SmallButton(
          label: 'Add members',
          onTap: onAdd,
          outlined: true,
          width: 50,
          height: 50,
          child: const DesignIcon('Icon', size: 24),
        ),
      ],
    ),
  );
}

Future<List<String>?> chooseMembers(
  BuildContext context,
  List<String> selected,
) => showModalBottomSheet<List<String>>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) {
    final values = Set<String>.of(selected);
    return StatefulBuilder(
      builder: (context, setState) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SectionLabel('Select Members'),
              const SizedBox(height: 14),
              for (final name in memberNames)
                CheckboxListTile(
                  title: Text(name, style: type(size: 14)),
                  value: values.contains(name),
                  onChanged: (v) => setState(
                    () => v! ? values.add(name) : values.remove(name),
                  ),
                ),
              const SizedBox(height: 12),
              PrimaryButton(
                'Done',
                onPressed: () => Navigator.pop(context, values.toList()),
              ),
            ],
          ),
        ),
      ),
    );
  },
);

class BottomBar extends StatelessWidget {
  const BottomBar({super.key, required this.store, this.selected = -1});
  final AppStore store;
  final int selected;
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 30,
          offset: Offset(0, -8),
        ),
      ],
    ),
    padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
    child: SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final (index, asset, label) in [
            (0, 'Icon1', 'Schedule'),
            (1, 'Icon2', 'Notifications'),
            (2, 'Icon3', 'Profile'),
          ])
            Transform.translate(
              offset: Offset(0, selected == index ? -13 : 0),
              child: SmallButton(
                label: label,
                width: 56,
                height: 56,
                color: selected == index ? AppColors.purple : null,
                child: DesignIcon(
                  asset,
                  color: selected == index ? Colors.white : null,
                ),
                onTap: () {
                  if (selected == index) return;
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => switch (index) {
                        0 => SchedulePage(store: store),
                        1 => NotificationsPage(store: store),
                        _ => ProfilePage(store: store),
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    ),
  );
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key, required this.store});
  final AppStore store;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: ListenableBuilder(
      listenable: store,
      builder: (context, _) => Column(
        children: [
          Container(
            color: AppColors.purple,
            padding: const EdgeInsets.only(bottom: 36),
            child: const TopBar('Notifications'),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (!store.notifications)
                  const ListTile(
                    leading: Icon(Icons.notifications_off_outlined),
                    title: Text('Notifications paused'),
                  )
                else ...[
                  const ListTile(
                    leading: Icon(
                      Icons.groups_outlined,
                      color: AppColors.purple,
                    ),
                    title: Text('Meeting starts at 10:30 AM'),
                    subtitle: Text('Your team is ready to collaborate.'),
                  ),
                  const Divider(),
                  for (final card in store.cards.reversed)
                    ListTile(
                      leading: const Icon(
                        Icons.task_alt,
                        color: AppColors.yellow,
                      ),
                      title: Text(card.title),
                      subtitle: const Text('Task saved in your workspace'),
                    ),
                  if (store.cards.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('New task activity will appear here.'),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: BottomBar(store: store, selected: 1),
  );
}
