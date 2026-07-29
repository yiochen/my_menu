import 'package:flutter/material.dart';

import 'package:mymenu/domain/capture/capture_batch.dart';
import 'package:mymenu/domain/capture/capture_item.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/app_image.dart';

class MenuProcessingDishCard extends StatefulWidget {
  const MenuProcessingDishCard({
    required this.batch,
    required this.onTap,
    this.selected = false,
    this.selectionMode = false,
    this.onLongPress,
    super.key,
  });

  final CaptureBatch batch;
  final VoidCallback onTap;
  final bool selected;
  final bool selectionMode;
  final VoidCallback? onLongPress;

  @override
  State<MenuProcessingDishCard> createState() => _MenuProcessingDishCardState();
}

class _MenuProcessingDishCardState extends State<MenuProcessingDishCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? imageRef = widget.batch.items
        .map((CaptureItem item) => item.localMediaRef ?? item.remoteMediaRef)
        .whereType<String>()
        .firstOrNull;
    return Container(
      key: ValueKey<String>('processing_dish_${widget.batch.id}'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: widget.selected
            ? const <BoxShadow>[
                BoxShadow(
                  color: Color(0x24C94B00),
                  blurRadius: 26,
                  offset: Offset(0, 10),
                ),
              ]
            : myMenuCardShadow,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.selected
              ? MyMenuColors.orangeAction
              : MyMenuColors.orangeSoft,
          width: widget.selected ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _artwork(imageRef),
              _details(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _artwork(String? imageRef) {
    return Expanded(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (imageRef != null)
            Opacity(
              opacity: 0.42,
              child: AppImage(imageRef: imageRef, fit: BoxFit.cover),
            )
          else
            const ColoredBox(color: MyMenuColors.oat),
          ColoredBox(color: MyMenuColors.orangeSoft.withAlpha(80)),
          Center(
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.45, end: 1).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
              ),
              child: Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xEFFFFFFF),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: MyMenuColors.orangeDark,
                ),
              ),
            ),
          ),
          if (widget.selectionMode)
            Positioned(
              top: 10,
              right: 10,
              child: _ProcessingSelectionIndicator(
                selected: widget.selected,
              ),
            ),
          const Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: LinearProgressIndicator(
              minHeight: 5,
              borderRadius: BorderRadius.all(Radius.circular(99)),
              color: MyMenuColors.orange,
              backgroundColor: Color(0xCFFFFFFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _details(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 3),
          Text(
            _status,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 7),
          const Row(
            children: <Widget>[
              Icon(
                Icons.open_in_new_rounded,
                size: 11,
                color: MyMenuColors.orangeDark,
              ),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Tap for processing status',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: MyMenuColors.orangeDark,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _title {
    final int count = widget.batch.items.length;
    return count == 1 ? 'Organizing photo' : 'Organizing $count photos';
  }

  String get _status => switch (widget.batch.status) {
        CaptureBatchStatus.local ||
        CaptureBatchStatus.pendingUpload ||
        CaptureBatchStatus.uploading =>
          'Uploading · creating your dish',
        CaptureBatchStatus.readyForAi ||
        CaptureBatchStatus.processing =>
          'AI is creating your dish',
        CaptureBatchStatus.failed => 'Needs attention',
        CaptureBatchStatus.applied || CaptureBatchStatus.discarded => '',
      };
}

class _ProcessingSelectionIndicator extends StatelessWidget {
  const _ProcessingSelectionIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? MyMenuColors.orangeAction : const Color(0xEFFFFFFF),
        border: Border.all(
          color: selected ? Colors.white : MyMenuColors.softInk,
          width: 2,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
          : null,
    );
  }
}
