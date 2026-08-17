import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/core/database/app_database.dart';
import 'package:mymenu/core/network/service_identity_client.dart';

void main() {
  test('auth changes and refresh leave local menu rows and media untouched',
      () async {
    final AppDatabase database =
        AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database.into(database.dishes).insert(
          DishesCompanion.insert(
            id: 'local-dish',
            title: 'Local noodles',
            description: '',
            heroImageUrl: '/local/menu/noodles.jpg',
            category: 'Captured',
            prepMinutes: 0,
            difficulty: 'Draft',
            madeCount: 1,
            lastMadeLabel: 'Today',
            ingredientsJson: '[]',
            recipeStepsJson: '[]',
            notesJson: '[]',
          ),
        );
    final Directory temp =
        await Directory.systemTemp.createTemp('mymenu_identity_boundary_');
    addTearDown(() => temp.delete(recursive: true));
    final File media = await File('${temp.path}/noodles.jpg').writeAsBytes(
      <int>[1, 2, 3, 4],
    );
    final _IdentityClient client = _IdentityClient();
    final ServiceIdentityController controller = ServiceIdentityController(
      client,
    );
    addTearDown(controller.dispose);
    await controller.ready;

    client.emit(
      const ServiceIdentity.account(
        userId: 'account-id',
        email: 'cook@example.com',
      ),
    );
    await Future<void>.delayed(Duration.zero);
    await controller.refreshIdentity();
    await controller.signOutToGuest();

    expect(controller.identity.isGuest, isTrue);
    expect(await database.select(database.dishes).get(), hasLength(1));
    expect(media.existsSync(), isTrue);
    expect(await media.readAsBytes(), <int>[1, 2, 3, 4]);
  });
}

class _IdentityClient implements ServiceIdentityClient {
  final StreamController<ServiceIdentity> _changes =
      StreamController<ServiceIdentity>.broadcast();
  ServiceIdentity _identity = const ServiceIdentity.guest(userId: 'guest-id');

  void emit(ServiceIdentity identity) {
    _identity = identity;
    _changes.add(identity);
  }

  @override
  Stream<ServiceIdentity> get changes => _changes.stream;

  @override
  ServiceIdentity get current => _identity;

  @override
  Future<void> deleteAccount() async {
    emit(const ServiceIdentity.guest(userId: 'replacement-guest'));
  }

  @override
  Future<void> ensureGuest() async {}

  @override
  Future<void> refreshIdentity() async {
    emit(_identity);
  }

  @override
  Future<void> signOutToGuest() async {
    emit(const ServiceIdentity.guest(userId: 'replacement-guest'));
  }
}
