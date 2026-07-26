import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mymenu/core/database/app_database.dart';
import 'package:mymenu/core/network/my_menu_api_client.dart';
import 'package:mymenu/core/network/network_status_monitor.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/domain/sync/repositories.dart';

final AppDatabase _sharedAppDatabase = AppDatabase();

final appDatabaseProvider = Provider<AppDatabase>((Ref ref) {
  return _sharedAppDatabase;
});

final networkStatusMonitorProvider = Provider<NetworkStatusMonitor>((Ref ref) {
  return ConnectivityNetworkStatusMonitor();
});

final myMenuApiClientProvider = Provider<MyMenuApiClient>((Ref ref) {
  if (SupabaseApiConfig.shouldUseSupabase) {
    return SupabaseMyMenuApiClient();
  }
  return FakeMyMenuApiClient();
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
