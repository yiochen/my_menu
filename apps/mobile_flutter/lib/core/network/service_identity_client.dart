import 'dart:async';

import 'package:mymenu/domain/account/service_identity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
