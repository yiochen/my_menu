import 'package:flutter/material.dart';
import 'package:mymenu/features/photos/photos_screen.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/photos_entry_button.dart';

Route<void> photosRoute({
  required PhotoFilter initialFilter,
  required bool reduceMotion,
}) {
  final Duration duration =
      reduceMotion ? Duration.zero : const Duration(milliseconds: 440);
  return PageRouteBuilder<void>(
    settings: const RouteSettings(name: 'photos'),
    opaque: false,
    transitionDuration: duration,
    reverseTransitionDuration:
        reduceMotion ? Duration.zero : const Duration(milliseconds: 360),
    pageBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
    ) {
      return Stack(
        children: <Widget>[
          Positioned.fill(
            child: Hero(
              tag: photosEntryHeroTag,
              createRectTween: (Rect? begin, Rect? end) =>
                  MaterialRectArcTween(begin: begin, end: end),
              flightShuttleBuilder: photosFlightShuttleBuilder,
              child: const ColoredBox(color: MyMenuColors.cream),
            ),
          ),
          FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: const Interval(0.68, 1, curve: Curves.easeOutCubic),
            ),
            child: ScaffoldMessenger(
              child: PhotosScreen(
                initialFilter: initialFilter,
                onBack: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
        ],
      );
    },
  );
}
