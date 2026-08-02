import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/app/app.dart';
import 'package:mymenu/app/home_shell.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/shared/theme/app_theme.dart';

void main() {
  testWidgets('menu photo icon opens the gallery and back restores dishes',
      (WidgetTester tester) async {
    final MyMenuState state = MyMenuState.forTesting();
    addTearDown(state.dispose);
    await tester.pumpWidget(
      MyMenuScope(
        notifier: state,
        child: MaterialApp(
          theme: AppTheme.data,
          home: const HomeShell(),
        ),
      ),
    );

    await tester.tap(find.text('Menu'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('menu_photos_button')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('menu_photos_button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Photos'), findsOneWidget);
    expect(find.text('Your photos will live here'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('photos_back')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('menu_search_field')),
      findsOneWidget,
    );
  });
}
