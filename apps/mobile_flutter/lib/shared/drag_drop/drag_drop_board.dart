import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

part 'drag_drop_debug.dart';
part 'drag_drop_group.dart';
part 'drag_drop_measurement.dart';
part 'drag_drop_models.dart';

typedef DragDropItemsForGroup<GroupId, Item> = List<Item> Function(
  GroupId groupId,
);

typedef DragDropItemIdOf<ItemId, Item> = ItemId Function(Item item);

typedef DragDropGroupBuilder<GroupId, ItemId, Item> = Widget Function(
  BuildContext context,
  DragDropGroupState<GroupId, ItemId, Item> state,
  Widget child,
);

typedef DragDropItemBuilder<GroupId, ItemId, Item> = Widget Function(
  BuildContext context,
  DragDropItemState<GroupId, ItemId, Item> state,
);

typedef DragDropFeedbackBuilder<GroupId, ItemId, Item> = Widget Function(
  BuildContext context,
  DragDropItemState<GroupId, ItemId, Item> state,
);

typedef DragDropGapBuilder<GroupId, ItemId, Item> = Widget Function(
  BuildContext context,
  DragDropGapState<GroupId, ItemId, Item> state,
);

typedef DragDropEmptyGroupBuilder<GroupId, ItemId, Item> = Widget Function(
  BuildContext context,
  DragDropEmptyGroupState<GroupId, ItemId, Item> state,
);

typedef DragDropSeparatorBuilder = Widget Function(BuildContext context);

class DragDropBoard<GroupId, ItemId, Item> extends StatefulWidget {
  const DragDropBoard({
    required this.groupIds,
    required this.itemsForGroup,
    required this.itemIdOf,
    required this.groupBuilder,
    required this.itemBuilder,
    required this.feedbackBuilder,
    required this.gapBuilder,
    required this.emptyGroupBuilder,
    required this.onMove,
    required this.defaultItemExtent,
    this.separatorBuilder,
    this.separatorExtent = 0,
    this.scrollController,
    this.dragSession,
    this.onDragSessionChanged,
    this.onDragPositionChanged,
    this.debugOptions = const DragDropDebugOptions(),
    this.autoScrollTriggerExtent = 140,
    this.autoScrollMaxStep = 20,
    super.key,
  });

  final List<GroupId> groupIds;
  final DragDropItemsForGroup<GroupId, Item> itemsForGroup;
  final DragDropItemIdOf<ItemId, Item> itemIdOf;
  final DragDropGroupBuilder<GroupId, ItemId, Item> groupBuilder;
  final DragDropItemBuilder<GroupId, ItemId, Item> itemBuilder;
  final DragDropFeedbackBuilder<GroupId, ItemId, Item> feedbackBuilder;
  final DragDropGapBuilder<GroupId, ItemId, Item> gapBuilder;
  final DragDropEmptyGroupBuilder<GroupId, ItemId, Item> emptyGroupBuilder;
  final DragDropSeparatorBuilder? separatorBuilder;
  final ValueChanged<DragDropMove<GroupId, ItemId, Item>> onMove;
  final double defaultItemExtent;
  final double separatorExtent;
  final ScrollController? scrollController;
  final DragDropSession<GroupId, ItemId, Item>? dragSession;
  final ValueChanged<DragDropSession<GroupId, ItemId, Item>?>?
      onDragSessionChanged;
  final ValueChanged<Offset>? onDragPositionChanged;
  final DragDropDebugOptions debugOptions;
  final double autoScrollTriggerExtent;
  final double autoScrollMaxStep;

  @override
  State<DragDropBoard<GroupId, ItemId, Item>> createState() =>
      _DragDropBoardState<GroupId, ItemId, Item>();
}

class _DragDropBoardState<GroupId, ItemId, Item>
    extends State<DragDropBoard<GroupId, ItemId, Item>>
    with SingleTickerProviderStateMixin {
  Ticker? _autoScrollTicker;
  Duration? _lastAutoScrollTick;
  DragDropSession<GroupId, ItemId, Item>? _session;

  DragDropSession<GroupId, ItemId, Item>? get _effectiveSession =>
      widget.dragSession ?? _session;
  bool get _isDragging => _effectiveSession != null;

  @override
  void didUpdateWidget(covariant DragDropBoard<GroupId, ItemId, Item> old) {
    super.didUpdateWidget(old);
    if (old.dragSession == null && widget.dragSession != null) {
      _startAutoScroll();
    } else if (old.dragSession != null && widget.dragSession == null) {
      _session = null;
      _stopAutoScroll();
    }
  }

  @override
  void dispose() {
    _autoScrollTicker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.groupIds.map((GroupId groupId) {
        final List<Item> items = widget.itemsForGroup(groupId);
        return _DragDropGroup<GroupId, ItemId, Item>(
          key: ValueKey<GroupId>(groupId),
          groupId: groupId,
          items: items,
          itemIdOf: widget.itemIdOf,
          groupBuilder: widget.groupBuilder,
          itemBuilder: widget.itemBuilder,
          feedbackBuilder: widget.feedbackBuilder,
          gapBuilder: widget.gapBuilder,
          emptyGroupBuilder: widget.emptyGroupBuilder,
          separatorBuilder: widget.separatorBuilder,
          separatorExtent: widget.separatorExtent,
          defaultItemExtent: widget.defaultItemExtent,
          session: _effectiveSession,
          debugOptions: widget.debugOptions,
          onDragStarted: _handleDragStarted,
          onDragMoved: _handleDragMoved,
          onDragEnded: _handleDragEnded,
          onMoveAccepted: _handleMoveAccepted,
        );
      }).toList(growable: false),
    );
  }

  void _handleDragStarted(DragDropPayload<GroupId, ItemId, Item> payload) {
    _setSession(
      DragDropSession<GroupId, ItemId, Item>(
        payload: payload,
        globalPosition: null,
      ),
    );
    _startAutoScroll();
  }

  void _handleDragMoved(Offset globalPosition) {
    final DragDropSession<GroupId, ItemId, Item>? effective = _effectiveSession;
    if (effective == null || !mounted) {
      return;
    }

    widget.onDragPositionChanged?.call(globalPosition);
    if (widget.dragSession == null) {
      _setSession(effective.copyWith(globalPosition: globalPosition));
    }
  }

  void _handleDragEnded() {
    _setSession(null);
    _stopAutoScroll();
  }

  void _handleMoveAccepted(
    DragDropPayload<GroupId, ItemId, Item> payload,
    GroupId targetGroupId,
    int targetIndex,
  ) {
    if (!payload.isSourcePosition(targetGroupId, targetIndex)) {
      widget.onMove(
        DragDropMove<GroupId, ItemId, Item>(
          item: payload.item,
          itemId: payload.itemId,
          fromGroupId: payload.sourceGroupId,
          fromIndex: payload.sourceIndex,
          toGroupId: targetGroupId,
          toIndex: targetIndex,
        ),
      );
    }
    _handleDragEnded();
  }

  void _setSession(DragDropSession<GroupId, ItemId, Item>? session) {
    if (!mounted) {
      return;
    }

    setState(() {
      _session = session;
    });
    widget.onDragSessionChanged?.call(session);
  }

  void _startAutoScroll() {
    _lastAutoScrollTick = null;
    _autoScrollTicker ??= createTicker(_handleAutoScrollTick);
    if (!_autoScrollTicker!.isActive) {
      _autoScrollTicker!.start();
    }
  }

  void _stopAutoScroll() {
    _autoScrollTicker?.stop();
    _lastAutoScrollTick = null;
  }

  void _handleAutoScrollTick(Duration elapsed) {
    final ScrollController? controller = widget.scrollController;
    final Offset? dragPosition = _effectiveSession?.globalPosition;
    final Duration? previousElapsed = _lastAutoScrollTick;
    _lastAutoScrollTick = elapsed;
    if (!_isDragging ||
        dragPosition == null ||
        previousElapsed == null ||
        controller == null ||
        !controller.hasClients ||
        !mounted) {
      return;
    }

    final RenderBox? viewportBox = _scrollViewportBox();
    final double topEdge = viewportBox?.localToGlobal(Offset.zero).dy ?? 0;
    final double bottomEdge = viewportBox == null
        ? MediaQuery.sizeOf(context).height
        : topEdge + viewportBox.size.height;
    final double trigger = widget.autoScrollTriggerExtent;
    final double elapsedSeconds =
        (elapsed - previousElapsed).inMicroseconds.clamp(0, 50000).toDouble() /
            Duration.microsecondsPerSecond;
    final double frameScale = elapsedSeconds * 60;
    double direction = 0;
    double progress = 0;

    if (dragPosition.dy < topEdge + trigger) {
      direction = -1;
      progress =
          ((topEdge + trigger - dragPosition.dy) / trigger).clamp(0.0, 1.0);
    } else if (dragPosition.dy > bottomEdge - trigger) {
      direction = 1;
      progress = ((dragPosition.dy - (bottomEdge - trigger)) / trigger)
          .clamp(0.0, 1.0);
    }

    if (direction == 0 || progress == 0) {
      return;
    }

    final double nextOffset = (controller.offset +
            direction * widget.autoScrollMaxStep * progress * frameScale)
        .clamp(
      controller.position.minScrollExtent,
      controller.position.maxScrollExtent,
    );
    if (nextOffset != controller.offset) {
      controller.jumpTo(nextOffset);
    }
  }

  RenderBox? _scrollViewportBox() {
    final ScrollableState? scrollable = Scrollable.maybeOf(context);
    final RenderObject? renderObject =
        scrollable?.context.findRenderObject() ?? context.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      return renderObject;
    }
    return null;
  }
}

@visibleForTesting
List<DragDropItemCenter<ItemId>> dragDropFrozenItemCenters<ItemId>({
  required List<ItemId> itemIds,
  required double Function(ItemId itemId) extentForItem,
  required double separatorExtent,
}) {
  double cursor = 0;
  final List<DragDropItemCenter<ItemId>> centers =
      <DragDropItemCenter<ItemId>>[];
  for (int index = 0; index < itemIds.length; index++) {
    final ItemId itemId = itemIds[index];
    final double itemExtent = extentForItem(itemId);
    centers.add(DragDropItemCenter<ItemId>(itemId, cursor + itemExtent / 2));
    cursor += itemExtent;
    if (index != itemIds.length - 1) {
      cursor += separatorExtent;
    }
  }
  return centers;
}

@visibleForTesting
int dragDropInsertionIndexForCenters<ItemId>({
  required List<DragDropItemCenter<ItemId>> centers,
  required ItemId? draggedItemId,
  required double comparisonY,
}) {
  int insertionIndex = 0;
  for (final DragDropItemCenter<ItemId> center in centers) {
    if (center.itemId == draggedItemId) {
      continue;
    }
    if (comparisonY > center.centerY) {
      insertionIndex += 1;
    }
  }
  return insertionIndex;
}
