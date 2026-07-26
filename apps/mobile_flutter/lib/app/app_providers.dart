import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mymenu/core/database/app_database.dart';
import 'package:mymenu/core/debug/debug_controls.dart';
import 'package:mymenu/core/network/my_menu_api_client.dart';
import 'package:mymenu/core/network/network_gated_my_menu_api_client.dart';
import 'package:mymenu/core/network/network_status_monitor.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/domain/sync/repositories.dart';
import 'package:mymenu/features/capture/capture_media_service.dart';

final AppDatabase _sharedAppDatabase = AppDatabase();

final debugControlsBootstrapProvider = Provider<DebugControlsBootstrap?>(
  (Ref ref) => null,
);

final appDatabaseProvider = Provider<AppDatabase>((Ref ref) {
  return _sharedAppDatabase;
});

final debugControlsProvider =
    ChangeNotifierProvider<DebugControlsController>((Ref ref) {
  final DebugControlsBootstrap? bootstrap = ref.watch(
    debugControlsBootstrapProvider,
  );
  return DebugControlsController(
    initialSettings: bootstrap?.settings ?? const DebugControlsSettings(),
    persistence: bootstrap?.persistence,
  );
});

final physicalNetworkStatusMonitorProvider =
    Provider<NetworkStatusMonitor>((Ref ref) {
  return ConnectivityNetworkStatusMonitor();
});

final networkStatusMonitorProvider = Provider<NetworkStatusMonitor>((Ref ref) {
  final NetworkStatusMonitor physical =
      ref.watch(physicalNetworkStatusMonitorProvider);
  if (!kDebugMode) {
    return physical;
  }
  return MergedNetworkStatusMonitor(
    <NetworkStatusMonitor>[physical, ref.read(debugControlsProvider)],
  );
});

final myMenuApiClientProvider = Provider<MyMenuApiClient>((Ref ref) {
  final MyMenuApiClient client;
  if (SupabaseApiConfig.shouldUseSupabase) {
    client = SupabaseMyMenuApiClient();
  } else {
    client = FakeMyMenuApiClient();
  }
  if (!kDebugMode) {
    return client;
  }
  return NetworkGatedMyMenuApiClient(
    client,
    ref.read(debugControlsProvider).requireNetwork,
  );
});

final captureMediaServiceProvider = Provider<CaptureMediaService>((Ref ref) {
  final CaptureMediaService service = ImagePickerCaptureMediaService();
  if (!kDebugMode) {
    return service;
  }
  return DebugGatedCaptureMediaService(
    service,
    ref.read(debugControlsProvider),
  );
});

final appRepositoriesProvider = Provider<AppRepositories>((Ref ref) {
  return AppRepositories(
    database: ref.watch(appDatabaseProvider),
    apiClient: ref.watch(myMenuApiClientProvider),
  );
});

final myMenuStateProvider = ChangeNotifierProvider<MyMenuState>((Ref ref) {
  return MyMenuState(
    repositories: ref.watch(appRepositoriesProvider),
    networkStatusMonitor: ref.watch(networkStatusMonitorProvider),
  );
});
