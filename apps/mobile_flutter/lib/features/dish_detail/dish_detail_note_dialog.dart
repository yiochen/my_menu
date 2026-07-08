part of 'dish_detail_screen.dart';

Future<void> _showNoteDetail(
  BuildContext context, {
  required DishNote note,
  required _NoteCardStyle style,
  required _NoteText noteText,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) async {
  await showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      final double maxDialogHeight =
          MediaQuery.sizeOf(dialogContext).height * 0.84;

      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        backgroundColor: _detailPaper,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shadowColor: Colors.black.withValues(alpha: 0.24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: 520, maxHeight: maxDialogHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const _NoteDialogHeader(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _NoteDialogPreview(style: style, noteText: noteText),
                      _FullNoteBody(note: note),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE7DDCE)),
              _NoteDialogActions(onEdit: onEdit, onDelete: onDelete),
            ],
          ),
        ),
      );
    },
  );
}

class _NoteDialogHeader extends StatelessWidget {
  const _NoteDialogHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Row(
        children: <Widget>[
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              'Note',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _detailInk,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          IconButton(
            tooltip: 'Close note',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            color: _detailInk,
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

class _NoteDialogPreview extends StatelessWidget {
  const _NoteDialogPreview({required this.style, required this.noteText});

  final _NoteCardStyle style;
  final _NoteText noteText;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _noteAssetAspectRatio,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.asset(
                style.assetPath,
                fit: BoxFit.fill,
                excludeFromSemantics: true,
              ),
              Padding(
                padding: style.detailPaddingFor(
                  Size(constraints.maxWidth, constraints.maxHeight),
                ),
                child: _NoteTextColumn(
                  noteText: noteText,
                  titleSize: 24,
                  bodySize: 17,
                  maxTitleLines: 2,
                  maxBodyLines: 5,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FullNoteBody extends StatelessWidget {
  const _FullNoteBody({required this.note});

  final DishNote note;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 4, 26, 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F1E6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE7DDCE)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Full note',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: _detailMuted,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                note.body,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF253027),
                      fontSize: 15,
                      height: 1.38,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteDialogActions extends StatelessWidget {
  const _NoteDialogActions({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onEdit();
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Note'),
              style: TextButton.styleFrom(
                foregroundColor: _detailInk,
                minimumSize: const Size.fromHeight(48),
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(
            height: 28,
            child: VerticalDivider(width: 1, color: Color(0xFFE7DDCE)),
          ),
          Expanded(
            child: TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete();
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete Note'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF9B4C35),
                minimumSize: const Size.fromHeight(48),
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
