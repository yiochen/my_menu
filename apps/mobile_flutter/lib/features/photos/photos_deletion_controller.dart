import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/photos/photos_selection_bar.dart';

class PhotosDeletionController {
  final Map<String, ({MyMenuState state, CaptureDeletionTicket ticket})>
      _pending =
      <String, ({MyMenuState state, CaptureDeletionTicket ticket})>{};

  void stage(BuildContext context, MyMenuState state, Set<String> ids) {
    final CaptureDeletionTicket ticket = state.stageCaptureDeletion(ids);
    _pending[ticket.id] = (state: state, ticket: ticket);
    final ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackbar =
        showPhotoDeletionUndo(
      context,
      ticket.captureIds.toSet(),
      duration: ticket.undoWindow,
      onUndo: () => _undo(ticket.id),
    );
    unawaited(snackbar.closed.then((_) => _commitPending(ticket.id)));
  }

  void dispose() {
    final pending = _pending.values.toList(growable: false);
    _pending.clear();
    for (final deletion in pending) {
      _commit(deletion.state, deletion.ticket);
    }
  }

  void _undo(String ticketId) {
    final deletion = _pending.remove(ticketId);
    if (deletion != null) {
      deletion.state.undoCaptureDeletion(deletion.ticket);
    }
  }

  void _commitPending(String ticketId) {
    final deletion = _pending.remove(ticketId);
    if (deletion != null) {
      _commit(deletion.state, deletion.ticket);
    }
  }

  void _commit(MyMenuState state, CaptureDeletionTicket ticket) {
    unawaited(
      state.commitCaptureDeletion(ticket).onError(
        (Object error, StackTrace stackTrace) {
          developer.log(
            'Photo deletion failed.',
            name: 'mymenu.local',
            error: error,
            stackTrace: stackTrace,
          );
        },
      ),
    );
  }
}
