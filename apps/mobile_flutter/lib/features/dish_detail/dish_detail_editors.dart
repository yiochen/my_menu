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
      return AlertDialog(
        title: Text(note == null ? 'Add Note' : 'Edit Note'),
        content: TextField(
          controller: controller,
          minLines: 3,
          maxLines: 6,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Use more lemon.'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (note == null) {
                state.addDishNote(dishId, controller.text);
              } else {
                state.updateDishNote(note.id, controller.text);
              }
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
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
      return AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          minLines: 8,
          maxLines: 12,
          autofocus: true,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final List<String> items = controller.text
                  .split('\n')
                  .map((String item) => item.trim())
                  .where((String item) => item.isNotEmpty)
                  .toList(growable: false);
              onSave(state, items);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
