import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/app/app_providers.dart';
import 'package:mymenu/core/network/service_identity_client.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/dishes/seeded_dishes.dart';
import 'package:mymenu/domain/menu/my_menu_state.dart';
import 'package:mymenu/features/processing/ai_settings_sheet.dart';

void main() {
  testWidgets('account deletion keeps menu and local erase keeps identity',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final _IdentityClient client = _IdentityClient();
    final ServiceIdentityController controller = ServiceIdentityController(
      client,
    );
    final MyMenuState state = MyMenuState.forTesting(
      dishes: <Dish>[seededDishes.first],
    );
    addTearDown(state.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          serviceIdentityControllerProvider.overrideWith(
            (Ref ref) => controller,
          ),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (BuildContext context) => Scaffold(
              body: FilledButton(
                onPressed: () => showAiSettingsSheet(context, state),
                child: const Text('Open settings'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const ValueKey<String>('delete_service_account')),
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('delete_service_account')),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Your local menu and photos'), findsOneWidget);
    await tester.tap(find.text('Delete account').last);
    await tester.pumpAndSettle();

    expect(state.dishes, hasLength(1));
    expect(controller.identity.isGuest, isTrue);

    await tester.ensureVisible(
      find.byKey(const ValueKey<String>('erase_local_menu')),
    );
    await tester.tap(find.byKey(const ValueKey<String>('erase_local_menu')));
    await tester.pumpAndSettle();
    expect(find.textContaining('service identity, account'), findsOneWidget);
    await tester.tap(find.text('Erase local menu').last);
    await tester.pumpAndSettle();

    expect(state.dishes, isEmpty);
    expect(controller.identity.isGuest, isTrue);
  });
}

class _IdentityClient implements ServiceIdentityClient {
  final StreamController<ServiceIdentity> _changes =
      StreamController<ServiceIdentity>.broadcast();
  ServiceIdentity _current = const ServiceIdentity.account(
    userId: 'signed-account',
    email: 'cook@example.com',
  );

  @override
  Stream<ServiceIdentity> get changes => _changes.stream;

  @override
  ServiceIdentity get current => _current;

  @override
  Future<void> deleteAccount() async {
    _current = const ServiceIdentity.guest(userId: 'new-guest');
    _changes.add(_current);
  }

  @override
  Future<void> ensureGuest() async {}

  @override
  Future<void> refreshIdentity() async {}

  @override
  Future<void> signOutToGuest() => deleteAccount();
}
