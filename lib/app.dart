import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'data/app_store.dart';
import 'features/boards/boards_page.dart';

class TaskflowApp extends StatelessWidget {
  const TaskflowApp({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Taskflow',
    debugShowCheckedModeBanner: false,
    theme: appTheme(),
    home: BoardsPage(store: store),
  );
}
