part of 'menu_screen.dart';

extension _MenuScreenSections on _MenuScreenState {
  Widget _filters() {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 32,
          height: 32,
          child: IconButton(
            key: const ValueKey<String>('menu_filter_button'),
            tooltip: _category ?? 'Filters',
            padding: EdgeInsets.zero,
            style: IconButton.styleFrom(
              backgroundColor: _category == null
                  ? MyMenuColors.oat
                  : MyMenuColors.orangeSoft,
              foregroundColor: _category == null
                  ? MyMenuColors.ink
                  : MyMenuColors.orangeDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            onPressed: _showCategoryFilters,
            icon: const Icon(Icons.tune_rounded, size: 17),
          ),
        ),
        const SizedBox(width: 8),
        Container(width: 1, height: 22, color: const Color(0x1F362D25)),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                WarmPill(
                  label: 'All',
                  compact: true,
                  selected: _filter == MenuCollectionFilter.all,
                  onPressed: () => _setFilter(MenuCollectionFilter.all),
                ),
                const SizedBox(width: 6),
                WarmPill(
                  label: 'Favorites',
                  compact: true,
                  selected: _filter == MenuCollectionFilter.favorites,
                  onPressed: () => _setFilter(MenuCollectionFilter.favorites),
                ),
                const SizedBox(width: 6),
                WarmPill(
                  label: 'Recently added',
                  compact: true,
                  selected: _filter == MenuCollectionFilter.recent,
                  onPressed: () => _setFilter(MenuCollectionFilter.recent),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(
    BuildContext context, {
    required int visibleDishCount,
    required int totalDishCount,
  }) {
    final String title = _filter == MenuCollectionFilter.favorites
        ? 'Favorites'
        : _filter == MenuCollectionFilter.recent
            ? 'Recently added'
            : 'All dishes';
    final int count = widget.query.trim().isEmpty &&
            _filter == MenuCollectionFilter.all &&
            _category == null
        ? totalDishCount
        : visibleDishCount;
    return Row(
      children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$count',
                key: const ValueKey<String>('menu_collection_count'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: MyMenuColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          key: const ValueKey<String>('menu_sort_button'),
          tooltip: _newestFirst ? 'Newest first' : 'Oldest first',
          onPressed: () => _updateSelection(() => _newestFirst = !_newestFirst),
          style: IconButton.styleFrom(
            backgroundColor: MyMenuColors.oat,
            foregroundColor: MyMenuColors.muted,
            fixedSize: const Size(32, 32),
            minimumSize: const Size(32, 32),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
          ),
          icon: Icon(
            _newestFirst
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            size: 17,
          ),
        ),
      ],
    );
  }

  List<Dish> _visibleDishes(MyMenuState state) {
    Iterable<Dish> dishes = <Dish>[
      ...state.filterDishes(widget.query),
      ..._exitingDishes.values,
    ];
    final List<Dish> newestFirst = dishes.toList(growable: false)
      ..sort(_compareNewestDish);
    dishes = _newestFirst ? newestFirst : newestFirst.reversed;
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

  int _compareNewestDish(Dish left, Dish right) {
    final DateTime leftDate = left.createdAt ??
        left.sourcePhotos
            .map((photo) => photo.capturedAt)
            .whereType<DateTime>()
            .fold(
              DateTime.fromMillisecondsSinceEpoch(0),
              (DateTime newest, DateTime value) =>
                  value.isAfter(newest) ? value : newest,
            );
    final DateTime rightDate = right.createdAt ??
        right.sourcePhotos
            .map((photo) => photo.capturedAt)
            .whereType<DateTime>()
            .fold(
              DateTime.fromMillisecondsSinceEpoch(0),
              (DateTime newest, DateTime value) =>
                  value.isAfter(newest) ? value : newest,
            );
    final int byDate = rightDate.compareTo(leftDate);
    return byDate != 0 ? byDate : left.title.compareTo(right.title);
  }

  Future<void> _showCategoryFilters() async {
    final String? next = await showMenuCategoryFilterSheet(
      context,
      selectedCategory: _category,
    );
    if (!mounted || next == null) {
      return;
    }
    _setCategory(next.isEmpty ? null : next);
  }
}
