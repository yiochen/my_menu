import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mymenu/core/database/app_database.dart';
import 'package:mymenu/core/debug/debug_controls.dart';
import 'package:mymenu/core/network/network_gated_processing_api_client.dart';
import 'package:mymenu/core/network/network_status_monitor.dart';
import 'package:mymenu/core/network/processing_api_client.dart';
import 'package:mymenu/core/network/service_identity_client.dart';
import 'package:mymenu/domain/menu/app_repositories.dart';
import 'package:mymenu/domain/menu/my_menu_state.dart';
import 'package:mymenu/features/capture/capture_media_service.dart';

final AppDatabase _sharedAppDatabase = AppDatabase();

final debugControlsBootstrapProvider = Provider<DebugControlsBootstrap?>(
  (Ref ref) => null,
);

final appDatabaseProvider = Provider<AppDatabase>((Ref ref) {
  return _sharedAppDatabase;
});

final seedSampleDataProvider = Provider<bool>((Ref ref) => false);

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

final processingApiClientProvider = Provider<ProcessingApiClient>((Ref ref) {
  final ProcessingApiClient client;
  if (ProcessingApiConfig.shouldUseSupabase) {
    client = SupabaseProcessingApiClient();
  } else {
    client = FakeProcessingApiClient();
  }
  if (!kDebugMode) {
    return client;
  }
  return NetworkGatedProcessingApiClient(
    client,
    ref.read(debugControlsProvider).requireNetwork,
  );
});

final serviceIdentityClientProvider = Provider<ServiceIdentityClient>(
  (Ref ref) => ProcessingApiConfig.shouldUseSupabase
      ? SupabaseServiceIdentityClient()
      : LocalServiceIdentityClient(),
);

final serviceIdentityControllerProvider =
    ChangeNotifierProvider<ServiceIdentityController>((Ref ref) {
  return ServiceIdentityController(ref.watch(serviceIdentityClientProvider));
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
    processingApiClient: ref.watch(processingApiClientProvider),
    seedSampleDataOnPrepare: ref.watch(seedSampleDataProvider),
  );
});

final myMenuStateProvider = ChangeNotifierProvider<MyMenuState>((Ref ref) {
  return MyMenuState(
    repositories: ref.watch(appRepositoriesProvider),
    networkStatusMonitor: ref.watch(networkStatusMonitorProvider),
  );
});
