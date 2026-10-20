import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/app_store.dart';
import '../../data/models.dart';
import '../../shared/widgets.dart';

class CardEditorPage extends StatefulWidget {
  const CardEditorPage({super.key, required this.store, this.card});
  final AppStore store;
  final TaskCard? card;
  @override
  State<CardEditorPage> createState() => _CardEditorPageState();
}

class _CardEditorPageState extends State<CardEditorPage> {
  late final title = TextEditingController(
    text: widget.card?.title ?? 'Social Media Design',
  );
  late final description = TextEditingController(
    text: widget.card?.description ?? defaultDescription,
  );
  late DateTime start = widget.card?.start ?? DateTime(2020, 5, 9);
  late DateTime end = widget.card?.end ?? DateTime(2020, 5, 13);
  late String category = widget.card?.category ?? 'Dashboard Design';
  late List<String> members = List.of(
    widget.card?.members ?? memberNames.take(3),
  );
  bool saving = false;
  String? titleError;

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  Future<void> pickDate(bool isStart) async {
    final value = await showDatePicker(
      context: context,
      initialDate: isStart ? start : end,
      firstDate: isStart ? DateTime(2020) : start,
      lastDate: DateTime(2100),
      helpText: isStart ? 'Start Time' : 'End Time',
    );
    if (value != null && mounted) {
      setState(() {
        if (isStart) {
          start = value;
          if (end.isBefore(start)) {
            end = start;
          }
        } else {
          end = value;
        }
      });
    }
  }

  Future<void> save() async {
    if (title.text.trim().isEmpty) {
      setState(() => titleError = 'Please enter a title');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => saving = true);
    await widget.store.saveCard(
      TaskCard(
        id: widget.card?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        title: title.text.trim(),
        description: description.text.trim(),
        start: start,
        end: end,
        category: category,
        members: List.of(members),
      ),
    );
    if (!mounted) return;
    if (widget.store.error != null) {
      setState(() => saving = false);
      showNotice(context, widget.store.error!);
      return;
    }
    Navigator.pop(context);
    showNotice(context, 'Task saved');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.purple,
    body: SingleChildScrollView(
      key: const Key('editor-scroll'),
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom > 0 ? 24 : 0,
      ),
      child: Column(
        children: [
          TopBar(
            widget.card == null ? 'Create New Card' : 'Edit Card',
            trailing: SmallButton(
              label: 'Save card',
              color: AppColors.yellow,
              width: 67,
              onTap: () {
                if (!saving) save();
              },
              child: Text(
                saving ? '...' : 'Save',
                style: type(
                  size: 12,
                  color: Colors.white,
                  weight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 42, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title', style: type(color: const Color(0xFFBB9CD9))),
                const SizedBox(height: 14),
                TextField(
                  key: const Key('card-title'),
                  controller: title,
                  style: type(color: Colors.white),
                  textInputAction: TextInputAction.next,
                  onChanged: (_) {
                    if (titleError != null) setState(() => titleError = null);
                  },
                  decoration: InputDecoration(
                    errorText: titleError,
                    errorStyle: type(size: 12, color: AppColors.yellow),
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFF550DCA)),
                Text(
                  'Creation Date',
                  style: type(color: const Color(0xFFBB9CD9)),
                ),
                const SizedBox(height: 14),
                Text('Monday, 05 May', style: type(color: Colors.white)),
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFF550DCA)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height - 322,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(38)),
            ),
            padding: EdgeInsets.fromLTRB(
              14,
              27,
              14,
              16 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    for (final isStart in [true, false])
                      Expanded(
                        child: InkWell(
                          key: Key(isStart ? 'start-date' : 'end-date'),
                          onTap: () => pickDate(isStart),
                          child: Column(
                            children: [
                              Text(
                                isStart ? 'Start Time' : 'End Time',
                                style: type(weight: FontWeight.w500),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 20,
                                    color: AppColors.yellow,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    shortDate(isStart ? start : end),
                                    style: type(color: AppColors.muted),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 30),
                const SectionLabel('Description'),
                const SizedBox(height: 17),
                TextField(
                  key: const Key('card-description'),
                  controller: description,
                  minLines: 3,
                  maxLines: null,
                  style: type(size: 13.6, color: AppColors.muted, height: 1.8),
                ),
                const SizedBox(height: 28),
                const SectionLabel('Category'),
                const SizedBox(height: 17),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final value in categoryOptions.take(3))
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: categoryChip(value),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(flex: 7, child: categoryChip('Dashboard Design')),
                    const SizedBox(width: 10),
                    Expanded(flex: 4, child: categoryChip('Backend')),
                  ],
                ),
                const SizedBox(height: 29),
                const SectionLabel('Members'),
                const SizedBox(height: 17),
                MemberRow(
                  members: members,
                  onAdd: () async {
                    final values = await chooseMembers(context, members);
                    if (values != null && mounted) {
                      setState(() => members = values);
                    }
                  },
                ),
                const SizedBox(height: 30),
                PrimaryButton(
                  saving
                      ? 'Saving...'
                      : widget.card == null
                      ? 'Create Task'
                      : 'Update Task',
                  onPressed: saving ? null : save,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget categoryChip(String value) => Semantics(
    selected: category == value,
    child: Material(
      color: category == value ? AppColors.purple : AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => setState(() => category = value),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 35,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            horizontal: value == 'Dashboard Design' ? 40 : 26,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: type(
                size: 13.6,
                spacing: .5,
                color: category == value ? Colors.white : AppColors.muted,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
