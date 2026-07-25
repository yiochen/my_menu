import 'package:flutter/material.dart';

import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/dish_artwork.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

class ImproveCoverSelection extends StatefulWidget {
  const ImproveCoverSelection({
    required this.dish,
    required this.selectedSources,
    required this.initialDirection,
    required this.onDirectionChanged,
    required this.onToggleSource,
    required this.onGenerate,
    required this.onClose,
    super.key,
  });

  final Dish dish;
  final Set<int> selectedSources;
  final String initialDirection;
  final ValueChanged<String> onDirectionChanged;
  final ValueChanged<int> onToggleSource;
  final VoidCallback onGenerate;
  final VoidCallback onClose;

  @override
  State<ImproveCoverSelection> createState() => _ImproveCoverSelectionState();
}

class _ImproveCoverSelectionState extends State<ImproveCoverSelection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialDirection);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.97,
      child: WarmPage(
        includeBottomChromeSpace: false,
        topPadding: 10,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SheetTopBar(
              title: 'Improve cover image',
              closeOnLeft: true,
              onClose: widget.onClose,
            ),
            const SizedBox(height: 12),
            const Eyebrow('Make it menu-worthy'),
            Text(
              'Choose source photos',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 7),
            Text(
              'MyMenu uses the real moments you select to create a new cover '
              'image. Your originals never change.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            _CurrentCover(dish: widget.dish),
            const SizedBox(height: 16),
            Text(
              'How should the cover feel?  Optional',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 7),
            TextField(
              controller: _controller,
              onChanged: widget.onDirectionChanged,
              minLines: 3,
              maxLines: 3,
            ),
            const SizedBox(height: 6),
            Text(
              'Describe plating, lighting, mood, or anything you want emphasized.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Your source photos',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        '${widget.selectedSources.length} of '
                        '${widget.dish.sourcePhotos.length} selected',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('Choose from ${widget.dish.sourcePhotos.length}'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _SourcePicker(
              dish: widget.dish,
              selectedSources: widget.selectedSources,
              onToggle: widget.onToggleSource,
            ),
            const SizedBox(height: 12),
            const StatusStrip(
              icon: Icons.auto_awesome,
              text: 'The result can be aspirational; sources stay documentary.',
            ),
            const SizedBox(height: 14),
            PrimaryPillButton(
              label: 'Generate new cover',
              icon: Icons.arrow_forward,
              onPressed:
                  widget.selectedSources.isEmpty ? null : widget.onGenerate,
            ),
          ],
        ),
      ),
    );
  }
}

class _SourcePicker extends StatelessWidget {
  const _SourcePicker({
    required this.dish,
    required this.selectedSources,
    required this.onToggle,
  });

  final Dish dish;
  final Set<int> selectedSources;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(
        3,
        (int index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == 2 ? 0 : 9),
            child: _SourceChoice(
              dish: dish,
              selected: selectedSources.contains(index),
              onTap: () => onToggle(index),
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrentCover extends StatelessWidget {
  const _CurrentCover({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    return WarmCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: SizedBox(
              width: 76,
              height: 76,
              child: DishArtwork(dish: dish),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('CURRENT COVER',
                    style: Theme.of(context).textTheme.labelSmall),
                Text(dish.title,
                    style: Theme.of(context).textTheme.titleMedium),
                Text(
                  'Safe until you choose a replacement',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.check, color: MyMenuColors.green),
        ],
      ),
    );
  }
}

class _SourceChoice extends StatelessWidget {
  const _SourceChoice({
    required this.dish,
    required this.selected,
    required this.onTap,
  });

  final Dish dish;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.9,
      child: Material(
        clipBehavior: Clip.antiAlias,
        color: MyMenuColors.oat,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: selected ? MyMenuColors.orange : Colors.transparent,
            width: 3,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              DishArtwork(dish: dish),
              if (selected)
                const Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 11,
                    backgroundColor: MyMenuColors.orange,
                    child: Icon(Icons.check, size: 14, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
