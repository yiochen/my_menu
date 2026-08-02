import 'package:flutter/material.dart';

Future<bool> runLocalWriteWithFeedback(
  BuildContext context,
  Future<void> Function() write, {
  String errorMessage = 'Could not save that change. Please try again.',
}) async {
  try {
    await write();
    return true;
  } on Object {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
    return false;
  }
}
