enum CoverOrigin { automatic, manual }

enum CoverGrounding { source, context }

enum GeneratedCoverState { proposed, history, current }

enum CoverLook {
  naturalPolish('natural_polish'),
  brightFresh('bright_fresh'),
  warmCozy('warm_cozy'),
  darkRefined('dark_refined');

  const CoverLook(this.apiValue);

  final String apiValue;
}

enum CoverView {
  automatic('auto'),
  overhead('overhead'),
  angled('angled'),
  closeUp('close_up');

  const CoverView(this.apiValue);

  final String apiValue;
}

enum CoverFinish {
  lightTouch('light_touch'),
  menuReady('menu_ready'),
  editorial('editorial');

  const CoverFinish(this.apiValue);

  final String apiValue;
}

class CoverTreatment {
  const CoverTreatment({
    required this.look,
    required this.view,
    required this.finish,
  });

  static const CoverTreatment defaults = CoverTreatment(
    look: CoverLook.naturalPolish,
    view: CoverView.automatic,
    finish: CoverFinish.menuReady,
  );

  final CoverLook look;
  final CoverView view;
  final CoverFinish finish;

  Map<String, Object?> toJson() => <String, Object?>{
        'look': look.apiValue,
        'view': view.apiValue,
        'finish': finish.apiValue,
      };
}

class GeneratedCover {
  const GeneratedCover({
    required this.id,
    required this.dishId,
    required this.localPath,
    required this.origin,
    required this.grounding,
    required this.selectedSourceIds,
    required this.treatment,
    required this.contractVersion,
    required this.proposalId,
    required this.state,
    required this.createdAt,
    this.previewPath,
    this.thumbnailPath,
    this.placeholderPath,
    this.automaticAcknowledged = false,
    this.automaticUndoAvailable = false,
  });

  final String id;
  final String dishId;
  final String localPath;
  final String? previewPath;
  final String? thumbnailPath;
  final String? placeholderPath;
  final CoverOrigin origin;
  final CoverGrounding grounding;
  final List<String> selectedSourceIds;
  final CoverTreatment treatment;
  final String contractVersion;
  final String proposalId;
  final GeneratedCoverState state;
  final DateTime createdAt;
  final bool automaticAcknowledged;
  final bool automaticUndoAvailable;
}
