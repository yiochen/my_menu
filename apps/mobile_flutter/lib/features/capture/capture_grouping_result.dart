import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/domain/capture/capture_correction.dart';
import 'package:mymenu/domain/capture/capture_item.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/capture/capture_grouping_destination_sheets.dart';
import 'package:mymenu/shared/drag_drop/drag_drop_board.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/app_image.dart';
import 'package:mymenu/shared/widgets/food_cover_placeholder.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

part 'capture_grouping_result_widgets.dart';
part 'capture_grouping_result_groups.dart';
part 'capture_grouping_unclassified.dart';
part 'capture_grouping_result_actions.dart';

typedef _CaptureDragPayload
    = MultiSelectDragDropPayload<String, String, CaptureItem>;

class CaptureGroupingResultView extends StatefulWidget {
  const CaptureGroupingResultView({
    required this.state,
    required this.batchId,
    required this.onClose,
    super.key,
  });

  final MyMenuState state;
  final String batchId;
  final VoidCallback onClose;

  @override
  State<CaptureGroupingResultView> createState() =>
      _CaptureGroupingResultViewState();
}

class _CaptureGroupingResultViewState extends State<CaptureGroupingResultView> {
  final Set<String> _selectedIds = <String>{};
  bool _isCorrecting = false;

  @override
  Widget build(BuildContext context) {
    final CaptureBatch? batch = widget.state.captureBatches
        .where((CaptureBatch item) => item.id == widget.batchId)
        .firstOrNull;
    if (batch == null) {
      return const SizedBox.shrink();
    }
    final List<CaptureItem> activeItems = batch.items
        .where(
          (CaptureItem item) =>
              item.status == CaptureItemStatus.applied &&
              item.appliedDishId != null,
        )
        .toList(growable: false)
      ..sort(
        (CaptureItem left, CaptureItem right) =>
            left.ordinal.compareTo(right.ordinal),
      );
    final List<CaptureItem> unclassifiedItems = batch.items
        .where(
          (CaptureItem item) =>
              item.status == CaptureItemStatus.discarded &&
              item.appliedDishId == null,
        )
        .toList(growable: false)
      ..sort(
        (CaptureItem left, CaptureItem right) =>
            left.ordinal.compareTo(right.ordinal),
      );
    final Map<String, List<CaptureItem>> groups = _groupItems(activeItems);
    final CaptureCorrection? latest =
        widget.state.latestCaptureCorrection(widget.batchId);

    return _isCorrecting
        ? _buildCorrection(activeItems, groups)
        : _buildOutcome(activeItems, unclassifiedItems, groups, latest);
  }

  Widget _buildOutcome(
    List<CaptureItem> activeItems,
    List<CaptureItem> unclassifiedItems,
    Map<String, List<CaptureItem>> groups,
    CaptureCorrection? latest,
  ) {
    return WarmPage(
      includeBottomChromeSpace: false,
      topPadding: 10,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SheetTopBar(title: 'Capture organized', onClose: widget.onClose),
          const SizedBox(height: 12),
          _OutcomeHeading(
            photoCount: activeItems.length,
            dishCount: groups.length,
            unclassifiedCount: unclassifiedItems.length,
          ),
          const SizedBox(height: 14),
          for (final MapEntry<String, List<CaptureItem>> entry
              in groups.entries) ...<Widget>[
            _OutcomeDishGroup(
              dish: _dish(entry.key),
              items: entry.value,
            ),
            const SizedBox(height: 10),
          ],
          if (unclassifiedItems.isNotEmpty) ...<Widget>[
            _UnclassifiedSection(
              items: unclassifiedItems,
              onAssign: _assignUnclassified,
              onDelete: _confirmDeleteUnclassified,
            ),
            const SizedBox(height: 14),
          ],
          if (activeItems.isNotEmpty)
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton(
                    key: const ValueKey<String>('correct_capture_grouping'),
                    onPressed: () => setState(() => _isCorrecting = true),
                    child: const Text('Correct grouping'),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  key: const ValueKey<String>('undo_capture_grouping'),
                  onPressed: latest?.canUndo ?? false ? _undo : null,
                  child: const Text('Undo'),
                ),
              ],
            ),
          if (latest != null) ...<Widget>[
            const SizedBox(height: 12),
            _CorrectionStatus(
              correction: latest,
              onUndo: null,
            ),
          ],
          const SizedBox(height: 14),
          Text(
            unclassifiedItems.isEmpty
                ? 'Every original is preserved. Check the groups or correct '
                    'anything that looks wrong.'
                : 'Unclassified photos stay separate unless you assign or '
                    'delete them.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildCorrection(
    List<CaptureItem> activeItems,
    Map<String, List<CaptureItem>> groups,
  ) {
    return WarmPage(
      includeBottomChromeSpace: false,
      topPadding: 10,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _CorrectionTopBar(onBack: _leaveCorrection),
          const SizedBox(height: 12),
          _CorrectionHeading(selectedCount: _selectedIds.length),
          const SizedBox(height: 14),
          for (final MapEntry<String, List<CaptureItem>> entry
              in groups.entries) ...<Widget>[
            _DishDropGroup(
              dish: _dish(entry.key),
              items: entry.value,
              selectedIds: _selectedIds,
              allSelectedItems: _selectedItems(activeItems),
              onToggleSelected: _toggleSelected,
              onDrop: (List<String> ids) => _move(ids, entry.key),
              onTapDestination: _selectedIds.isEmpty
                  ? null
                  : () => _move(_selectedIds.toList(), entry.key),
            ),
            const SizedBox(height: 10),
          ],
          if (_selectedIds.isNotEmpty) ...<Widget>[
            _SelectionSummary(
              selectedCount: _selectedIds.length,
              onClear: () => setState(_selectedIds.clear),
            ),
            const SizedBox(height: 10),
          ],
          _DestinationDropZone(
            key: const ValueKey<String>('move_to_menu_drop_zone'),
            icon: Icons.search_rounded,
            title: 'Another dish in your Menu',
            subtitle: 'Search all existing dishes',
            onTap: () => _openDishSearch(_selectedOrAll(activeItems)),
            onDrop: _openDishSearch,
          ),
          const SizedBox(height: 10),
          _DestinationDropZone(
            key: const ValueKey<String>('make_new_dish_drop_zone'),
            icon: Icons.add_rounded,
            title: 'Make a new dish',
            subtitle: 'Start one history with the selected photos',
            onTap: () => _makeNewDish(_selectedOrAll(activeItems)),
            onDrop: _makeNewDish,
          ),
          const SizedBox(height: 14),
          Text(
            'Original photos never change. Tap a photo to select more than '
            'one, then drag them together. You can also tap a destination.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _leaveCorrection() {
    setState(() {
      _selectedIds.clear();
      _isCorrecting = false;
    });
  }

  Map<String, List<CaptureItem>> _groupItems(List<CaptureItem> items) {
    final Map<String, List<CaptureItem>> groups = <String, List<CaptureItem>>{};
    for (final CaptureItem item in items) {
      groups.putIfAbsent(item.appliedDishId!, () => <CaptureItem>[]).add(item);
    }
    return groups;
  }

  Dish _dish(String dishId) {
    return widget.state.dishes.firstWhere((Dish dish) => dish.id == dishId);
  }

  List<CaptureItem> _selectedItems(List<CaptureItem> allItems) {
    return allItems
        .where((CaptureItem item) => _selectedIds.contains(item.id))
        .toList(growable: false);
  }

  List<String> _selectedOrAll(List<CaptureItem> activeItems) {
    if (_selectedIds.isNotEmpty) {
      return _selectedIds.toList(growable: false);
    }
    return activeItems.map((CaptureItem item) => item.id).toList();
  }

  void _toggleSelected(String captureId) {
    setState(() {
      if (!_selectedIds.add(captureId)) {
        _selectedIds.remove(captureId);
      }
    });
  }

  Future<void> _move(List<String> captureIds, String targetDishId) async {
    if (captureIds.isEmpty) {
      return;
    }
    await widget.state.moveCapturePhotos(
      batchId: widget.batchId,
      captureIds: captureIds,
      targetDishId: targetDishId,
    );
    if (mounted) {
      setState(() {
        _selectedIds.clear();
        _isCorrecting = false;
      });
    }
  }

  Future<void> _openDishSearch(List<String> captureIds) async {
    if (captureIds.isEmpty) {
      return;
    }
    final Set<String> groupedDishIds = widget.state.captureBatches
        .where((CaptureBatch item) => item.id == widget.batchId)
        .expand((CaptureBatch item) => item.items)
        .map((CaptureItem item) => item.appliedDishId)
        .whereType<String>()
        .toSet();
    final String? targetDishId = await showCaptureDishSearchSheet(
      context,
      state: widget.state,
      excludedDishIds: groupedDishIds,
      selectedCount: captureIds.length,
    );
    if (targetDishId != null) {
      await _move(captureIds, targetDishId);
    }
  }

  Future<void> _makeNewDish(List<String> captureIds) async {
    if (captureIds.isEmpty) {
      return;
    }
    final String? title = await showCaptureNewDishDialog(
      context,
      selectedCount: captureIds.length,
    );
    if (title == null) {
      return;
    }
    await widget.state.splitCapturePhotos(
      batchId: widget.batchId,
      captureIds: captureIds,
      title: title,
    );
    if (mounted) {
      setState(() {
        _selectedIds.clear();
        _isCorrecting = false;
      });
    }
  }

  Future<void> _undo() async {
    await widget.state.undoLatestCaptureCorrection(widget.batchId);
    if (mounted) {
      setState(() {
        _selectedIds.clear();
        _isCorrecting = false;
      });
    }
  }

  void _refreshUnclassifiedResult() {
    if (mounted) {
      setState(() {});
    }
  }
}

typedef _CaptureDragPayloadDetails = DragTargetDetails<_CaptureDragPayload>;
