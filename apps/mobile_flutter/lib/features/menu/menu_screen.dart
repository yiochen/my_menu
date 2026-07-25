import 'package:flutter/material.dart';

import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/menu/menu_grid_card.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

enum MenuCollectionFilter { all, favorites, recent }

class MenuScreen extends StatefulWidget {
  const MenuScreen({
    required this.query,
    required this.onQueryChanged,
    super.key,
  });

  final String query;
  final ValueChanged<String> onQueryChanged;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  MenuCollectionFilter _filter = MenuCollectionFilter.all;
  String? _category;

  @override
  void didUpdateWidget(covariant MenuScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _searchController.text) {
      _searchController.text = widget.query;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);
    final List<Dish> dishes = _visibleDishes(state);
    return WarmPage(
      topPadding: 0,
      child: RefreshIndicator(
        onRefresh: state.refreshFromServer,
        child: CustomScrollView(
          key: const ValueKey<String>('menu_screen'),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.paddingOf(context).top + MyMenuUnits.pageTop,
              ),
            ),
            SliverToBoxAdapter(
              child: RepaintBoundary(
                key: const ValueKey<String>('menu_heading_golden'),
                child: _header(
                  context,
                  showDishCount: state.dishes.isNotEmpty,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            if (state.dishes.isNotEmpty) ...<Widget>[
              SliverToBoxAdapter(child: _searchField()),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(child: _filters()),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
            if (state.dishes.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyMenu(),
              )
            else if (dishes.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _SearchEmpty(
                  onClear: () {
                    _searchController.clear();
                    widget.onQueryChanged('');
                    setState(() {});
                  },
                ),
              )
            else ...<Widget>[
              SliverToBoxAdapter(child: _sectionHeader(context)),
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
                    return MenuGridCard(dish: dishes[index]);
                  },
                  childCount: dishes.length,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _header(
    BuildContext context, {
    required bool showDishCount,
  }) {
    return ConstrainedBox(
      key: const ValueKey<String>('menu_heading'),
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Your personal restaurant',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Row(
                  children: <Widget>[
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'My Menu',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (showDishCount)
                      const WarmPill(
                        label: '24 dishes',
                        orange: true,
                        compact: true,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const MyMenuAvatar(),
        ],
      ),
    );
  }

  Widget _searchField() {
    return TextField(
      key: const ValueKey<String>('menu_search_field'),
      controller: _searchController,
      onChanged: widget.onQueryChanged,
      decoration: InputDecoration(
        hintText: 'Search dishes, notes, ingredients',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: widget.query.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _searchController.clear();
                  widget.onQueryChanged('');
                  setState(() {});
                },
                icon: const Icon(Icons.close),
              ),
      ),
    );
  }

  Widget _filters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          WarmPill(
            label: 'All',
            selected: _filter == MenuCollectionFilter.all,
            onPressed: () => setState(() => _filter = MenuCollectionFilter.all),
          ),
          const SizedBox(width: 8),
          WarmPill(
            label: 'Favorites',
            selected: _filter == MenuCollectionFilter.favorites,
            onPressed: () =>
                setState(() => _filter = MenuCollectionFilter.favorites),
          ),
          const SizedBox(width: 8),
          WarmPill(
            label: 'Recently added',
            selected: _filter == MenuCollectionFilter.recent,
            onPressed: () =>
                setState(() => _filter = MenuCollectionFilter.recent),
          ),
          const SizedBox(width: 8),
          WarmPill(
            label: _category ?? 'Filters',
            icon: Icons.tune,
            orange: _category != null,
            onPressed: _showCategoryFilters,
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            _filter == MenuCollectionFilter.favorites
                ? 'Favorites'
                : _filter == MenuCollectionFilter.recent
                    ? 'Recently added'
                    : 'All dishes',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Text('Newest first', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  List<Dish> _visibleDishes(MyMenuState state) {
    Iterable<Dish> dishes = state.filterDishes(widget.query);
    if (_filter == MenuCollectionFilter.favorites) {
      dishes = dishes.where((Dish dish) => dish.isFavorite);
    } else if (_filter == MenuCollectionFilter.recent) {
      dishes = dishes.take(3);
    }
    if (_category != null) {
      dishes = dishes.where((Dish dish) => dish.category == _category);
    }
    return dishes.toList(growable: false);
  }

  Future<void> _showCategoryFilters() async {
    final String? next = await showModalBottomSheet<String?>(
      context: context,
      useSafeArea: true,
      builder: (BuildContext context) {
        return WarmPage(
          includeBottomChromeSpace: false,
          topPadding: 10,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SheetTopBar(
                title: 'Filter dishes',
                onClose: () => Navigator.pop(context),
              ),
              const SizedBox(height: 12),
              for (final String category in <String>[
                'Bowls',
                'Pasta',
                'Mains',
                'Soups'
              ])
                ListTile(
                  title: Text(category),
                  trailing: _category == category
                      ? const Icon(
                          Icons.check,
                          color: MyMenuColors.orangeDark,
                        )
                      : null,
                  onTap: () => Navigator.pop(context, category),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context, ''),
                child: const Text('Clear filters'),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted || next == null) {
      return;
    }
    setState(() => _category = next.isEmpty ? null : next);
  }
}

class _SearchEmpty extends StatelessWidget {
  const _SearchEmpty({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 116,
          height: 116,
          decoration: BoxDecoration(
            color: MyMenuColors.orangeSoft,
            borderRadius: BorderRadius.circular(38),
          ),
          child: const Icon(
            Icons.search_off_rounded,
            size: 52,
            color: MyMenuColors.orange,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'No dish named that—yet',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Try fewer words or search for an ingredient or note.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: 150,
          child: PrimaryPillButton(
            label: 'Clear search',
            onPressed: onClear,
            backgroundColor: MyMenuColors.oat,
            foregroundColor: MyMenuColors.ink,
          ),
        ),
      ],
    );
  }
}

class _EmptyMenu extends StatelessWidget {
  const _EmptyMenu();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Icon(Icons.auto_awesome, size: 96, color: MyMenuColors.orange),
        const SizedBox(height: 16),
        Text(
          'Capture your first cooking moment',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'A photo, an import, or even a rough idea is enough. '
          'MyMenu organizes it after capture.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 14),
        const StatusStrip(
          icon: Icons.arrow_downward_rounded,
          text: 'Tap the orange + below to begin',
          color: MyMenuColors.orangeDark,
          background: MyMenuColors.orangeSoft,
        ),
      ],
    );
  }
}
