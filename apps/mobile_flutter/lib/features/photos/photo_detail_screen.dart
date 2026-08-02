import 'package:flutter/material.dart';
import 'package:mymenu/domain/capture/captured_photo.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/features/photos/photo_organize_dialogs.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/app_image.dart';

enum PhotoDetailAction {
  assign,
  createDish,
  delete,
  dismiss,
  retry,
  undo,
  viewDish
}

class PhotoDetailIntent {
  const PhotoDetailIntent(
    this.action, {
    this.dishId,
    this.title,
    this.includeBatch = false,
  });

  final PhotoDetailAction action;
  final String? dishId;
  final String? title;
  final bool includeBatch;
}

class PhotoDetailScreen extends StatelessWidget {
  const PhotoDetailScreen({
    required this.photo,
    required this.dishes,
    required this.batchSiblingCount,
    required this.canUndo,
    super.key,
  });

  final CapturedPhoto photo;
  final List<Dish> dishes;
  final int batchSiblingCount;
  final bool canUndo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171411),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(photo.overlayLabel),
        actions: <Widget>[
          IconButton(
            key: const ValueKey<String>('photo_delete'),
            tooltip: 'Delete photo',
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Hero(
                tag: 'captured_photo_${photo.id}',
                child: AppImage(
                  imageRef: photo.imageRef,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            decoration: const BoxDecoration(
              color: MyMenuColors.cream,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _StatusSummary(photo: photo),
                const SizedBox(height: 14),
                if (photo.isOrganized) ...<Widget>[
                  FilledButton.icon(
                    key: const ValueKey<String>('photo_view_dish'),
                    onPressed: () => Navigator.pop(
                      context,
                      PhotoDetailIntent(
                        PhotoDetailAction.viewDish,
                        dishId: photo.item.appliedDishId,
                      ),
                    ),
                    icon: const Icon(Icons.restaurant_menu_rounded),
                    label: Text('View ${photo.dish?.title ?? 'dish'}'),
                  ),
                  OutlinedButton(
                    key: const ValueKey<String>('photo_change_dish'),
                    onPressed: () => _chooseDish(context),
                    child: const Text('Change dish'),
                  ),
                  if (canUndo)
                    TextButton(
                      key: const ValueKey<String>('photo_undo_organization'),
                      onPressed: () => Navigator.pop(
                        context,
                        const PhotoDetailIntent(PhotoDetailAction.undo),
                      ),
                      child: const Text('Undo last organization'),
                    ),
                ] else ...<Widget>[
                  FilledButton.icon(
                    key: const ValueKey<String>('photo_add_to_dish'),
                    onPressed: () => _chooseDish(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add to a dish'),
                  ),
                  OutlinedButton.icon(
                    key: const ValueKey<String>('photo_create_dish'),
                    onPressed: () => _createDish(context),
                    icon: const Icon(Icons.restaurant_rounded),
                    label: const Text('Create a new dish'),
                  ),
                ],
                if (photo.state == CapturedPhotoState.review)
                  TextButton(
                    key: const ValueKey<String>('photo_dismiss_suggestion'),
                    onPressed: () => Navigator.pop(
                      context,
                      const PhotoDetailIntent(PhotoDetailAction.dismiss),
                    ),
                    child: const Text('Dismiss suggestion'),
                  ),
                if (photo.state == CapturedPhotoState.failed)
                  TextButton.icon(
                    key: const ValueKey<String>('photo_retry'),
                    onPressed: () => Navigator.pop(
                      context,
                      const PhotoDetailIntent(PhotoDetailAction.retry),
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try organizing again'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _chooseDish(BuildContext context) async {
    final result = await showPhotoDishPicker(
      context,
      dishes: dishes,
      batchSiblingCount: batchSiblingCount,
    );
    if (result != null && context.mounted) {
      Navigator.pop(
        context,
        PhotoDetailIntent(
          PhotoDetailAction.assign,
          dishId: result.dishId,
          includeBatch: result.includeBatch,
        ),
      );
    }
  }

  Future<void> _createDish(BuildContext context) async {
    final String? title = await showNewPhotoDishDialog(context);
    if (title != null && context.mounted) {
      Navigator.pop(
        context,
        PhotoDetailIntent(PhotoDetailAction.createDish, title: title),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete this photo?'),
        content: Text(photo.isOrganized
            ? 'The dish will stay in your menu.'
            : 'This removes the photo from MyMenu.'),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if ((confirmed ?? false) && context.mounted) {
      Navigator.pop(
        context,
        const PhotoDetailIntent(PhotoDetailAction.delete),
      );
    }
  }
}

class _StatusSummary extends StatelessWidget {
  const _StatusSummary({required this.photo});

  final CapturedPhoto photo;

  @override
  Widget build(BuildContext context) {
    final String description = switch (photo.state) {
      CapturedPhotoState.review => photo.reviewItem?.summary ??
          'MyMenu needs your help placing this photo.',
      CapturedPhotoState.failed =>
        'The photo is safe here. You can organize it yourself or try again.',
      CapturedPhotoState.organizing =>
        'Ready to use now. MyMenu is quietly looking for the right dish.',
      CapturedPhotoState.unorganized =>
        'This photo is ready whenever you want to place it in a dish.',
      CapturedPhotoState.organized =>
        'Organized in ${photo.dish?.title ?? 'a dish'}.',
    };
    return Semantics(
      label: photo.semanticsLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(photo.overlayLabel,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
