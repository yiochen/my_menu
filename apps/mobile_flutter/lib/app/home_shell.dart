import 'package:flutter/material.dart';

import 'package:mymenu/app/app.dart';
import 'package:mymenu/app/app_shell_theme.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/capture/capture_feed_sheet.dart';
import 'package:mymenu/features/capture/capture_media_service.dart';
import 'package:mymenu/features/capture/capture_sheet.dart';
import 'package:mymenu/features/menu/menu_screen.dart';
import 'package:mymenu/features/plan/plan_screen.dart';
import 'package:mymenu/features/review/review_sheet.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;
  String _query = '';
  bool _isPlanDragging = false;
  final ImagePickerCaptureMediaService _captureMediaService =
      ImagePickerCaptureMediaService();

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: state,
        builder: (BuildContext context, _) {
          return Stack(
            children: <Widget>[
              SafeArea(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: <Widget>[
                    PlanScreen(
                      onOpenReview: () => showReviewSheet(context, state),
                      onOpenCaptureFeed: () =>
                          showCaptureFeedSheet(context, state),
                      onDragStateChanged: (bool isDragging) {
                        setState(() => _isPlanDragging = isDragging);
                      },
                    ),
                    MenuScreen(
                      query: _query,
                      onQueryChanged: (String value) {
                        setState(() => _query = value);
                      },
                    ),
                  ],
                ),
              ),
              if (!_isPlanDragging)
                _FloatingChrome(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() => _selectedIndex = index);
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
    );
  }
}

class _FloatingChrome extends StatelessWidget {
  const _FloatingChrome({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onCapture,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    final AppShellThemeTokens tokens = context.appShellTheme;

    return Positioned(
      left: 0,
      right: 0,
      bottom: tokens.bottomChromeBottomOffset,
      child: IgnorePointer(
        ignoring: false,
        child: SizedBox(
          height: tokens.bottomChromeHeight,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: tokens.bottomBarWidth,
                  height: tokens.bottomBarHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFCF7),
                    borderRadius: BorderRadius.circular(tokens.bottomBarRadius),
                    border: Border.all(color: const Color(0xFFE8DFD2)),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: _NavItem(
                          isSelected: selectedIndex == 0,
                          icon: Icons.calendar_month,
                          label: 'Plan',
                          onTap: () => onDestinationSelected(0),
                        ),
                      ),
                      Expanded(
                        child: _NavItem(
                          isSelected: selectedIndex == 1,
                          icon: Icons.person_2_outlined,
                          label: 'Menu',
                          onTap: () => onDestinationSelected(1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: tokens.fabRightOffset,
                bottom: tokens.fabBottomOffset,
                child: SizedBox(
                  width: tokens.fabSize,
                  height: tokens.fabHeight,
                  child: FloatingActionButton(
                    key: const ValueKey('capture_fab'),
                    onPressed: onCapture,
                    backgroundColor: const Color(0xFFD79A00),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: const CircleBorder(),
                    child: Icon(Icons.add, size: tokens.fabIconSize),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.isSelected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool isSelected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppShellThemeTokens tokens = context.appShellTheme;

    return Padding(
      padding: EdgeInsets.all(tokens.bottomNavItemPadding),
      child: Material(
        color: isSelected ? const Color(0xFFF3EFE5) : Colors.transparent,
        borderRadius: BorderRadius.circular(tokens.bottomNavItemRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(tokens.bottomNavItemRadius),
          onTap: onTap,
          child: SizedBox(
            height: tokens.bottomNavSelectedHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  icon,
                  size: tokens.bottomNavIconSize,
                  color: isSelected
                      ? const Color(0xFF174B2A)
                      : const Color(0xFF727272),
                ),
                SizedBox(height: tokens.bottomNavLabelSpacing),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontSize: tokens.bottomNavLabelFontSize,
                        color: isSelected
                            ? const Color(0xFF174B2A)
                            : const Color(0xFF727272),
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
