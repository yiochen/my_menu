part of 'dish_detail_screen.dart';

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.dish, super.key});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    final MyMenuState state = MyMenuScope.of(context);

    return _SectionChrome(
      title: 'Notes',
      trailing: TextButton.icon(
        onPressed: () => _showNoteEditor(context, dishId: dish.id),
        icon: const Icon(Icons.add_circle_outline, size: 18),
        label: const Text('Add Note'),
        style: TextButton.styleFrom(
          foregroundColor: _detailGold,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool twoColumns = constraints.maxWidth >= 340;
          final double cardWidth = twoColumns
              ? (constraints.maxWidth - 16) / 2
              : constraints.maxWidth;

          return Wrap(
            spacing: 16,
            runSpacing: 14,
            children: dish.notes.map((DishNote note) {
              return SizedBox(
                width: cardWidth,
                child: _NoteCard(
                  note: note,
                  onEdit: () => _showNoteEditor(
                    context,
                    dishId: dish.id,
                    note: note,
                  ),
                  onDelete: () => state.deleteDishNote(note.id),
                ),
              );
            }).toList(growable: false),
          );
        },
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  final DishNote note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final _NoteCardStyle style = _NoteCardStyle.forIndex(note.position);
    final _NoteText noteText = _splitNoteText(note.body);

    return Semantics(
      button: true,
      label: 'Open note: ${note.body}',
      child: GestureDetector(
        key: ValueKey<String>('dish_note_card_${note.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _showNoteDetail(
          context,
          note: note,
          style: style,
          noteText: noteText,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
        child: AspectRatio(
          aspectRatio: _noteAssetAspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.asset(
                style.assetPath,
                fit: BoxFit.fill,
                excludeFromSemantics: true,
              ),
              Padding(
                padding: style.previewPadding,
                child: _NoteTextColumn(
                  noteText: noteText,
                  titleSize: 12.5,
                  bodySize: 11.5,
                  maxTitleLines: 1,
                  maxBodyLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteTextColumn extends StatelessWidget {
  const _NoteTextColumn({
    required this.noteText,
    required this.titleSize,
    required this.bodySize,
    required this.maxTitleLines,
    required this.maxBodyLines,
  });

  final _NoteText noteText;
  final double titleSize;
  final double bodySize;
  final int maxTitleLines;
  final int maxBodyLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          noteText.title,
          maxLines: maxTitleLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: const Color(0xFF253027),
            fontSize: titleSize,
            height: 1.05,
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
          ),
        ),
        if (noteText.body.isNotEmpty) ...<Widget>[
          SizedBox(height: bodySize * 0.35),
          Text(
            noteText.body,
            maxLines: maxBodyLines,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF253027),
              fontSize: bodySize,
              height: 1.24,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _NoteCardStyle {
  const _NoteCardStyle({
    required this.assetPath,
    required this.previewPadding,
    required this.detailPadding,
  });

  factory _NoteCardStyle.forIndex(int index) {
    const List<_NoteCardStyle> styles = <_NoteCardStyle>[
      _NoteCardStyle(
        assetPath: 'assets/dish_detail_notes/note_lemon_pin.png',
        previewPadding: EdgeInsets.fromLTRB(76, 34, 8, 14),
        detailPadding: EdgeInsets.fromLTRB(132, 72, 24, 36),
      ),
      _NoteCardStyle(
        assetPath: 'assets/dish_detail_notes/note_shrimp_tape.png',
        previewPadding: EdgeInsets.fromLTRB(24, 40, 38, 14),
        detailPadding: EdgeInsets.fromLTRB(72, 82, 230, 36),
      ),
      _NoteCardStyle(
        assetPath: 'assets/dish_detail_notes/note_cheese_pin.png',
        previewPadding: EdgeInsets.fromLTRB(76, 40, 8, 14),
        detailPadding: EdgeInsets.fromLTRB(126, 82, 28, 36),
      ),
      _NoteCardStyle(
        assetPath: 'assets/dish_detail_notes/note_kid_clip.png',
        previewPadding: EdgeInsets.fromLTRB(24, 40, 38, 14),
        detailPadding: EdgeInsets.fromLTRB(72, 82, 230, 36),
      ),
    ];

    return styles[index % styles.length];
  }

  final String assetPath;
  final EdgeInsets previewPadding;
  final EdgeInsets detailPadding;

  EdgeInsets detailPaddingFor(Size size) => _scalePadding(detailPadding, size);
}

const double _noteAssetAspectRatio = 720 / 500;
const Size _noteAssetBaseSize = Size(720, 500);

EdgeInsets _scalePadding(EdgeInsets padding, Size size) {
  final double widthScale = size.width / _noteAssetBaseSize.width;
  final double heightScale = size.height / _noteAssetBaseSize.height;

  return EdgeInsets.fromLTRB(
    padding.left * widthScale,
    padding.top * heightScale,
    padding.right * widthScale,
    padding.bottom * heightScale,
  );
}

_NoteText _splitNoteText(String body) {
  final String trimmed = body.trim();
  if (trimmed.isEmpty) {
    return const _NoteText(title: 'Note', body: '');
  }

  final RegExpMatch? sentenceMatch = RegExp(r'[.!?\n]').firstMatch(trimmed);
  if (sentenceMatch != null && sentenceMatch.end < trimmed.length) {
    final String title = trimmed.substring(0, sentenceMatch.start).trim();
    return _NoteText(
      title: _ellipsize(title.isEmpty ? 'Note' : title, 28),
      body: trimmed.substring(sentenceMatch.end).trim(),
    );
  }

  final List<String> words = trimmed.split(RegExp(r'\s+'));
  if (words.length <= 3) {
    return _NoteText(title: _ellipsize(trimmed, 28), body: '');
  }

  if (words.length >= 4 &&
      words[0].toLowerCase() == 'use' &&
      words[1].toLowerCase() == 'more') {
    return _NoteText(
      title: _ellipsize('More ${words[2]}', 28),
      body: words.skip(3).join(' '),
    );
  }

  return _NoteText(
    title: _ellipsize(words.take(2).join(' '), 28),
    body: words.skip(2).join(' '),
  );
}

String _ellipsize(String text, int maxLength) {
  if (text.length <= maxLength) {
    return text;
  }
  return '${text.substring(0, maxLength).trim()}...';
}

class _NoteText {
  const _NoteText({required this.title, required this.body});

  final String title;
  final String body;
}
