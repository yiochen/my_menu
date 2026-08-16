import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mymenu/domain/covers/generated_cover.dart';
import 'package:mymenu/domain/dishes/dish.dart';
import 'package:mymenu/domain/menu/my_menu_state.dart';
import 'package:mymenu/domain/processing/processing_consent_prompt.dart';
import 'package:mymenu/domain/processing/processing_privacy_notice.dart';
import 'package:mymenu/features/improve_cover/cover_history_sheet.dart';
import 'package:mymenu/features/improve_cover/improve_cover_selection.dart';
import 'package:mymenu/features/improve_cover/improve_cover_status.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';
import 'package:mymenu/shared/widgets/warm_components.dart';

enum ImproveCoverStep { selection, generating, result, offline, error }

Future<void> showImproveCoverDialog(
  BuildContext context,
  MyMenuState state,
  String dishId,
) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => ImproveCoverFlow(state: state, dishId: dishId),
    ),
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
  bool _hasRememberedTreatment = false;
  int? _coverAllowanceRemaining;

  Dish get _dish => widget.state.dishById(widget.dishId);

  @override
  void initState() {
    super.initState();
    _step = switch (widget.initialStep) {
      ImproveCoverStep.generating ||
      ImproveCoverStep.result =>
        ImproveCoverStep.selection,
      ImproveCoverStep.selection ||
      ImproveCoverStep.offline ||
      ImproveCoverStep.error =>
        widget.initialStep,
    };
    _selectedSourceIds.addAll(
      _dish.sourcePhotos
          .map((SourcePhoto source) => source.id)
          .whereType<String>()
          .take(3),
    );
    unawaited(_loadLastTreatment());
    unawaited(_loadAllowance());
  }

  @override
  Widget build(BuildContext context) {
    return switch (_step) {
      ImproveCoverStep.selection || ImproveCoverStep.result => _CoverImagePage(
          state: widget.state,
          dish: _dish,
          aiSelection: ImproveCoverSelection(
            dish: _dish,
            selectedSourceIds: _selectedSourceIds,
            treatment: _treatment,
            autoScrollToTreatment: _hasRememberedTreatment,
            onTreatmentChanged: (CoverTreatment value) {
              setState(() => _treatment = value);
            },
            onToggleSource: _toggleSource,
            onGenerate: _canGenerate ? _startGeneration : null,
            coverAllowanceRemaining: _coverAllowanceRemaining,
            horizontalPadding: MyMenuUnits.pageHorizontal(context),
          ),
          onClose: () => Navigator.pop(context),
        ),
      ImproveCoverStep.generating => throw StateError('Unreachable step'),
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

  Future<void> _loadLastTreatment() async {
    final CoverTreatment? remembered =
        await widget.state.lastManualCoverTreatment();
    if (!mounted || remembered == null) return;
    setState(() {
      _treatment = remembered;
      _hasRememberedTreatment = true;
    });
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
    if (enqueued) {
      Navigator.pop(context);
    } else {
      setState(() => _step = ImproveCoverStep.error);
    }
  }
}

class _CoverImagePage extends StatelessWidget {
  const _CoverImagePage({
    required this.state,
    required this.dish,
    required this.aiSelection,
    required this.onClose,
  });

  final MyMenuState state;
  final Dish dish;
  final Widget aiSelection;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final double horizontal = MyMenuUnits.pageHorizontal(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: MyMenuColors.cream,
        body: WarmPage(
          includeBottomChromeSpace: false,
          horizontalPadding: 0,
          topPadding: 0,
          bottomPadding: 0,
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 0),
                  child: SheetTopBar(
                    key: const ValueKey<String>(
                      'improve_cover_sticky_header',
                    ),
                    title: 'Cover image',
                    closeOnLeft: true,
                    onClose: onClose,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontal),
                  child: const TabBar(
                    key: ValueKey<String>('cover_mode_tabs'),
                    labelColor: MyMenuColors.ink,
                    unselectedLabelColor: MyMenuColors.softInk,
                    indicatorColor: MyMenuColors.orange,
                    dividerColor: MyMenuColors.line,
                    tabs: <Widget>[
                      Tab(
                        key: ValueKey<String>('cover_ai_tab'),
                        text: 'AI generation',
                      ),
                      Tab(
                        key: ValueKey<String>('cover_existing_tab'),
                        text: 'Use existing',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: <Widget>[
                      aiSelection,
                      CoverHistorySelection(
                        state: state,
                        dishId: dish.id,
                        horizontalPadding: horizontal,
                        onDone: onClose,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
