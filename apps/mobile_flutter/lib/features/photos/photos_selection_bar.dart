import 'package:flutter/material.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';

class PhotoSelectionBar extends StatelessWidget {
  const PhotoSelectionBar({
    required this.count,
    required this.onAssign,
    required this.onCreate,
    required this.onDelete,
    super.key,
  });

  final int count;
  final VoidCallback onAssign;
  final VoidCallback onCreate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        elevation: 10,
        color: MyMenuColors.ink,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('$count selected',
                    style: const TextStyle(color: Colors.white)),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Add selected photos to a dish',
                onPressed: onAssign,
                color: Colors.white,
                icon: const Icon(Icons.restaurant_menu_rounded),
              ),
              IconButton(
                tooltip: 'Split selected photos into a new dish',
                onPressed: onCreate,
                color: Colors.white,
                icon: const Icon(Icons.call_split_rounded),
              ),
              IconButton(
                tooltip: 'Delete selected photos',
                onPressed: onDelete,
                color: Colors.white,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
