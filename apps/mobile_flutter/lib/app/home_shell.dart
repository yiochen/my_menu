import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/capture/capture_media_service.dart';
import 'package:mymenu/features/capture/capture_sheet.dart';
import 'package:mymenu/features/menu/menu_screen.dart';
import 'package:mymenu/features/plan/plan_screen.dart';
import 'package:mymenu/features/review/review_sheet.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({this.captureMediaService, super.key});

  final CaptureMediaService? captureMediaService;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late final CaptureMediaService _captureMediaService =
      widget.captureMediaService ?? ImagePickerCaptureMediaService();
  int _selectedIndex = 0;
  String _query = '';
  bool _menuSelectionActive = false;

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        extendBody: true,
        body: AnimatedBuilder(
          animation: state,
          builder: (BuildContext context, _) {
            return Stack(
              children: <Widget>[
                switch (_selectedIndex) {
                  0 => PlanScreen(
                      key: const ValueKey<String>('plan_destination'),
                      onOpenReview: () => showReviewSheet(context, state),
                    ),
                  _ => MenuScreen(
                      key: const ValueKey<String>('menu_destination'),
                      query: _query,
                      onQueryChanged: (String value) {
                        setState(() => _query = value);
                      },
                      onSelectionModeChanged: (bool active) {
                        if (_menuSelectionActive != active) {
                          setState(() => _menuSelectionActive = active);
                        }
                      },
                    ),
                },
                if (!_menuSelectionActive)
                  _FloatingBottomShell(
                    selectedIndex: _selectedIndex,
                    reviewCount: state.reviewItems.length,
                    onSelect: (int value) {
                      setState(() {
                        _selectedIndex = value;
                        if (value != 1) {
                          _menuSelectionActive = false;
                        }
                      });
                    },
                    onCapture: () => showCaptureSheet(
                      context,
                      state,
                      _captureMediaService,
                    ),
                    onOpenReview: () => showReviewSheet(context, state),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FloatingBottomShell extends StatelessWidget {
  const _FloatingBottomShell({
    required this.selectedIndex,
    required this.reviewCount,
    required this.onSelect,
    required this.onCapture,
    required this.onOpenReview,
  });

  final int selectedIndex;
  final int reviewCount;
  final ValueChanged<int> onSelect;
  final VoidCallback onCapture;
  final VoidCallback onOpenReview;

  @override
  Widget build(BuildContext context) {
    final double safeBottom = MediaQuery.paddingOf(context).bottom;
    return Positioned(
      left: MyMenuUnits.bottomBarInset,
      right: MyMenuUnits.bottomBarInset,
      bottom: math.max(MyMenuUnits.bottomBarBottom, safeBottom + 4),
      child: RepaintBoundary(
        key: const ValueKey<String>('bottom_shell_golden'),
        child: SizedBox(
          height: MyMenuUnits.bottomBarHeight + 35,
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: MyMenuUnits.bottomBarHeight,
                child: _BottomBar(
                  selectedIndex: selectedIndex,
                  reviewCount: reviewCount,
                  onSelect: onSelect,
                  onOpenReview: onOpenReview,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 8,
                child: Center(
                  child: _CaptureButton(onPressed: onCapture),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.selectedIndex,
    required this.reviewCount,
    required this.onSelect,
    required this.onOpenReview,
  });

  final int selectedIndex;
  final int reviewCount;
  final ValueChanged<int> onSelect;
  final VoidCallback onOpenReview;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(27);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: myMenuFloatingShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xF5FFFFFF),
              borderRadius: borderRadius,
              border: Border.all(color: MyMenuColors.line),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _BottomDestination(
                    label: 'Plan',
                    icon: Icons.calendar_month_outlined,
                    selected: selectedIndex == 0,
                    onTap: () => onSelect(0),
                  ),
                ),
                const SizedBox(width: 78),
                Expanded(
                  child: _BottomDestination(
                    label: 'Menu',
                    icon: Icons.menu_book_outlined,
                    selected: selectedIndex == 1,
                    badgeCount: reviewCount,
                    onBadgeTap: onOpenReview,
                    onTap: () => onSelect(1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  const _CaptureButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Capture',
      child: Container(
        key: const ValueKey<String>('capture_glow'),
        width: 94,
        height: 94,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[
              Color(0x70FF710A),
              Color(0x36FF9A3D),
              Color(0x00FFB166),
            ],
            stops: <double>[0, 0.58, 1],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            width: MyMenuUnits.captureButtonSize,
            height: MyMenuUnits.captureButtonSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              border: Border.fromBorderSide(
                BorderSide(
                  color: MyMenuColors.cream,
                  width: 6,
                ),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color(0xFFFF8A24),
                  MyMenuColors.orangeAction,
                ],
                stops: <double>[0, 0.78],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Color(0x33FFFFFF),
                  blurRadius: 2,
                  spreadRadius: 1,
                  offset: Offset(-1, -1),
                ),
              ],
            ),
            child: InkWell(
              key: const ValueKey<String>('capture_fab'),
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: const Icon(
                Icons.add,
                size: 28,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomDestination extends StatelessWidget {
  const _BottomDestination({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
    this.onBadgeTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;
  final VoidCallback? onBadgeTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? MyMenuColors.orangeDark : MyMenuColors.muted;
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned.fill(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(27),
            child: Semantics(
              selected: selected,
              button: true,
              label: label,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(icon, size: 22, color: color),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            top: 2,
            left: 0,
            right: 0,
            child: Center(
              child: Transform.translate(
                offset: const Offset(13, 0),
                child: Semantics(
                  button: true,
                  label: '$badgeCount captures need review',
                  child: GestureDetector(
                    onTap: onBadgeTap,
                    child: Container(
                      key: const ValueKey<String>('menu_review_badge'),
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: MyMenuColors.orangeAction,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
