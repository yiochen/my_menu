import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/services.dart';

import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/menu/my_menu_state.dart';
import 'package:mymenu/features/dish_detail/dish_detail_screen.dart';
import 'package:mymenu/features/menu/menu_category_filter_sheet.dart';
import 'package:mymenu/features/menu/menu_delete_dialog.dart';
import 'package:mymenu/features/menu/menu_empty_states.dart';
import 'package:mymenu/features/menu/menu_exit_transition.dart';
import 'package:mymenu/features/menu/menu_grid_card.dart';
import 'package:mymenu/features/menu/menu_sticky_header.dart';
import 'package:mymenu/features/settings/settings_sheet.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

part 'menu_screen_sections.dart';
part 'menu_selection.dart';

enum MenuCollectionFilter { all, favorites, recent }

class MenuScreen extends StatefulWidget {
  const MenuScreen({
    required this.query,
    required this.onQueryChanged,
    required this.onOpenPhotos,
    this.onSelectionModeChanged,
    super.key,
  });

  final String query;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<bool>? onSelectionModeChanged;
  final VoidCallback onOpenPhotos;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  static const Duration _deleteSheetExitDuration = Duration(milliseconds: 270);
  static const Duration _cardExitDuration = Duration(milliseconds: 420);

  static Duration _dilated(Duration duration, {int bufferMilliseconds = 0}) {
    return Duration(
      microseconds: (duration.inMicroseconds * timeDilation).ceil() +
          bufferMilliseconds * Duration.microsecondsPerMillisecond,
    );
  }

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  MenuCollectionFilter _filter = MenuCollectionFilter.all;
  String? _category;
  bool _newestFirst = true;
  bool _hasScrolled = false;
  final Set<String> _selectedDishIds = <String>{};
  final Set<String> _removingDishIds = <String>{};
  final Map<String, Dish> _exitingDishes = <String, Dish>{};
  final Map<String, Timer> _dishExitFallbacks = <String, Timer>{};

  int get _selectedCount => _selectedDishIds.length;

  bool get _isSelecting => _selectedCount > 0;

  void _updateSelection(VoidCallback update) => setState(update);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void didUpdateWidget(covariant MenuScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _searchController.text) {
      _searchController.text = widget.query;
    }
  }

  @override
  void dispose() {
    for (final Timer timer in _dishExitFallbacks.values) {
      timer.cancel();
    }
    _searchController.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    final bool hasScrolled =
        _scrollController.hasClients && _scrollController.position.pixels > 0;
    if (hasScrolled != _hasScrolled) {
      setState(() => _hasScrolled = hasScrolled);
    }
  }

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);
    final List<Dish> dishes = _visibleDishes(state);
    final Set<String> availableDishIds =
        state.dishes.map((Dish dish) => dish.id).toSet();
    _selectedDishIds.removeWhere(
      (String dishId) => !availableDishIds.contains(dishId),
    );
    final bool hasMenuContent =
        state.dishes.isNotEmpty || _exitingDishes.isNotEmpty;
    final double horizontal = MyMenuUnits.pageHorizontal(context);
    return WarmPage(
      topPadding: 0,
      bottomPadding: 0,
      horizontalPadding: 0,
      child: Stack(
        children: <Widget>[
          _scrollView(
            context,
            state: state,
            dishes: dishes,
            hasMenuContent: hasMenuContent,
            horizontal: horizontal,
          ),
          if (_isSelecting)
            Positioned(
              left: horizontal,
              right: horizontal,
              bottom: MediaQuery.paddingOf(context).bottom + 12,
              child: MenuDeleteActionBar(
                selectedCount: _selectedCount,
                onDelete: () {
                  unawaited(_confirmDeleteSelected(state));
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _scrollView(
    BuildContext context, {
    required MyMenuState state,
    required List<Dish> dishes,
    required bool hasMenuContent,
    required double horizontal,
  }) {
    return Column(
      children: <Widget>[
        AnimatedContainer(
          key: const ValueKey<String>('menu_fixed_chrome'),
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.fromLTRB(
            horizontal,
            MediaQuery.paddingOf(context).top + 8,
            horizontal,
            10,
          ),
          decoration: BoxDecoration(
            color: MyMenuColors.cream,
            boxShadow: _hasScrolled
                ? const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x17302318),
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ]
                : const <BoxShadow>[],
          ),
          child: Column(
            children: <Widget>[
              MenuStickyHeader(
                controller: _searchController,
                query: widget.query,
                onQueryChanged: widget.onQueryChanged,
                onClearQuery: _clearSearch,
                selectedCount: _selectedCount,
                allSelected: dishes.isNotEmpty &&
                    dishes.every(
                      (Dish dish) => _selectedDishIds.contains(dish.id),
                    ),
                onCloseSelection: _clearSelection,
                onSelectAll: () => _toggleSelectAll(dishes),
                unorganizedPhotoCount: state.unorganizedPhotoCount,
                organizingPhotos: state.isOrganizingPhotos,
                onOpenPhotos: widget.onOpenPhotos,
                onOpenSettings: () => showSettingsSheet(context, state),
              ),
              if (state.dishes.isNotEmpty && !_isSelecting) ...<Widget>[
                const SizedBox(height: 7),
                _filters(),
              ],
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: state.resumeProcessing,
            child: CustomScrollView(
              key: const ValueKey<String>('menu_screen'),
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontal),
                  sliver: SliverMainAxisGroup(
                    slivers: <Widget>[
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      if (!hasMenuContent)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: MenuEmpty(),
                        )
                      else if (dishes.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: MenuSearchEmpty(onClear: _clearSearch),
                        )
                      else
                        ..._menuGridSlivers(
                          context,
                          state: state,
                          dishes: dishes,
                          totalDishCount: state.dishes.length,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _menuGridSlivers(
    BuildContext context, {
    required MyMenuState state,
    required List<Dish> dishes,
    required int totalDishCount,
  }) {
    return <Widget>[
      SliverToBoxAdapter(
        child: _sectionHeader(
          context,
          visibleDishCount: dishes
              .where((Dish dish) => !_exitingDishes.containsKey(dish.id))
              .length,
          totalDishCount: totalDishCount,
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 12)),
      SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.69,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final Dish dish = dishes[index];
            return KeyedSubtree(
              key: ValueKey<String>('menu_entry_dish_${dish.id}'),
              child: _removalTransition(
                removing: _removingDishIds.contains(dish.id),
                onExitCompleted: () => _finishDishExit(dish.id),
                child: MenuGridCard(
                  dish: dish,
                  selected: _selectedDishIds.contains(dish.id),
                  selectionMode: _isSelecting,
                  showNewBadge: _filter == MenuCollectionFilter.recent,
                  onTap: () => _handleDishTap(context, dish),
                  onLongPress: () => _startSelection(dish.id),
                  onSelect: () => _toggleSelection(dish.id),
                ),
              ),
            );
          },
          childCount: dishes.length,
        ),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          key: const ValueKey<String>('menu_bottom_scroll_clearance'),
          height: !_isSelecting
              ? MyMenuUnits.pageBottom
              : MyMenuUnits.pageBottom + 72,
        ),
      ),
    ];
  }

  Widget _removalTransition({
    required bool removing,
    required VoidCallback onExitCompleted,
    required Widget child,
  }) {
    return MenuExitTransition(
      duration: _cardExitDuration,
      removing: removing,
      onExitCompleted: onExitCompleted,
      child: child,
    );
  }

  void _finishDishExit(String dishId) {
    _dishExitFallbacks.remove(dishId)?.cancel();
    if (!mounted || !_exitingDishes.containsKey(dishId)) {
      return;
    }
    setState(() {
      _exitingDishes.remove(dishId);
      _removingDishIds.remove(dishId);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    widget.onQueryChanged('');
    setState(() {});
  }

  void _setFilter(MenuCollectionFilter filter) {
    setState(() => _filter = filter);
  }

  void _setCategory(String? category) {
    setState(() => _category = category);
  }
}
