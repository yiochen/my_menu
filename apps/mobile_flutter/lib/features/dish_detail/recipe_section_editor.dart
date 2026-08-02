import 'package:flutter/material.dart';

import 'package:mymenu/shared/widgets/warm_components.dart';

Future<List<String>?> showRecipeSectionEditor(
  BuildContext context, {
  required String title,
  required List<String> values,
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _RecipeSectionEditor(title: title, values: values),
  );
}

class _RecipeSectionEditor extends StatefulWidget {
  const _RecipeSectionEditor({
    required this.title,
    required this.values,
  });

  final String title;
  final List<String> values;

  @override
  State<_RecipeSectionEditor> createState() => _RecipeSectionEditorState();
}

class _RecipeSectionEditorState extends State<_RecipeSectionEditor> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.values.join('\n'),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        10,
        18,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SheetTopBar(
            title: 'Edit ${widget.title.toLowerCase()}',
            closeOnLeft: true,
            onClose: () => Navigator.pop(context),
          ),
          const SizedBox(height: 14),
          TextField(
            key: const ValueKey<String>('recipe_section_input'),
            controller: _controller,
            autofocus: true,
            minLines: 6,
            maxLines: 10,
            decoration: InputDecoration(
              hintText: widget.title == 'Ingredients'
                  ? 'One ingredient per line'
                  : 'One step per line',
              helperText: 'Use one line for each item.',
            ),
          ),
          const SizedBox(height: 14),
          PrimaryPillButton(
            key: const ValueKey<String>('save_recipe_section'),
            label: 'Save',
            icon: Icons.check,
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  void _save() {
    final List<String> values = _controller.text
        .split('\n')
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .toList(growable: false);
    Navigator.pop(context, values);
  }
}
