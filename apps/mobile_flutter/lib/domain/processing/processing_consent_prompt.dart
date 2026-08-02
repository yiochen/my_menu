enum ProcessingConsentTrigger {
  capture,
  improveCover,
  recipeEnrichment,
}

class ProcessingConsentRequest {
  const ProcessingConsentRequest({
    required this.id,
    required this.trigger,
  });

  final int id;
  final ProcessingConsentTrigger trigger;
}
