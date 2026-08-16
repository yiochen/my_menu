import 'package:flutter/material.dart';

import 'package:mymenu/app/app.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/menu/my_menu_state.dart';
import 'package:mymenu/features/improve_cover/improve_cover_dialog.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/dish_artwork.dart';
import 'package:mymenu/shared/widgets/local_write_feedback.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

class DishDetailHero extends StatefulWidget {
  const DishDetailHero({required this.dish, super.key});

  final Dish dish;

  @override
  State<DishDetailHero> createState() => _DishDetailHeroState();
}

class _DishDetailHeroState extends State<DishDetailHero> {
  late final TextEditingController _titleController = TextEditingController(
    text: widget.dish.title,
  );
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.dish.description);
  bool _editing = false;
  bool _saving = false;

  Dish get dish => widget.dish;
  bool get _canSave => !_saving && _titleController.text.trim().isNotEmpty;

  @override
  void didUpdateWidget(covariant DishDetailHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing || oldWidget.dish.id != dish.id) {
      _resetControllers();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).width <= 380 ? 300 : 330;
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Hero(
              key: ValueKey<String>('dish_detail_artwork_hero_${dish.id}'),
              tag: dishArtworkHeroTag(dish.id),
              child: DishArtwork(dish: dish),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Colors.transparent, Color(0x991A130D)],
                  stops: <double>[0.45, 1],
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              top: 12,
              child: _HeroActions(
                dish: dish,
                editing: _editing,
                saving: _saving,
                canSave: _canSave,
                onEdit: _startEditing,
                onCancel: _cancelEditing,
                onSave: _save,
              ),
            ),
            Positioned(
              right: 12,
              top: 70,
              child: WarmPill(
                key: const ValueKey<String>('cover_image_button'),
                label: 'Cover image',
                icon: Icons.photo_library_outlined,
                compact: true,
                onPressed: () => showImproveCoverDialog(
                  context,
                  MyMenuScope.read(context),
                  dish.id,
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: _HeroCaption(
                dish: dish,
                editing: _editing,
                titleController: _titleController,
                descriptionController: _descriptionController,
                onChanged: () => setState(() {}),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startEditing() {
    _resetControllers();
    setState(() => _editing = true);
  }

  void _cancelEditing() {
    FocusManager.instance.primaryFocus?.unfocus();
    _resetControllers();
    setState(() => _editing = false);
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    final bool saved = await runLocalWriteWithFeedback(
      context,
      () => MyMenuScope.read(context).updateDishDetails(
        dish.id,
        title: _titleController.text,
        description: _descriptionController.text,
      ),
    );
    if (!mounted) return;
    if (saved) FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _saving = false;
      if (saved) _editing = false;
    });
  }

  void _resetControllers() {
    _titleController.text = dish.title;
    _descriptionController.text = dish.description;
  }
}

class _HeroActions extends StatelessWidget {
  const _HeroActions({
    required this.dish,
    required this.editing,
    required this.saving,
    required this.canSave,
    required this.onEdit,
    required this.onCancel,
    required this.onSave,
  });

  final Dish dish;
  final bool editing;
  final bool saving;
  final bool canSave;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          size: 40,
          radius: 14,
          semanticLabel: 'Back',
          onPressed: () => Navigator.pop(context),
        ),
        const Spacer(),
        CircleIconButton(
          icon: dish.isFavorite ? Icons.favorite : Icons.favorite_border,
          size: 40,
          radius: 14,
          semanticLabel: 'Favorite',
          onPressed: () => runLocalWriteWithFeedback(
            context,
            () => MyMenuScope.read(context).toggleFavorite(dish.id),
          ),
        ),
        const SizedBox(width: 8),
        if (editing) ...<Widget>[
          _HeroEditAction(
            key: const ValueKey<String>('dish_edit_cancel'),
            label: 'Cancel',
            onPressed: saving ? null : onCancel,
          ),
          const SizedBox(width: 6),
          _HeroEditAction(
            key: const ValueKey<String>('dish_edit_save'),
            label: saving ? 'Saving…' : 'Save',
            emphasized: true,
            onPressed: canSave ? onSave : null,
          ),
        ] else
          CircleIconButton(
            key: const ValueKey<String>('dish_edit_button'),
            icon: Icons.edit_outlined,
            size: 40,
            radius: 14,
            semanticLabel: 'Edit dish details',
            onPressed: onEdit,
          ),
      ],
    );
  }
}

class _HeroEditAction extends StatelessWidget {
  const _HeroEditAction({
    required this.label,
    required this.onPressed,
    this.emphasized = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 11),
          foregroundColor: emphasized ? Colors.white : MyMenuColors.ink,
          backgroundColor:
              emphasized ? MyMenuColors.orangeAction : const Color(0xF2FFFFFF),
          disabledForegroundColor: MyMenuColors.softInk,
          disabledBackgroundColor:
              emphasized ? const Color(0xF2EEE8DF) : const Color(0xD9FFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(label),
      );
}

class _HeroCaption extends StatelessWidget {
  const _HeroCaption({
    required this.dish,
    required this.editing,
    required this.titleController,
    required this.descriptionController,
    required this.onChanged,
  });

  final Dish dish;
  final bool editing;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    if (editing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            key: const ValueKey<String>('dish_title_field'),
            controller: titleController,
            autofocus: true,
            maxLength: 120,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            onChanged: (_) => onChanged(),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontSize: 27,
                ),
            decoration: _editDecoration('Dish title'),
          ),
          const SizedBox(height: 6),
          TextField(
            key: const ValueKey<String>('dish_description_field'),
            controller: descriptionController,
            maxLength: 300,
            minLines: 1,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onChanged: (_) => onChanged(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
            decoration: _editDecoration('Description (optional)'),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          dish.title,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontSize: 31,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          dish.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
        ),
      ],
    );
  }
}

InputDecoration _editDecoration(String hint) => InputDecoration(
      isDense: true,
      filled: true,
      fillColor: const Color(0x521A130D),
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xCCFFFFFF)),
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xB3FFFFFF)),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 2),
      ),
    );
