import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/capture/capture_correction.dart';
import 'package:mymenu/domain/capture/captured_photo.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/dish_detail/dish_detail_screen.dart';
import 'package:mymenu/features/photos/photo_date_groups.dart';
import 'package:mymenu/features/photos/photo_detail_screen.dart';
import 'package:mymenu/features/photos/photo_gallery_tile.dart';
import 'package:mymenu/features/photos/photo_organize_dialogs.dart';
import 'package:mymenu/features/photos/photos_deletion_controller.dart';
import 'package:mymenu/features/photos/photos_selection_bar.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';

enum PhotoFilter { all, unorganized, organized }

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({
    required this.onBack,
    this.initialFilter = PhotoFilter.all,
    this.onSelectionModeChanged,
    super.key,
  });

  final VoidCallback onBack;
  final PhotoFilter initialFilter;
  final ValueChanged<bool>? onSelectionModeChanged;

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  late PhotoFilter _filter = widget.initialFilter;
  final Set<String> _selectedIds = <String>{};
  final PhotosDeletionController _deletions = PhotosDeletionController();
  bool _selectionMode = false;

  @override
  void dispose() {
    _deletions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);
    final List<CapturedPhoto> allPhotos = state.photos;
    final List<CapturedPhoto> visible = allPhotos.where((CapturedPhoto photo) {
      return switch (_filter) {
        PhotoFilter.all => true,
        PhotoFilter.unorganized => !photo.isOrganized,
        PhotoFilter.organized => photo.isOrganized,
      };
    }).toList(growable: false);
    _selectedIds.removeWhere(
      (String id) => !allPhotos.any((CapturedPhoto photo) => photo.id == id),
    );
    final Map<String, List<CapturedPhoto>> groups = groupPhotosByDate(visible);

    return PopScope<void>(
      onPopInvokedWithResult: (bool didPop, void result) {
        widget.onSelectionModeChanged?.call(false);
        if (!didPop) {
          widget.onBack();
        }
      },
      child: Scaffold(
        backgroundColor: MyMenuColors.cream,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              _header(allPhotos.length),
              _filters(state),
              const SizedBox(height: 8),
              Expanded(
                child: visible.isEmpty
                    ? _emptyState(state.photos.isEmpty)
                    : _gallery(state, groups),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _selectionMode && _selectedIds.isNotEmpty
            ? PhotoSelectionBar(
                count: _selectedIds.length,
                onAssign: () => _assignSelected(state),
                onCreate: () => _splitSelected(state),
                onDelete: () => _stageDeletion(state, _selectedIds.toSet()),
              )
            : null,
      ),
    );
  }

  Widget _header(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 14, 8),
      child: Row(
        children: <Widget>[
          IconButton(
            key: const ValueKey<String>('photos_back'),
            tooltip: 'Back',
            onPressed: () {
              widget.onSelectionModeChanged?.call(false);
              widget.onBack();
            },
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Photos',
                    style: Theme.of(context).textTheme.headlineMedium),
                Text('$count captured',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          TextButton(
            key: const ValueKey<String>('photos_select'),
            onPressed: () => setState(() {
              _selectionMode = !_selectionMode;
              if (!_selectionMode) _selectedIds.clear();
              widget.onSelectionModeChanged?.call(_selectionMode);
            }),
            child: Text(_selectionMode ? 'Done' : 'Select'),
          ),
        ],
      ),
    );
  }

  Widget _filters(MyMenuState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: SegmentedButton<PhotoFilter>(
        key: const ValueKey<String>('photo_filters'),
        showSelectedIcon: false,
        segments: <ButtonSegment<PhotoFilter>>[
          ButtonSegment<PhotoFilter>(
            value: PhotoFilter.all,
            label: Text('All ${state.photos.length}'),
          ),
          ButtonSegment<PhotoFilter>(
            value: PhotoFilter.unorganized,
            label: Text('Unorganized ${state.unorganizedPhotoCount}'),
          ),
          ButtonSegment<PhotoFilter>(
            value: PhotoFilter.organized,
            label: Text('Organized ${state.organizedPhotoCount}'),
          ),
        ],
        selected: <PhotoFilter>{_filter},
        onSelectionChanged: (Set<PhotoFilter> value) {
          setState(() => _filter = value.single);
        },
      ),
    );
  }

  Widget _gallery(
    MyMenuState state,
    Map<String, List<CapturedPhoto>> groups,
  ) {
    return CustomScrollView(
      key: const ValueKey<String>('photos_gallery'),
      slivers: <Widget>[
        for (final MapEntry<String, List<CapturedPhoto>> group
            in groups.entries)
          SliverMainAxisGroup(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 9),
                  child: Text(
                    photoDateLabel(group.key),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 7,
                    mainAxisSpacing: 7,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final CapturedPhoto photo = group.value[index];
                      return PhotoGalleryTile(
                        photo: photo,
                        selected: _selectedIds.contains(photo.id),
                        selectionMode: _selectionMode,
                        onTap: () => _handleTap(state, photo),
                        onLongPress: () => _toggleSelection(photo.id),
                      );
                    },
                    childCount: group.value.length,
                  ),
                ),
              ),
            ],
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 130)),
      ],
    );
  }

  Widget _emptyState(bool hasNoPhotos) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.photo_library_outlined,
                size: 54, color: MyMenuColors.orange),
            const SizedBox(height: 14),
            Text(
              hasNoPhotos
                  ? 'Your photos will live here'
                  : 'No photos in this view',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 7),
            Text(
              hasNoPhotos
                  ? 'Use the orange + button to take or import a photo. It appears here immediately.'
                  : 'Try another filter.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(MyMenuState state, CapturedPhoto photo) {
    if (_selectionMode) {
      _toggleSelection(photo.id);
      return;
    }
    unawaited(_openDetail(state, photo));
  }

  void _toggleSelection(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectionMode = true;
      if (!_selectedIds.add(id)) _selectedIds.remove(id);
      if (_selectedIds.isEmpty) _selectionMode = false;
    });
    widget.onSelectionModeChanged?.call(_selectionMode);
  }

  Future<void> _openDetail(MyMenuState state, CapturedPhoto photo) async {
    final List<CapturedPhoto> batchSiblings = state.photos
        .where(
          (CapturedPhoto sibling) =>
              sibling.batchId == photo.batchId &&
              sibling.id != photo.id &&
              !sibling.isOrganized,
        )
        .toList(growable: false);
    final CaptureCorrection? latest =
        state.latestCaptureCorrectionForPhoto(photo.id);
    final PhotoDetailIntent? intent =
        await Navigator.of(context).push<PhotoDetailIntent>(
      MaterialPageRoute<PhotoDetailIntent>(
        builder: (_) => PhotoDetailScreen(
          photo: photo,
          dishes: state.dishes,
          batchSiblingCount: batchSiblings.length,
          canUndo: latest?.canUndo ?? false,
        ),
      ),
    );
    if (!mounted || intent == null) return;
    final Set<String> ids = <String>{
      photo.id,
      if (intent.includeBatch) ...batchSiblings.map((photo) => photo.id),
    };
    switch (intent.action) {
      case PhotoDetailAction.assign:
        await state.organizePhotos(captureIds: ids, dishId: intent.dishId!);
        if (!mounted) return;
        showPhotoUndoSnackBar(
          context,
          state,
          photo.batchId,
          'Photo organized',
        );
      case PhotoDetailAction.createDish:
        await state.organizePhotosIntoNewDish(
          captureIds: ids,
          title: intent.title!,
        );
        if (!mounted) return;
        showPhotoUndoSnackBar(
          context,
          state,
          photo.batchId,
          'Dish created from photo',
        );
      case PhotoDetailAction.delete:
        await _stageDeletion(state, <String>{photo.id});
      case PhotoDetailAction.dismiss:
        await state.dismissPhotoSuggestion(photo.id);
      case PhotoDetailAction.retry:
        if (photo.batchId != null) {
          await state.retryCaptureBatch(photo.batchId!);
        }
      case PhotoDetailAction.undo:
        if (photo.batchId != null) {
          await state.undoLatestCaptureCorrection(
            photo.batchId!,
            captureId: photo.id,
          );
        }
      case PhotoDetailAction.viewDish:
        if (intent.dishId != null && mounted) {
          await Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => DishDetailScreen(dishId: intent.dishId!),
            ),
          );
        }
    }
  }

  Future<void> _assignSelected(MyMenuState state) async {
    final result = await showPhotoDishPicker(context, dishes: state.dishes);
    if (result == null) return;
    final List<CaptureCorrection> corrections = await state.organizePhotos(
      captureIds: _selectedIds,
      dishId: result.dishId,
    );
    if (mounted) {
      setState(_clearSelection);
      showPhotoBulkUndoSnackBar(
          context, state, corrections, 'Photos organized');
    }
  }

  Future<void> _splitSelected(MyMenuState state) async {
    final List<CapturedPhoto> selected = state.photos
        .where((CapturedPhoto photo) => _selectedIds.contains(photo.id))
        .toList(growable: false);
    final Map<String, String>? assignments = await showPhotoSplitDialog(
      context,
      photos: selected,
      dishes: state.dishes,
    );
    if (assignments == null) return;
    final List<CaptureCorrection> corrections =
        await state.organizePhotoAssignments(assignments);
    if (mounted) {
      setState(_clearSelection);
      showPhotoBulkUndoSnackBar(
        context,
        state,
        corrections,
        'Photos split across dishes',
      );
    }
  }

  Future<void> _stageDeletion(MyMenuState state, Set<String> ids) async {
    setState(_clearSelection);
    _deletions.stage(context, state, ids);
  }

  void _clearSelection() {
    _selectedIds.clear();
    _selectionMode = false;
    widget.onSelectionModeChanged?.call(false);
  }
}
