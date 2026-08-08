import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mymenu/domain/covers/generated_cover.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/processing/processing_consent_prompt.dart';
import 'package:mymenu/domain/processing/processing_outbox.dart';
import 'package:mymenu/domain/processing/processing_privacy_notice.dart';
import 'package:mymenu/domain/sync/my_menu_state.dart';
import 'package:mymenu/features/improve_cover/improve_cover_result.dart';
import 'package:mymenu/features/improve_cover/improve_cover_selection.dart';
import 'package:mymenu/features/improve_cover/improve_cover_status.dart';

enum ImproveCoverStep { selection, generating, result, offline, error }

Future<void> showImproveCoverDialog(
  BuildContext context,
  MyMenuState state,
  String dishId,
) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (_) => ImproveCoverFlow(state: state, dishId: dishId),
  );
}

class ImproveCoverFlow extends StatefulWidget {
  const ImproveCoverFlow({
    required this.state,
    required this.dishId,
    this.initialStep = ImproveCoverStep.selection,
    super.key,
  });

  final MyMenuState state;
  final String dishId;
  final ImproveCoverStep initialStep;

  @override
  State<ImproveCoverFlow> createState() => _ImproveCoverFlowState();
}

class _ImproveCoverFlowState extends State<ImproveCoverFlow> {
  late ImproveCoverStep _step;
  final Set<String> _selectedSourceIds = <String>{};
  CoverTreatment _treatment = CoverTreatment.defaults;
  int? _coverAllowanceRemaining;

  Dish get _dish => widget.state.dishById(widget.dishId);
  GeneratedCover? get _proposal =>
      widget.state.proposedCoverForDish(widget.dishId);

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep;
    _selectedSourceIds.addAll(
      _dish.sourcePhotos
          .map((SourcePhoto source) => source.id)
          .whereType<String>()
          .take(3),
    );
    if (_proposal != null) _step = ImproveCoverStep.result;
    widget.state.addListener(_stateChanged);
    unawaited(_loadAllowance());
  }

  @override
  void dispose() {
    widget.state.removeListener(_stateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GeneratedCover? proposal = _proposal;
    if (proposal != null && _step != ImproveCoverStep.selection) {
      return ImproveCoverResult(
        dish: _dish,
        proposal: proposal,
        onUseCover: () => _useCover(proposal),
        onTryAnother: () => setState(() => _step = ImproveCoverStep.selection),
        onKeepCurrent: () => _keepCurrent(proposal),
      );
    }
    return switch (_step) {
      ImproveCoverStep.selection ||
      ImproveCoverStep.result =>
        ImproveCoverSelection(
          dish: _dish,
          selectedSourceIds: _selectedSourceIds,
          treatment: _treatment,
          onTreatmentChanged: (CoverTreatment value) {
            setState(() => _treatment = value);
          },
          onToggleSource: _toggleSource,
          onGenerate: _canGenerate ? _startGeneration : null,
          onClose: () => Navigator.pop(context),
          coverAllowanceRemaining: _coverAllowanceRemaining,
        ),
      ImproveCoverStep.generating => ImproveCoverGenerating(
          dish: _dish,
          onClose: () => Navigator.pop(context),
        ),
      ImproveCoverStep.offline => ImproveCoverOffline(
          dish: _dish,
          onClose: () => Navigator.pop(context),
          onRetry: () => setState(() => _step = ImproveCoverStep.selection),
        ),
      ImproveCoverStep.error => ImproveCoverError(
          dish: _dish,
          selectedCount: _selectedSourceIds.length,
          onClose: () => Navigator.pop(context),
          onRetry: _startGeneration,
        ),
    };
  }

  bool get _canGenerate =>
      _coverAllowanceRemaining != 0 &&
      (_dish.sourcePhotos.isEmpty || _selectedSourceIds.isNotEmpty);

  Future<void> _loadAllowance() async {
    final int? remaining = await widget.state.remainingCoverAllowance();
    if (mounted) setState(() => _coverAllowanceRemaining = remaining);
  }

  void _stateChanged() {
    if (!mounted) return;
    final ProcessingOutboxRequest? request = _coverRequest;
    setState(() {
      if (_proposal != null) {
        _step = ImproveCoverStep.result;
      } else if (request?.deliveryState == ProcessingDeliveryState.failed ||
          request?.deliveryState == ProcessingDeliveryState.expired) {
        _step = ImproveCoverStep.error;
      }
    });
  }

  ProcessingOutboxRequest? get _coverRequest {
    for (final ProcessingOutboxRequest request
        in widget.state.processingRequests.reversed) {
      if (request.kind == ProcessingRequestKind.coverGeneration &&
          request.subjectId == widget.dishId) {
        return request;
      }
    }
    return null;
  }

  void _toggleSource(String id) {
    setState(() {
      if (_selectedSourceIds.contains(id)) {
        _selectedSourceIds.remove(id);
      } else if (_selectedSourceIds.length < 3) {
        _selectedSourceIds.add(id);
      }
    });
  }

  Future<void> _startGeneration() async {
    if (!_canGenerate) return;
    final ProcessingConsentDecision decision =
        await widget.state.requestProcessingConsent(
      trigger: ProcessingConsentTrigger.improveCover,
    );
    if (!mounted || decision != ProcessingConsentDecision.accepted) return;
    final bool enqueued = await widget.state.startManualCoverGeneration(
      dishId: widget.dishId,
      selectedSourceIds: _selectedSourceIds.toList(growable: false),
      treatment: _treatment,
    );
    if (!mounted) return;
    setState(() {
      _step = enqueued ? ImproveCoverStep.generating : ImproveCoverStep.error;
    });
  }

  Future<void> _useCover(GeneratedCover proposal) async {
    await widget.state.acceptCoverProposal(proposal.id);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _keepCurrent(GeneratedCover proposal) async {
    await widget.state.keepCurrentCover(proposal.id);
    if (mounted) Navigator.pop(context);
  }
}
