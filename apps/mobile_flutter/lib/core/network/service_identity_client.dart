import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

class SupabaseServiceIdentityClient implements ServiceIdentityClient {
  SupabaseServiceIdentityClient({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  ServiceIdentity get current => _fromUser(_client.auth.currentUser);

  @override
  Stream<ServiceIdentity> get changes => _client.auth.onAuthStateChange.map(
        (AuthState state) => _fromUser(state.session?.user),
      );

  @override
  Future<void> ensureGuest() async {
    if (_client.auth.currentSession == null) {
      await _client.auth.signInAnonymously();
    }
  }

  @override
  Future<void> refreshIdentity() async {
    if (_client.auth.currentSession != null) {
      await _client.auth.refreshSession();
    }
  }

  @override
  Future<void> signOutToGuest() async {
    await _client.auth.signOut();
    await _client.auth.signInAnonymously();
  }

  @override
  Future<void> deleteAccount() async {
    final FunctionResponse response = await _client.functions.invoke(
      'service-account',
      body: <String, Object?>{'action': 'delete'},
    );
    if (response.status != 200) {
      throw StateError('Account deletion failed.');
    }
    await _client.auth.signOut();
    await _client.auth.signInAnonymously();
  }

  ServiceIdentity _fromUser(User? user) {
    if (user == null || user.isAnonymous) {
      return ServiceIdentity.guest(userId: user?.id ?? 'pending-guest');
    }
    return ServiceIdentity.account(userId: user.id, email: user.email);
  }
}

class LocalServiceIdentityClient implements ServiceIdentityClient {
  LocalServiceIdentityClient()
      : _current = const ServiceIdentity.guest(userId: 'local-guest');

  final StreamController<ServiceIdentity> _changes =
      StreamController<ServiceIdentity>.broadcast();
  final ServiceIdentity _current;

  @override
  Stream<ServiceIdentity> get changes => _changes.stream;

  @override
  ServiceIdentity get current => _current;

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<void> ensureGuest() async {}

  @override
  Future<void> refreshIdentity() async {}

  @override
  Future<void> signOutToGuest() async {}
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
