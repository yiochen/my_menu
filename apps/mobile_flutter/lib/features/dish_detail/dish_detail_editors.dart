part of 'dish_detail_screen.dart';

Future<void> _showNoteEditor(
  BuildContext context, {
  required String dishId,
  DishNote? note,
}) async {
  final MyMenuState state = MyMenuScope.read(context);

  final String? body = await showDialog<String>(
    context: context,
    builder: (BuildContext dialogContext) {
      return _NoteEditorDialog(
          initialBody: note?.body ?? '', isNew: note == null);
    },
  );

  if (body == null) {
    return;
  }

  if (note == null) {
    state.addDishNote(dishId, body);
  } else {
    state.updateDishNote(note.id, body);
  }
}

Future<void> _showListEditor(
  BuildContext context, {
  required String title,
  required List<String> initialItems,
  required void Function(MyMenuState state, List<String> items) onSave,
}) async {
  final MyMenuState state = MyMenuScope.read(context);

  final String? body = await showDialog<String>(
    context: context,
    builder: (BuildContext dialogContext) {
      return _ListEditorDialog(
        title: title,
        initialText: initialItems.join('\n'),
      );
    },
  );

  if (body == null) {
    return;
  }

  final List<String> items = body
      .split('\n')
      .map((String item) => item.trim())
      .where((String item) => item.isNotEmpty)
      .toList(growable: false);
  onSave(state, items);
}

class _NoteEditorDialog extends StatefulWidget {
  const _NoteEditorDialog({required this.initialBody, required this.isNew});

  final String initialBody;
  final bool isNew;

  @override
  State<_NoteEditorDialog> createState() => _NoteEditorDialogState();
}

class _NoteEditorDialogState extends State<_NoteEditorDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialBody);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: widget.isNew ? 'Add Note' : 'Edit Note',
      subtitle: 'Capture the little thing you want to remember next time.',
      icon: Icons.sticky_note_2_outlined,
      content: TextField(
        controller: _controller,
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppDialogAction(
          label: 'Save',
          icon: Icons.check,
          isPrimary: true,
          onPressed: () => Navigator.of(context).pop(_controller.text),
        ),
      ],
    );
  }
}

class _ListEditorDialog extends StatefulWidget {
  const _ListEditorDialog({required this.title, required this.initialText});

  final String title;
  final String initialText;

  @override
  State<_ListEditorDialog> createState() => _ListEditorDialogState();
}

class _ListEditorDialogState extends State<_ListEditorDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Edit ${widget.title}',
      subtitle: 'Keep one item per line so the dish stays easy to scan.',
      icon: widget.title == 'Ingredients'
          ? Icons.format_list_bulleted
          : Icons.menu_book_outlined,
      content: TextField(
        controller: _controller,
        minLines: 9,
        maxLines: 13,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
      ),
      actions: <AppDialogAction>[
        AppDialogAction(
          label: 'Cancel',
          icon: Icons.close,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppDialogAction(
          label: 'Save',
          icon: Icons.check,
          isPrimary: true,
          onPressed: () => Navigator.of(context).pop(_controller.text),
        ),
      ],
    );
  }
}
