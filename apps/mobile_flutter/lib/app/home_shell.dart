import 'package:flutter/material.dart';

import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
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

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: state,
        builder: (BuildContext context, _) {
          return SafeArea(
            child: IndexedStack(
              index: _selectedIndex,
              children: <Widget>[
                PlanScreen(
                  onOpenReview: () => showReviewSheet(context, state),
                ),
                MenuScreen(
                  query: _query,
                  onQueryChanged: (String value) {
                    setState(() => _query = value);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('capture_fab'),
        onPressed: () => showCaptureSheet(context, state),
        icon: const Icon(Icons.add),
        label: const Text('Capture'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Plan',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}
