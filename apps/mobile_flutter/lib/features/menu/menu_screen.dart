import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/services.dart';

import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/capture/capture_feed_sheet.dart';
import 'package:mymenu/features/dish_detail/dish_detail_screen.dart';
import 'package:mymenu/features/menu/menu_category_filter_sheet.dart';
import 'package:mymenu/features/menu/menu_delete_dialog.dart';
import 'package:mymenu/features/menu/menu_empty_states.dart';
import 'package:mymenu/features/menu/menu_exit_transition.dart';
import 'package:mymenu/features/menu/menu_grid_card.dart';
import 'package:mymenu/features/menu/menu_processing_dish_card.dart';
import 'package:mymenu/features/menu/menu_sticky_header.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

part 'menu_screen_sections.dart';
part 'menu_selection.dart';

enum MenuCollectionFilter { all, favorites, recent }

class MenuScreen extends StatefulWidget {
  const MenuScreen({
    required this.query,
    required this.onQueryChanged,
    this.onSelectionModeChanged,
    super.key,
  });

  final String query;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<bool>? onSelectionModeChanged;

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
  MenuCollectionFilter _filter = MenuCollectionFilter.all;
  String? _category;
  final Set<String> _selectedDishIds = <String>{};
  final Set<String> _selectedBatchIds = <String>{};
  final Set<String> _removingDishIds = <String>{};
  final Set<String> _removingBatchIds = <String>{};
  final Map<String, Dish> _exitingDishes = <String, Dish>{};
  final Map<String, CaptureBatch> _exitingBatches = <String, CaptureBatch>{};
  final Map<String, Timer> _dishExitFallbacks = <String, Timer>{};
  final Map<String, Timer> _batchExitFallbacks = <String, Timer>{};

  int get _selectedCount => _selectedDishIds.length + _selectedBatchIds.length;

  bool get _isSelecting => _selectedCount > 0;

  void _updateSelection(VoidCallback update) => setState(update);

  @override
  void didUpdateWidget(covariant MenuScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _searchController.text) {
      _searchController.text = widget.query;
    }
  }

  @override
  void dispose() {
    for (final Timer timer in <Timer>[
      ..._dishExitFallbacks.values,
      ..._batchExitFallbacks.values,
    ]) {
      timer.cancel();
    }
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);
    final List<Dish> dishes = _visibleDishes(state);
    final List<CaptureBatch> processingBatches =
        _visibleProcessingBatches(state);
    final Set<String> availableDishIds =
        state.dishes.map((Dish dish) => dish.id).toSet();
    _selectedDishIds.removeWhere(
      (String dishId) => !availableDishIds.contains(dishId),
    );
    final Set<String> availableBatchIds =
        processingBatches.map((CaptureBatch batch) => batch.id).toSet();
    _selectedBatchIds.removeWhere(
      (String batchId) => !availableBatchIds.contains(batchId),
    );
    final bool hasMenuContent = state.dishes.isNotEmpty ||
        processingBatches.isNotEmpty ||
        _exitingDishes.isNotEmpty ||
        _exitingBatches.isNotEmpty;
    final double horizontal = MyMenuUnits.pageHorizontal(context);
    return WarmPage(
      topPadding: 0,
      bottomPadding: 0,
      horizontalPadding: 0,
      child: Stack(
        children: <Widget>[
          RefreshIndicator(
            onRefresh: state.refreshFromServer,
            child: _scrollView(
              context,
              state: state,
              dishes: dishes,
              processingBatches: processingBatches,
              hasMenuContent: hasMenuContent,
              horizontal: horizontal,
            ),
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
    required List<CaptureBatch> processingBatches,
    required bool hasMenuContent,
    required double horizontal,
  }) {
    return CustomScrollView(
      key: const ValueKey<String>('menu_screen'),
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        SliverAppBar(
          key: const ValueKey<String>('menu_sticky_app_bar'),
          pinned: true,
          automaticallyImplyLeading: false,
          toolbarHeight: 62,
          titleSpacing: horizontal,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: MyMenuColors.cream,
          surfaceTintColor: Colors.transparent,
          title: MenuStickyHeader(
            controller: _searchController,
            query: widget.query,
            onQueryChanged: widget.onQueryChanged,
            onClearQuery: _clearSearch,
            selectedCount: _selectedCount,
            allSelected: (dishes.isNotEmpty || processingBatches.isNotEmpty) &&
                dishes.every(
                  (Dish dish) => _selectedDishIds.contains(dish.id),
                ) &&
                processingBatches.every(
                  (CaptureBatch batch) => _selectedBatchIds.contains(batch.id),
                ),
            onCloseSelection: _clearSelection,
            onSelectAll: () => _toggleSelectAll(dishes, processingBatches),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontal),
          sliver: SliverMainAxisGroup(
            slivers: <Widget>[
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              if (state.dishes.isNotEmpty) ...<Widget>[
                SliverToBoxAdapter(child: _filters()),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
              if (!hasMenuContent)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: MenuEmpty(),
                )
              else if (dishes.isEmpty && processingBatches.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: MenuSearchEmpty(onClear: _clearSearch),
                )
              else
                ..._menuGridSlivers(
                  context,
                  state: state,
                  dishes: dishes,
                  processingBatches: processingBatches,
                  totalDishCount: state.dishes.length,
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _menuGridSlivers(
    BuildContext context, {
    required MyMenuState state,
    required List<Dish> dishes,
    required List<CaptureBatch> processingBatches,
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
            if (index < processingBatches.length) {
              final CaptureBatch batch = processingBatches[index];
              return KeyedSubtree(
                key: ValueKey<String>('menu_entry_batch_${batch.id}'),
                child: _removalTransition(
                  removing: _removingBatchIds.contains(batch.id),
                  onExitCompleted: () => _finishBatchExit(batch.id),
                  child: MenuProcessingDishCard(
                    batch: batch,
                    selected: _selectedBatchIds.contains(batch.id),
                    selectionMode: _isSelecting,
                    onTap: () => _handleBatchTap(context, state, batch),
                    onLongPress: () => _startBatchSelection(batch.id),
                  ),
                ),
              );
            }
            final Dish dish = dishes[index - processingBatches.length];
            return KeyedSubtree(
              key: ValueKey<String>('menu_entry_dish_${dish.id}'),
              child: _removalTransition(
                removing: _removingDishIds.contains(dish.id),
                onExitCompleted: () => _finishDishExit(dish.id),
                child: MenuGridCard(
                  dish: dish,
                  selected: _selectedDishIds.contains(dish.id),
                  selectionMode: _isSelecting,
                  onTap: () => _handleDishTap(context, dish),
                  onLongPress: () => _startSelection(dish.id),
                  onSelect: () => _toggleSelection(dish.id),
                ),
              ),
            );
          },
          childCount: processingBatches.length + dishes.length,
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

  void _finishBatchExit(String batchId) {
    _batchExitFallbacks.remove(batchId)?.cancel();
    if (!mounted || !_exitingBatches.containsKey(batchId)) {
      return;
    }
    setState(() {
      _exitingBatches.remove(batchId);
      _removingBatchIds.remove(batchId);
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
