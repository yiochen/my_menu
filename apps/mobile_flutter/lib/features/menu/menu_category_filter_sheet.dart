import 'package:flutter/material.dart';

import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

Future<String?> showMenuCategoryFilterSheet(
  BuildContext context, {
  required String? selectedCategory,
}) {
  return showModalBottomSheet<String?>(
    context: context,
    useSafeArea: true,
    builder: (BuildContext context) {
      return WarmPage(
        includeBottomChromeSpace: false,
        topPadding: 10,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SheetTopBar(
              title: 'Filter dishes',
              onClose: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            for (final String category in <String>[
              'Bowls',
              'Pasta',
              'Mains',
              'Soups',
            ])
              ListTile(
                title: Text(category),
                trailing: selectedCategory == category
                    ? const Icon(Icons.check, color: MyMenuColors.orangeDark)
                    : null,
                onTap: () => Navigator.pop(context, category),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context, ''),
              child: const Text('Clear filters'),
            ),
          ],
        ),
      );
    },
  );
}
