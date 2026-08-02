import 'dart:developer' as developer;

import 'package:flutter/material.dart';

Future<bool> runLocalWriteWithFeedback(
  BuildContext context,
  Future<void> Function() write, {
  String errorMessage = 'Could not save that change. Please try again.',
}) async {
  try {
    await write();
    return true;
  } on Object catch (error, stackTrace) {
    debugPrint('mymenu.local: Local write failed: $error\n$stackTrace');
    developer.log(
      'Local write failed.',
      name: 'mymenu.local',
      error: error,
      stackTrace: stackTrace,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
    return false;
  }
}
