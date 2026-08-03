import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/shared/widgets/photos_entry_button.dart';

void main() {
  testWidgets('photo button shows a stationary unorganized count',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PhotosEntryButton(
            unorganizedCount: 3,
            organizing: false,
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('3'), findsOneWidget);
    final Finder badge = find.byKey(
      const ValueKey<String>('menu_photos_badge'),
    );
    expect(tester.getSize(badge), const Size.square(18));
    final DecoratedBox badgeDecoration = tester.widget<DecoratedBox>(
      find.descendant(of: badge, matching: find.byType(DecoratedBox)),
    );
    expect(
      (badgeDecoration.decoration as BoxDecoration).shape,
      BoxShape.circle,
    );
    expect(
      tester
          .getSemantics(
            find.byKey(const ValueKey<String>('menu_photos_button')),
          )
          .label,
      contains('3 unorganized'),
    );
  });

  testWidgets('photo button announces organizing without a job count',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PhotosEntryButton(
            unorganizedCount: 3,
            organizing: true,
            onPressed: () {},
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('3'), findsNothing);
    expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
    expect(
      tester
          .getSemantics(
            find.byKey(const ValueKey<String>('menu_photos_button')),
          )
          .label,
      contains('organizing in progress'),
    );
  });
}
