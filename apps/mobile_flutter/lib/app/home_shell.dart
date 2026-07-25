import 'dart:math' as math;

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
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final ImagePickerCaptureMediaService _captureMediaService =
      ImagePickerCaptureMediaService();
  int _selectedIndex = 0;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: MyMenuColors.cream,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
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
                    ),
                },
                _FloatingBottomShell(
                  selectedIndex: _selectedIndex,
                  onSelect: (int value) {
                    setState(() => _selectedIndex = value);
                  },
                  onCapture: () => showCaptureSheet(
                    context,
                    state,
                    _captureMediaService,
                  ),
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
    required this.onSelect,
    required this.onCapture,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    final double safeBottom = MediaQuery.paddingOf(context).bottom;
    return Positioned(
      left: MyMenuUnits.bottomBarInset,
      right: MyMenuUnits.bottomBarInset,
      bottom: math.max(MyMenuUnits.bottomBarBottom, safeBottom + 4),
      child: SizedBox(
        height: MyMenuUnits.bottomBarHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFAFFFFFF),
                borderRadius: BorderRadius.circular(27),
                border: Border.all(color: MyMenuColors.line),
                boxShadow: myMenuFloatingShadow,
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
                      onTap: () => onSelect(1),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: -19,
              child: Center(
                child: Container(
                  width: 74,
                  height: 74,
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: MyMenuColors.cream,
                    shape: BoxShape.circle,
                  ),
                  child: FloatingActionButton(
                    key: const ValueKey<String>('capture_fab'),
                    heroTag: 'global_capture',
                    onPressed: onCapture,
                    elevation: 0,
                    backgroundColor: MyMenuColors.orangeAction,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.add, size: 28),
                  ),
                ),
              ),
            ),
          ],
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
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? MyMenuColors.orangeDark : MyMenuColors.muted;
    return InkWell(
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
    );
  }
}
