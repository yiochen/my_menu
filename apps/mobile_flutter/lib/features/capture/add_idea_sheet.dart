import 'package:flutter/material.dart';

import 'package:mymenu/shared/widgets/warm_components.dart';

class AddIdeaIntent {
  const AddIdeaIntent({required this.title, required this.note});

  final String title;
  final String note;
}

Future<AddIdeaIntent?> showAddIdeaSheet(BuildContext context) {
  return showModalBottomSheet<AddIdeaIntent>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (_) => const AddIdeaSheet(),
  );
}

class AddIdeaSheet extends StatefulWidget {
  const AddIdeaSheet({super.key});

  @override
  State<AddIdeaSheet> createState() => _AddIdeaSheetState();
}

class _AddIdeaSheetState extends State<AddIdeaSheet> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _note = TextEditingController();
  bool _showValidation = false;

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          10,
          18,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SheetTopBar(
              title: 'Add an idea',
              closeOnLeft: true,
              onClose: () => Navigator.pop(context),
            ),
            const SizedBox(height: 14),
            _IdeaIntro(showValidation: _showValidation),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Dish idea',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 7),
            TextField(
              key: const ValueKey<String>('idea_title_field'),
              controller: _title,
              autofocus: true,
              onChanged: (_) {
                if (_showValidation) {
                  setState(() => _showValidation = false);
                }
              },
              decoration: InputDecoration(
                hintText: 'Charred corn ramen',
                errorText: _showValidation
                    ? 'Add a dish name or a few words about the idea.'
                    : null,
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Anything you want to remember?  Optional',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 7),
            TextField(
              key: const ValueKey<String>('idea_note_field'),
              controller: _note,
              minLines: 4,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Try miso butter broth with lime and scallions.',
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _showValidation
                    ? 'Your note is still here.'
                    : 'This becomes the first note on the new dish.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 14),
            const StatusStrip(
              icon: Icons.auto_awesome,
              text: 'AI can suggest a name, ingredients, and steps when '
                  'you’re ready.',
            ),
            const SizedBox(height: 16),
            PrimaryPillButton(
              label: 'Save idea',
              icon: Icons.arrow_forward,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final String title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _showValidation = true);
      return;
    }
    Navigator.pop(
      context,
      AddIdeaIntent(title: title, note: _note.text.trim()),
    );
  }
}

class _IdeaIntro extends StatelessWidget {
  const _IdeaIntro({required this.showValidation});

  final bool showValidation;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Eyebrow(showValidation ? 'Almost there' : 'For later'),
          Text(
            showValidation
                ? 'Give this idea a name'
                : 'What do you wanna cook?',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 7),
          Text(
            showValidation
                ? 'It can be messy—we just need something you’ll recognize.'
                : 'A rough thought is plenty. We’ll help shape it later.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
