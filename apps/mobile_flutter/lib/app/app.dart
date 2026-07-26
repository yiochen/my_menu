import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mymenu/app/app_providers.dart';
import 'package:mymenu/app/home_shell.dart';
import 'package:mymenu/core/database/app_database.dart';
import 'package:mymenu/core/network/network_status_monitor.dart';
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

  static MyMenuState read(BuildContext context) {
    final InheritedElement? element =
        context.getElementForInheritedWidgetOfExactType<MyMenuScope>();
    final MyMenuScope? scope = element?.widget as MyMenuScope?;
    assert(scope != null, 'MyMenuScope not found.');
    return scope!.notifier!;
  }
}

class MyMenuApp extends StatelessWidget {
  const MyMenuApp({
    this.database,
    this.networkStatusMonitor,
    super.key,
  });

  final AppDatabase? database;
  final NetworkStatusMonitor? networkStatusMonitor;

  @override
  Widget build(BuildContext context) {
    final AppDatabase? overrideDatabase = database;
    if (overrideDatabase == null) {
      return const ProviderScope(child: _MyMenuAppView());
    }

    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(overrideDatabase),
        if (networkStatusMonitor != null)
          networkStatusMonitorProvider.overrideWithValue(
            networkStatusMonitor!,
          ),
      ],
      child: const _MyMenuAppView(),
    );
  }
}

class _MyMenuAppView extends ConsumerWidget {
  const _MyMenuAppView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MyMenuState state = ref.watch(myMenuStateProvider);
    return MyMenuScope(
      notifier: state,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MyMenu',
        theme: AppTheme.data,
        home: const HomeShell(),
      ),
    );
  }
}
