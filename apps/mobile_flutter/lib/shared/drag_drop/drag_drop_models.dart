part of 'drag_drop_board.dart';

class MultiSelectDragDropPayload<GroupId, ItemId, Item> {
  const MultiSelectDragDropPayload({
    required this.items,
    required this.itemIds,
    required this.sourceGroupIds,
  })  : assert(
          items.length == itemIds.length,
          'Each dragged item must have one item ID.',
        ),
        assert(
          items.length == sourceGroupIds.length,
          'Each dragged item must have one source group ID.',
        );

  final List<Item> items;
  final List<ItemId> itemIds;
  final List<GroupId> sourceGroupIds;

  int get length => items.length;

  bool contains(ItemId itemId) => itemIds.contains(itemId);
}

class DragDropPayload<GroupId, ItemId, Item> {
  const DragDropPayload({
    required this.item,
    required this.itemId,
    required this.sourceGroupId,
    required this.sourceIndex,
    required this.itemExtent,
  });

  final Item item;
  final ItemId itemId;
  final GroupId sourceGroupId;
  final int sourceIndex;
  final double itemExtent;

  bool isSourcePosition(GroupId groupId, int index) {
    return sourceGroupId == groupId && sourceIndex == index;
  }
}

class DragDropMove<GroupId, ItemId, Item> {
  const DragDropMove({
    required this.item,
    required this.itemId,
    required this.fromGroupId,
    required this.fromIndex,
    required this.toGroupId,
    required this.toIndex,
  });

  final Item item;
  final ItemId itemId;
  final GroupId fromGroupId;
  final int fromIndex;
  final GroupId toGroupId;
  final int toIndex;
}

class DragDropSession<GroupId, ItemId, Item> {
  const DragDropSession({
    required this.payload,
    required this.globalPosition,
  });

  final DragDropPayload<GroupId, ItemId, Item> payload;
  final Offset? globalPosition;

  Item get item => payload.item;
  ItemId get itemId => payload.itemId;
  GroupId get sourceGroupId => payload.sourceGroupId;
  int get sourceIndex => payload.sourceIndex;
  double get itemExtent => payload.itemExtent;

  DragDropSession<GroupId, ItemId, Item> copyWith({
    Offset? globalPosition,
  }) {
    return DragDropSession<GroupId, ItemId, Item>(
      payload: payload,
      globalPosition: globalPosition,
    );
  }
}

class DragDropGroupState<GroupId, ItemId, Item> {
  const DragDropGroupState({
    required this.groupId,
    required this.items,
    required this.isDragging,
    required this.session,
  });

  final GroupId groupId;
  final List<Item> items;
  final bool isDragging;
  final DragDropSession<GroupId, ItemId, Item>? session;
}

class DragDropItemState<GroupId, ItemId, Item> {
  const DragDropItemState({
    required this.groupId,
    required this.item,
    required this.itemId,
    required this.index,
    required this.isDragging,
    required this.itemExtent,
  });

  final GroupId groupId;
  final Item item;
  final ItemId itemId;
  final int index;
  final bool isDragging;
  final double itemExtent;
}

class DragDropGapState<GroupId, ItemId, Item> {
  const DragDropGapState({
    required this.groupId,
    required this.index,
    required this.isActive,
    required this.hasLeadingItem,
    required this.hasTrailingItem,
    required this.draggedItemExtent,
    required this.session,
  });

  final GroupId groupId;
  final int index;
  final bool isActive;
  final bool hasLeadingItem;
  final bool hasTrailingItem;
  final double draggedItemExtent;
  final DragDropSession<GroupId, ItemId, Item>? session;
}

class DragDropEmptyGroupState<GroupId, ItemId, Item> {
  const DragDropEmptyGroupState({
    required this.groupId,
    required this.isDragging,
    required this.isActive,
    required this.session,
  });

  final GroupId groupId;
  final bool isDragging;
  final bool isActive;
  final DragDropSession<GroupId, ItemId, Item>? session;
}

class DragDropItemCenter<ItemId> {
  const DragDropItemCenter(this.itemId, this.centerY);

  final ItemId itemId;
  final double centerY;
}

class DragDropDebugOptions {
  const DragDropDebugOptions({
    this.showThresholds = false,
    this.thresholdColor = const Color(0xAA00AEEF),
    this.ghostCenterColor = const Color(0xCCFF3B30),
  });

  final bool showThresholds;
  final Color thresholdColor;
  final Color ghostCenterColor;
}
