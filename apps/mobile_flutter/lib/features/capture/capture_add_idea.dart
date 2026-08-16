import 'package:flutter/material.dart';
import 'package:mymenu/domain/menu/my_menu_state.dart';
import 'package:mymenu/domain/processing/processing_consent_prompt.dart';
import 'package:mymenu/domain/processing/processing_privacy_notice.dart';
import 'package:mymenu/features/capture/add_idea_sheet.dart';
import 'package:mymenu/shared/widgets/local_write_feedback.dart';

Future<bool> captureAddIdea(BuildContext context, MyMenuState state) async {
  final AddIdeaIntent? intent = await showAddIdeaSheet(context);
  if (intent == null || !context.mounted) return false;
  String? dishId;
  final bool added = await runLocalWriteWithFeedback(
    context,
    () async {
      dishId = await state.addIdea(intent.title, note: intent.note);
    },
  );
  if (!added || dishId == null) return added;
  final bool needsConsent =
      state.processingConsentDecision == ProcessingConsentDecision.notDecided;
  ProcessingConsentDecision decision = state.processingConsentDecision;
  if (needsConsent) {
    decision = await state.requestProcessingConsent(
      trigger: ProcessingConsentTrigger.improveCover,
    );
  }
  if (needsConsent && decision == ProcessingConsentDecision.accepted) {
    await state.enqueueAutomaticCoverForDish(dishId!);
  }
  return added;
}
