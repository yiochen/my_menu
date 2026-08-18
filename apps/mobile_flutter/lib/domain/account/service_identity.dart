import 'dart:async';

import 'package:flutter/foundation.dart';

class ServiceIdentity {
  const ServiceIdentity.guest({required this.userId})
      : email = null,
        isGuest = true;

  const ServiceIdentity.account({
    required this.userId,
    required this.email,
  }) : isGuest = false;

  final String userId;
  final String? email;
  final bool isGuest;

  bool get isAccount => !isGuest;
}

abstract class ServiceIdentityClient {
  ServiceIdentity get current;

  Stream<ServiceIdentity> get changes;

  Future<void> ensureGuest();

  Future<void> refreshIdentity();

  Future<void> signOutToGuest();

  Future<void> deleteAccount();
}

class ServiceIdentityController extends ChangeNotifier {
  ServiceIdentityController(this._client) : _identity = _client.current {
    _subscription = _client.changes.listen(_setIdentity);
    _initialization = _initialize();
  }

  final ServiceIdentityClient _client;
  late final StreamSubscription<ServiceIdentity> _subscription;
  late final Future<void> _initialization;
  ServiceIdentity _identity;
  bool _busy = false;
  Object? _lastError;

  ServiceIdentity get identity => _identity;
  bool get busy => _busy;
  Object? get lastError => _lastError;
  Future<void> get ready => _initialization;

  Future<void> _initialize() async {
    await _client.ensureGuest();
    _setIdentity(_client.current);
  }

  Future<void> refreshIdentity() => _run(_client.refreshIdentity);

  Future<void> signOutToGuest() => _run(_client.signOutToGuest);

  Future<void> deleteAccount() => _run(_client.deleteAccount);

  Future<void> _run(Future<void> Function() action) async {
    _busy = true;
    _lastError = null;
    notifyListeners();
    try {
      await action();
      _setIdentity(_client.current);
    } on Object catch (error) {
      _lastError = error;
      rethrow;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  void _setIdentity(ServiceIdentity identity) {
    _identity = identity;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
