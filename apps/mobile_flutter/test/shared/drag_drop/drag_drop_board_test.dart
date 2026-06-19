import 'package:flutter_test/flutter_test.dart';
import 'package:mymenu/shared/drag_drop/drag_drop_board.dart';

void main() {
  group('DragDropBoard helpers', () {
    test('computes frozen item centers with separator extent', () {
      final List<DragDropItemCenter<String>> centers =
          dragDropFrozenItemCenters<String>(
        itemIds: <String>['first', 'second'],
        extentForItem: (String itemId) => itemId == 'first' ? 20 : 10,
        separatorExtent: 4,
      );

      expect(centers[0].itemId, 'first');
      expect(centers[0].centerY, 10);
      expect(centers[1].itemId, 'second');
      expect(centers[1].centerY, 29);
    });

    test('calculates insertion index from frozen centers', () {
      const List<DragDropItemCenter<String>> centers =
          <DragDropItemCenter<String>>[
        DragDropItemCenter<String>('first', 10),
        DragDropItemCenter<String>('second', 29),
      ];

      expect(
        dragDropInsertionIndexForCenters<String>(
          centers: centers,
          draggedItemId: 'first',
          comparisonY: 24,
        ),
        0,
      );
      expect(
        dragDropInsertionIndexForCenters<String>(
          centers: centers,
          draggedItemId: 'first',
          comparisonY: 30,
        ),
        1,
      );
    });

    test('keeps duplicate item content separate by item id', () {
      final List<DragDropItemCenter<String>> centers =
          dragDropFrozenItemCenters<String>(
        itemIds: <String>['plan_1', 'plan_2'],
        extentForItem: (_) => 20,
        separatorExtent: 0,
      );

      expect(
        centers.map((DragDropItemCenter<String> center) => center.itemId),
        <String>['plan_1', 'plan_2'],
      );
    });

    test('detects source-position drops as no-op', () {
      const DragDropPayload<String, String, String> payload =
          DragDropPayload<String, String, String>(
        item: 'Lemon Garlic Linguine',
        itemId: 'plan_1',
        sourceGroupId: 'today',
        sourceIndex: 1,
        itemExtent: 82,
      );

      expect(payload.isSourcePosition('today', 1), isTrue);
      expect(payload.isSourcePosition('today', 2), isFalse);
      expect(payload.isSourcePosition('tomorrow', 1), isFalse);
    });

    test('move payload reports source and target indexes', () {
      const DragDropMove<String, String, String> move =
          DragDropMove<String, String, String>(
        item: 'Miso Salmon Bowl',
        itemId: 'plan_2',
        fromGroupId: 'today',
        fromIndex: 0,
        toGroupId: 'tomorrow',
        toIndex: 2,
      );

      expect(move.itemId, 'plan_2');
      expect(move.fromGroupId, 'today');
      expect(move.fromIndex, 0);
      expect(move.toGroupId, 'tomorrow');
      expect(move.toIndex, 2);
    });
  });
}
