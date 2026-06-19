part of 'drag_drop_board.dart';

class _DragDropGroup<GroupId, ItemId, Item> extends StatefulWidget {
  const _DragDropGroup({
    required this.groupId,
    required this.items,
    required this.itemIdOf,
    required this.groupBuilder,
    required this.itemBuilder,
    required this.feedbackBuilder,
    required this.gapBuilder,
    required this.emptyGroupBuilder,
    required this.separatorBuilder,
    required this.separatorExtent,
    required this.defaultItemExtent,
    required this.session,
    required this.debugOptions,
    required this.onDragStarted,
    required this.onDragMoved,
    required this.onDragEnded,
    required this.onMoveAccepted,
    super.key,
  });

  final GroupId groupId;
  final List<Item> items;
  final DragDropItemIdOf<ItemId, Item> itemIdOf;
  final DragDropGroupBuilder<GroupId, ItemId, Item> groupBuilder;
  final DragDropItemBuilder<GroupId, ItemId, Item> itemBuilder;
  final DragDropFeedbackBuilder<GroupId, ItemId, Item> feedbackBuilder;
  final DragDropGapBuilder<GroupId, ItemId, Item> gapBuilder;
  final DragDropEmptyGroupBuilder<GroupId, ItemId, Item> emptyGroupBuilder;
  final DragDropSeparatorBuilder? separatorBuilder;
  final double separatorExtent;
  final double defaultItemExtent;
  final DragDropSession<GroupId, ItemId, Item>? session;
  final DragDropDebugOptions debugOptions;
  final ValueChanged<DragDropPayload<GroupId, ItemId, Item>> onDragStarted;
  final ValueChanged<Offset> onDragMoved;
  final VoidCallback onDragEnded;
  final void Function(
    DragDropPayload<GroupId, ItemId, Item> payload,
    GroupId targetGroupId,
    int targetIndex,
  ) onMoveAccepted;

  @override
  State<_DragDropGroup<GroupId, ItemId, Item>> createState() =>
      _DragDropGroupState<GroupId, ItemId, Item>();
}

class _DragDropGroupState<GroupId, ItemId, Item>
    extends State<_DragDropGroup<GroupId, ItemId, Item>> {
  final GlobalKey _itemsKey = GlobalKey();
  final Map<ItemId, double> _itemExtents = <ItemId, double>{};
  int? _hoveredInsertionIndex;
  List<double> _debugThresholdYs = const <double>[];
  double? _debugGhostCenterY;

  bool get _isDragging => widget.session != null;
  ItemId? get _draggingItemId => widget.session?.itemId;

  @override
  void didUpdateWidget(covariant _DragDropGroup<GroupId, ItemId, Item> old) {
    super.didUpdateWidget(old);
    if (!_isDragging) {
      _hoveredInsertionIndex = null;
      _debugThresholdYs = const <double>[];
      _debugGhostCenterY = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = widget.items.isEmpty
        ? _buildEmptyGroupTarget()
        : _buildItemsTarget(widget.items);

    return widget.groupBuilder(
      context,
      DragDropGroupState<GroupId, ItemId, Item>(
        groupId: widget.groupId,
        items: widget.items,
        isDragging: _isDragging,
        session: widget.session,
      ),
      child,
    );
  }

  Widget _buildEmptyGroupTarget() {
    return DragTarget<DragDropPayload<GroupId, ItemId, Item>>(
      onWillAcceptWithDetails:
          (DragTargetDetails<DragDropPayload<GroupId, ItemId, Item>> details) {
        return true;
      },
      onAcceptWithDetails:
          (DragTargetDetails<DragDropPayload<GroupId, ItemId, Item>> details) {
        widget.onMoveAccepted(details.data, widget.groupId, 0);
      },
      builder: (
        BuildContext context,
        List<DragDropPayload<GroupId, ItemId, Item>?> candidateData,
        List<dynamic> rejectedData,
      ) {
        return widget.emptyGroupBuilder(
          context,
          DragDropEmptyGroupState<GroupId, ItemId, Item>(
            groupId: widget.groupId,
            isDragging: _isDragging,
            isActive: candidateData.isNotEmpty,
            session: widget.session,
          ),
        );
      },
    );
  }

  Widget _buildItemsTarget(List<Item> items) {
    return DragTarget<DragDropPayload<GroupId, ItemId, Item>>(
      onWillAcceptWithDetails:
          (DragTargetDetails<DragDropPayload<GroupId, ItemId, Item>> details) {
        return true;
      },
      onMove:
          (DragTargetDetails<DragDropPayload<GroupId, ItemId, Item>> details) {
        final int nextIndex = _insertionIndexForOffset(items, details.offset);
        _updateDebugOverlay(items, details.offset);
        if (_hoveredInsertionIndex == nextIndex) {
          return;
        }
        setState(() {
          _hoveredInsertionIndex = nextIndex;
        });
      },
      onLeave: (DragDropPayload<GroupId, ItemId, Item>? data) {
        if (_hoveredInsertionIndex == null) {
          return;
        }
        setState(() {
          _hoveredInsertionIndex = null;
          _debugGhostCenterY = null;
        });
      },
      onAcceptWithDetails:
          (DragTargetDetails<DragDropPayload<GroupId, ItemId, Item>> details) {
        final int targetIndex = _insertionIndexForOffset(items, details.offset);
        widget.onMoveAccepted(details.data, widget.groupId, targetIndex);
        setState(() {
          _hoveredInsertionIndex = null;
          _debugGhostCenterY = null;
        });
      },
      builder: (
        BuildContext context,
        List<DragDropPayload<GroupId, ItemId, Item>?> candidateData,
        List<dynamic> rejectedData,
      ) {
        final List<Item> visibleItems = items
            .where((Item item) => widget.itemIdOf(item) != _draggingItemId)
            .toList(growable: false);

        return SizedBox(
          key: _itemsKey,
          width: double.infinity,
          child: Stack(
            children: <Widget>[
              if (_isDragging)
                _buildDraggingColumn(visibleItems)
              else
                _buildRestingColumn(items),
              if (_isDragging && widget.debugOptions.showThresholds)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _DragDropDebugPainter(
                        thresholdYs: _debugThresholdYs,
                        ghostCenterY: _debugGhostCenterY,
                        options: widget.debugOptions,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRestingColumn(List<Item> items) {
    return Column(
      children: <Widget>[
        for (int index = 0; index < items.length; index++) ...<Widget>[
          _buildDraggableItem(items[index], index),
          if (index != items.length - 1) _buildSeparator(context),
        ],
      ],
    );
  }

  Widget _buildDraggingColumn(List<Item> visibleItems) {
    return Column(
      children: <Widget>[
        for (int index = 0; index <= visibleItems.length; index++) ...<Widget>[
          _buildInsertionSlot(index, visibleItems.length),
          if (index < visibleItems.length)
            _buildDraggableItem(visibleItems[index], index),
        ],
      ],
    );
  }

  Widget _buildInsertionSlot(int index, int visibleItemCount) {
    final bool isActive = _activeInsertionIndex == index;

    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: Column(
        children: <Widget>[
          if (index > 0 && (isActive || index < visibleItemCount))
            _buildSeparator(context),
          widget.gapBuilder(
            context,
            DragDropGapState<GroupId, ItemId, Item>(
              groupId: widget.groupId,
              index: index,
              isActive: isActive,
              hasLeadingItem: index > 0,
              hasTrailingItem: index < visibleItemCount,
              draggedItemExtent:
                  widget.session?.itemExtent ?? widget.defaultItemExtent,
              session: widget.session,
            ),
          ),
          if (isActive && index < visibleItemCount) _buildSeparator(context),
        ],
      ),
    );
  }

  int? get _activeInsertionIndex {
    if (_hoveredInsertionIndex != null) {
      return _hoveredInsertionIndex;
    }
    final DragDropPayload<GroupId, ItemId, Item>? payload =
        widget.session?.payload;
    if (payload == null || payload.sourceGroupId != widget.groupId) {
      return null;
    }
    return payload.sourceIndex.clamp(0, widget.items.length - 1);
  }

  Widget _buildDraggableItem(Item item, int visibleIndex) {
    final ItemId itemId = widget.itemIdOf(item);
    final int sourceIndex = widget.items.indexWhere(
      (Item candidate) => widget.itemIdOf(candidate) == itemId,
    );
    final double itemExtent = _measuredItemExtentFor(itemId);
    final DragDropItemState<GroupId, ItemId, Item> itemState =
        DragDropItemState<GroupId, ItemId, Item>(
      groupId: widget.groupId,
      item: item,
      itemId: itemId,
      index: sourceIndex == -1 ? visibleIndex : sourceIndex,
      isDragging: _isDragging,
      itemExtent: itemExtent,
    );
    final DragDropPayload<GroupId, ItemId, Item> payload =
        DragDropPayload<GroupId, ItemId, Item>(
      item: item,
      itemId: itemId,
      sourceGroupId: widget.groupId,
      sourceIndex: itemState.index,
      itemExtent: itemExtent,
    );

    return _MeasuredDragDropItem(
      onExtentChanged: (double height) {
        _cacheItemExtent(itemId, height);
      },
      child: LongPressDraggable<DragDropPayload<GroupId, ItemId, Item>>(
        data: payload,
        maxSimultaneousDrags: 1,
        onDragStarted: () => widget.onDragStarted(payload),
        onDragUpdate: (DragUpdateDetails details) {
          widget.onDragMoved(details.globalPosition);
        },
        onDraggableCanceled: (_, __) => widget.onDragEnded(),
        onDragCompleted: widget.onDragEnded,
        onDragEnd: (_) => widget.onDragEnded(),
        feedback: widget.feedbackBuilder(context, itemState),
        childWhenDragging: const SizedBox.shrink(),
        child: widget.itemBuilder(context, itemState),
      ),
    );
  }

  Widget _buildSeparator(BuildContext context) {
    return widget.separatorBuilder?.call(context) ?? const SizedBox.shrink();
  }

  int _insertionIndexForOffset(List<Item> items, Offset globalFeedbackOrigin) {
    final BuildContext? context = _itemsKey.currentContext;
    if (context == null) {
      return _hoveredInsertionIndex ?? 0;
    }
    final RenderBox box = context.findRenderObject()! as RenderBox;
    final double feedbackTopY = box.globalToLocal(globalFeedbackOrigin).dy;
    final double comparisonY = feedbackTopY +
        (widget.session?.itemExtent ?? widget.defaultItemExtent) / 2;

    return dragDropInsertionIndexForCenters<ItemId>(
      centers: _frozenItemCenters(items),
      draggedItemId: _draggingItemId,
      comparisonY: comparisonY,
    );
  }

  List<DragDropItemCenter<ItemId>> _frozenItemCenters(List<Item> items) {
    return dragDropFrozenItemCenters<ItemId>(
      itemIds: items.map(widget.itemIdOf).toList(growable: false),
      extentForItem: _measuredItemExtentFor,
      separatorExtent: widget.separatorExtent,
    );
  }

  double _measuredItemExtentFor(ItemId itemId) {
    if (itemId == _draggingItemId && widget.session != null) {
      return widget.session!.itemExtent;
    }
    return _itemExtents[itemId] ?? widget.defaultItemExtent;
  }

  void _cacheItemExtent(ItemId itemId, double height) {
    if (_itemExtents[itemId] == height) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _itemExtents[itemId] == height) {
        return;
      }
      setState(() {
        _itemExtents[itemId] = height;
      });
    });
  }

  void _updateDebugOverlay(List<Item> items, Offset globalFeedbackOrigin) {
    final BuildContext? context = _itemsKey.currentContext;
    if (context == null) {
      return;
    }
    final RenderBox box = context.findRenderObject()! as RenderBox;
    final double feedbackTopY = box.globalToLocal(globalFeedbackOrigin).dy;
    final double ghostCenterY = feedbackTopY +
        (widget.session?.itemExtent ?? widget.defaultItemExtent) / 2;
    final List<double> thresholdYs = _frozenItemCenters(items)
        .where((DragDropItemCenter<ItemId> center) {
          return center.itemId != _draggingItemId;
        })
        .map((DragDropItemCenter<ItemId> center) => center.centerY)
        .toList(growable: false);

    if (_sameThresholds(_debugThresholdYs, thresholdYs) &&
        _debugGhostCenterY == ghostCenterY) {
      return;
    }
    setState(() {
      _debugThresholdYs = thresholdYs;
      _debugGhostCenterY = ghostCenterY;
    });
  }

  bool _sameThresholds(List<double> a, List<double> b) {
    if (a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
