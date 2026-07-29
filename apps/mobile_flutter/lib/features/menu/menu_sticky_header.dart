import 'package:flutter/material.dart';

import 'package:mymenu/shared/theme/my_menu_theme.dart';

class MenuStickyHeader extends StatelessWidget {
  const MenuStickyHeader({
    required this.controller,
    required this.query,
    required this.onQueryChanged,
    required this.onClearQuery,
    required this.selectedCount,
    required this.allSelected,
    required this.onCloseSelection,
    required this.onSelectAll,
    super.key,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final int selectedCount;
  final bool allSelected;
  final VoidCallback onCloseSelection;
  final VoidCallback onSelectAll;

  bool get _isSelecting => selectedCount > 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: _isSelecting
          ? _SelectionHeader(
              key: const ValueKey<String>('menu_selection_header'),
              selectedCount: selectedCount,
              allSelected: allSelected,
              onClose: onCloseSelection,
              onSelectAll: onSelectAll,
            )
          : _SearchHeader(
              key: const ValueKey<String>('menu_compact_search_header'),
              controller: controller,
              query: query,
              onQueryChanged: onQueryChanged,
              onClear: onClearQuery,
            ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    required this.query,
    required this.onQueryChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MyMenuColors.oat,
      borderRadius: BorderRadius.circular(23),
      child: SizedBox(
        height: 46,
        child: TextField(
          key: const ValueKey<String>('menu_search_field'),
          controller: controller,
          onChanged: onQueryChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search dishes, notes, ingredients',
            prefixIcon: const Icon(Icons.search_rounded, size: 22),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}

class _SelectionHeader extends StatelessWidget {
  const _SelectionHeader({
    required this.selectedCount,
    required this.allSelected,
    required this.onClose,
    required this.onSelectAll,
    super.key,
  });

  final int selectedCount;
  final bool allSelected;
  final VoidCallback onClose;
  final VoidCallback onSelectAll;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MyMenuColors.oat,
      borderRadius: BorderRadius.circular(23),
      child: SizedBox(
        height: 46,
        child: Row(
          children: <Widget>[
            IconButton(
              key: const ValueKey<String>('menu_selection_close'),
              tooltip: 'Exit selection',
              onPressed: onClose,
              color: MyMenuColors.ink,
              icon: const Icon(Icons.close_rounded, size: 21),
            ),
            Expanded(
              child: Text(
                '$selectedCount selected',
                key: const ValueKey<String>('menu_selected_count'),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: MyMenuColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            TextButton(
              key: const ValueKey<String>('menu_select_all'),
              onPressed: onSelectAll,
              style: TextButton.styleFrom(
                foregroundColor: MyMenuColors.ink,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(allSelected ? 'Clear all' : 'Select all'),
            ),
          ],
        ),
      ),
    );
  }
}
