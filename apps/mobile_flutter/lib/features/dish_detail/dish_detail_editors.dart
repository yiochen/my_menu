part of 'dish_detail_screen.dart';

Future<void> _showNoteEditor(
  BuildContext context, {
  required String dishId,
  DishNote? note,
}) async {
  final MyMenuState state = MyMenuScope.of(context);
  final TextEditingController controller = TextEditingController(
    text: note?.body ?? '',
  );

  await showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AppDialog(
        title: note == null ? 'Add Note' : 'Edit Note',
        subtitle: 'Capture the little thing you want to remember next time.',
        icon: Icons.sticky_note_2_outlined,
        content: TextField(
          controller: controller,
          minLines: 4,
          maxLines: 7,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Use more lemon.'),
        ),
        actions: <AppDialogAction>[
          AppDialogAction(
            label: 'Cancel',
            icon: Icons.close,
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          AppDialogAction(
            label: 'Save',
            icon: Icons.check,
            isPrimary: true,
            onPressed: () {
              if (note == null) {
                state.addDishNote(dishId, controller.text);
              } else {
                state.updateDishNote(note.id, controller.text);
              }
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      );
    },
  );
  controller.dispose();
}

Future<void> _showListEditor(
  BuildContext context, {
  required String title,
  required List<String> initialItems,
  required void Function(MyMenuState state, List<String> items) onSave,
}) async {
  final MyMenuState state = MyMenuScope.of(context);
  final TextEditingController controller = TextEditingController(
    text: initialItems.join('\n'),
  );

  await showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AppDialog(
        title: 'Edit $title',
        subtitle: 'Keep one item per line so the dish stays easy to scan.',
        icon: title == 'Ingredients'
            ? Icons.format_list_bulleted
            : Icons.menu_book_outlined,
        content: TextField(
          controller: controller,
          minLines: 9,
          maxLines: 13,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: <AppDialogAction>[
          AppDialogAction(
            label: 'Cancel',
            icon: Icons.close,
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          AppDialogAction(
            label: 'Save',
            icon: Icons.check,
            isPrimary: true,
            onPressed: () {
              final List<String> items = controller.text
                  .split('\n')
                  .map((String item) => item.trim())
                  .where((String item) => item.isNotEmpty)
                  .toList(growable: false);
              onSave(state, items);
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      );
    },
  );
  controller.dispose();
}
