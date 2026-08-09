import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/core/debug/debug_controls.dart';
import 'package:mymenu/core/debug/shared_preferences_debug_controls.dart';
import 'package:mymenu/core/network/my_menu_api_client.dart';
import 'package:mymenu/core/network/network_gated_my_menu_api_client.dart';
import 'package:mymenu/core/network/network_status_monitor.dart';
import 'package:mymenu/shared/debug_feedback/debug_feedback_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('network toggle emits off and on events and gates requests', () async {
    final DebugControlsController controls = DebugControlsController();
    addTearDown(controls.dispose);
    final NetworkGatedMyMenuApiClient client = NetworkGatedMyMenuApiClient(
      FakeMyMenuApiClient(),
      controls.requireNetwork,
    );
    final Future<List<void>> events = controls.changes.take(2).toList();

    controls.setNetworkEnabled(enabled: false);
    await expectLater(
      client.upsertCaptureBatch(
        batchId: 'batch',
        itemCount: 1,
        createdAt: DateTime.utc(2026, 7, 26),
      ),
      throwsA(isA<SocketException>()),
    );

    controls.setNetworkEnabled(enabled: true);
    await client.upsertCaptureBatch(
      batchId: 'batch',
      itemCount: 1,
      createdAt: DateTime.utc(2026, 7, 26),
    );

    expect(await events, <void>[null, null]);
  });

  test('merged monitor forwards simulated network changes', () async {
    final DebugControlsController controls = DebugControlsController();
    addTearDown(controls.dispose);
    final MergedNetworkStatusMonitor monitor = MergedNetworkStatusMonitor(
      <NetworkStatusMonitor>[
        const InertNetworkStatusMonitor(),
        controls,
      ],
    );
    final Completer<void> changed = Completer<void>();
    final StreamSubscription<void> subscription = monitor.changes.listen((_) {
      changed.complete();
    });
    addTearDown(subscription.cancel);

    controls.setNetworkEnabled(enabled: false);

    await changed.future;
  });

  test('network setting survives controller recreation', () async {
    SharedPreferences.setMockInitialValues(
      <String, Object>{'debug_controls.network_enabled': false},
    );
    final SharedPreferencesDebugControls storedControls =
        await SharedPreferencesDebugControls.load();
    final DebugControlsController firstController = DebugControlsController(
      initialSettings: storedControls.settings,
      persistence: storedControls,
    );

    expect(firstController.networkEnabled, isFalse);
    firstController.setNetworkEnabled(enabled: true);
    await Future<void>.delayed(Duration.zero);
    firstController.dispose();

    final SharedPreferencesDebugControls reloadedControls =
        await SharedPreferencesDebugControls.load();
    final DebugControlsController reloadedController = DebugControlsController(
      initialSettings: reloadedControls.settings,
      persistence: reloadedControls,
    );
    addTearDown(reloadedController.dispose);

    expect(reloadedController.networkEnabled, isTrue);
  });

  test('feedback survives controller recreation', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferencesDebugControls storedControls =
        await SharedPreferencesDebugControls.load();
    await storedControls.setFeedbackEntries(
      <DebugFeedbackEntry>[
        DebugFeedbackEntry(
          target: const DebugFeedbackTargetSnapshot(
            id: 'screen.action',
            label: 'Screen action',
            widgetType: 'TextButton',
            widgetPath: <String>['Screen', 'TextButton'],
          ),
          comment: 'Use a quieter style.',
          createdAt: DateTime.utc(2026, 8, 8),
        ),
      ],
    );

    final SharedPreferencesDebugControls reloadedControls =
        await SharedPreferencesDebugControls.load();
    final DebugControlsController controller = DebugControlsController(
      initialSettings: reloadedControls.settings,
      persistence: reloadedControls,
    );
    addTearDown(controller.dispose);

    expect(controller.feedback.entries, hasLength(1));
    expect(controller.feedback.entries.single.target.id, 'screen.action');
    expect(controller.feedback.entries.single.comment, 'Use a quieter style.');
  });
}
