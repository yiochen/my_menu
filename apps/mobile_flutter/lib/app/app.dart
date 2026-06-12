import 'package:flutter/material.dart';

import 'package:mymenu/app/home_shell.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/shared/theme/app_theme.dart';

class MyMenuScope extends InheritedNotifier<MyMenuState> {
  const MyMenuScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static MyMenuState of(BuildContext context) {
    final MyMenuScope? scope =
        context.dependOnInheritedWidgetOfExactType<MyMenuScope>();
    assert(scope != null, 'MyMenuScope not found.');
    return scope!.notifier!;
  }
}

class MyMenuApp extends StatefulWidget {
  const MyMenuApp({super.key});

  @override
  State<MyMenuApp> createState() => _MyMenuAppState();
}

class _MyMenuAppState extends State<MyMenuApp> {
  final MyMenuState _state = MyMenuState();

  @override
  Widget build(BuildContext context) {
    return MyMenuScope(
      notifier: _state,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MyMenu',
        theme: AppTheme.data,
        home: const HomeShell(),
      ),
    );
  }
}
