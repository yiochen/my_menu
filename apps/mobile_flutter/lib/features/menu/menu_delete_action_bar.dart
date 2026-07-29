part of 'menu_delete_dialog.dart';

class MenuDeleteActionBar extends StatelessWidget {
  const MenuDeleteActionBar({
    required this.selectedCount,
    required this.onDelete,
    super.key,
  });

  final int selectedCount;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const ValueKey<String>('menu_delete_action_bar'),
      color: Colors.white.withValues(alpha: 0.97),
      borderRadius: BorderRadius.circular(27),
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: 0.16),
      child: Container(
        constraints: const BoxConstraints(minHeight: 76),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: MyMenuColors.line),
          borderRadius: BorderRadius.circular(27),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '$selectedCount '
                    '${selectedCount == 1 ? 'item' : 'items'}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(
                    'Selection mode',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              key: const ValueKey<String>('menu_delete_selected'),
              onPressed: onDelete,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 48),
                backgroundColor: MyMenuColors.redSoft,
                foregroundColor: MyMenuColors.red,
                elevation: 0,
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.delete_outline_rounded, size: 19),
              label: Text('Delete $selectedCount'),
            ),
          ],
        ),
      ),
    );
  }
}
