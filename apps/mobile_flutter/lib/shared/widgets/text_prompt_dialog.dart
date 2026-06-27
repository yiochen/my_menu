import 'package:flutter/material.dart';

Future<String?> showTextPromptDialog(
  BuildContext context, {
  required String title,
  required String hint,
  String submitLabel = 'Save',
  bool autofocus = false,
}) async {
  String value = '';
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: TextFormField(
          autofocus: autofocus,
          maxLines: 3,
          decoration: InputDecoration(hintText: hint),
          onChanged: (String nextValue) {
            value = nextValue;
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(value),
            child: Text(submitLabel),
          ),
        ],
      );
    },
  );
}
