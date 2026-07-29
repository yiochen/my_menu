part of 'menu_screen.dart';

extension _MenuScreenSections on _MenuScreenState {
  Widget _filters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          WarmPill(
            label: 'All',
            selected: _filter == MenuCollectionFilter.all,
            onPressed: () => _setFilter(MenuCollectionFilter.all),
          ),
          const SizedBox(width: 8),
          WarmPill(
            label: 'Favorites',
            selected: _filter == MenuCollectionFilter.favorites,
            onPressed: () => _setFilter(MenuCollectionFilter.favorites),
          ),
          const SizedBox(width: 8),
          WarmPill(
            label: 'Recently added',
            selected: _filter == MenuCollectionFilter.recent,
            onPressed: () => _setFilter(MenuCollectionFilter.recent),
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
        const Icon(
          Icons.arrow_downward_rounded,
          size: 14,
          color: MyMenuColors.muted,
        ),
        const SizedBox(width: 4),
        Text('Newest first', style: Theme.of(context).textTheme.bodySmall),
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
    dishes = newestFirst;
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

  List<CaptureBatch> _visibleProcessingBatches(MyMenuState state) {
    if (widget.query.trim().isNotEmpty ||
        _filter != MenuCollectionFilter.all ||
        _category != null) {
      return const <CaptureBatch>[];
    }
    return <CaptureBatch>[
      ...state.captureBatches,
      ..._exitingBatches.values,
    ]
        .where(
          (CaptureBatch batch) =>
              batch.status != CaptureBatchStatus.applied &&
              batch.status != CaptureBatchStatus.discarded,
        )
        .toList(growable: false)
      ..sort(
        (CaptureBatch left, CaptureBatch right) =>
            right.createdAt.compareTo(left.createdAt),
      );
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
