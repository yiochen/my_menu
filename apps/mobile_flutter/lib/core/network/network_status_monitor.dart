import 'dart:async';
import 'dart:developer' as developer;

import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkStatusMonitor {
  Stream<void> get changes;
}

class InertNetworkStatusMonitor implements NetworkStatusMonitor {
  const InertNetworkStatusMonitor();

  @override
  Stream<void> get changes => const Stream<void>.empty();
}

class ConnectivityNetworkStatusMonitor implements NetworkStatusMonitor {
  ConnectivityNetworkStatusMonitor({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Stream<void> get changes {
    return _connectivity.onConnectivityChanged
        .handleError((Object error, StackTrace stackTrace) {
      developer.log(
        'Network status monitoring is unavailable.',
        name: 'mymenu.network',
        error: error,
        stackTrace: stackTrace,
      );
    }).map<void>((_) {});
  }
}

class MergedNetworkStatusMonitor implements NetworkStatusMonitor {
  const MergedNetworkStatusMonitor(this._monitors);

  final List<NetworkStatusMonitor> _monitors;

  @override
  Stream<void> get changes {
    return Stream<void>.multi((MultiStreamController<void> controller) {
      final List<StreamSubscription<void>> subscriptions = _monitors
          .map(
            (NetworkStatusMonitor monitor) => monitor.changes.listen(
              (_) => controller.add(null),
              onError: controller.addError,
            ),
          )
          .toList(growable: false);
      controller.onCancel = () async {
        await Future.wait<void>(
          subscriptions.map(
            (StreamSubscription<void> subscription) => subscription.cancel(),
          ),
        );
      };
    });
  }
}
