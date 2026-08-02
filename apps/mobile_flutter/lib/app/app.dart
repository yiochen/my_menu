import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mymenu/app/app_providers.dart';
import 'package:mymenu/app/home_shell.dart';
import 'package:mymenu/core/database/app_database.dart';
import 'package:mymenu/core/debug/debug_controls.dart';
import 'package:mymenu/core/network/network_status_monitor.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/debug/debug_controls_overlay.dart';
import 'package:mymenu/features/processing/processing_consent_prompt.dart';
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
    this.debugControlsBootstrap,
    this.networkStatusMonitor,
    this.showDebugPanel,
    this.seedSampleData = false,
    super.key,
  });

  final AppDatabase? database;
  final DebugControlsBootstrap? debugControlsBootstrap;
  final NetworkStatusMonitor? networkStatusMonitor;
  final bool? showDebugPanel;
  @visibleForTesting
  final bool seedSampleData;

  @override
  Widget build(BuildContext context) {
    final AppDatabase? overrideDatabase = database;
    final bool debugPanelEnabled = kDebugMode && (showDebugPanel ?? true);
    return ProviderScope(
      overrides: [
        if (overrideDatabase != null)
          appDatabaseProvider.overrideWithValue(overrideDatabase),
        if (debugControlsBootstrap != null)
          debugControlsBootstrapProvider.overrideWithValue(
            debugControlsBootstrap,
          ),
        if (networkStatusMonitor != null)
          physicalNetworkStatusMonitorProvider.overrideWithValue(
            networkStatusMonitor!,
          ),
        seedSampleDataProvider.overrideWithValue(seedSampleData),
      ],
      child: _MyMenuAppView(debugPanelEnabled: debugPanelEnabled),
    );
  }
}

class _MyMenuAppView extends ConsumerWidget {
  const _MyMenuAppView({required this.debugPanelEnabled});

  final bool debugPanelEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MyMenuState state = ref.watch(myMenuStateProvider);
    final debugControls = ref.read(debugControlsProvider);
    final captureMediaService = ref.watch(captureMediaServiceProvider);
    return MyMenuScope(
      notifier: state,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MyMenu',
        theme: AppTheme.data,
        home: ProcessingConsentPromptHost(
          child: HomeShell(captureMediaService: captureMediaService),
        ),
        builder: (BuildContext context, Widget? child) {
          return DebugControlsOverlay(
            controller: debugControls,
            enabled: debugPanelEnabled,
            onResetProcessingConsent: state.resetProcessingConsent,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
