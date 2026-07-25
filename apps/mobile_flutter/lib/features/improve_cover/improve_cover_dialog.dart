import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mymenu/domain/dishes/dish.dart';
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
  const String scenario = String.fromEnvironment(
    'MY_MENU_COVER_SCENARIO',
    defaultValue: 'success',
  );
  final ImproveCoverStep initialStep = switch (scenario) {
    'offline' => ImproveCoverStep.offline,
    'error' => ImproveCoverStep.error,
    _ => ImproveCoverStep.selection,
  };
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (_) => ImproveCoverFlow(
      state: state,
      dishId: dishId,
      initialStep: initialStep,
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
  final Set<int> _selectedSources = <int>{0, 1, 2};
  String _direction =
      'Make the salmon glossy, use a darker table, and keep the bowl simple.';

  Dish get _dish => widget.state.dishById(widget.dishId);

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep;
  }

  @override
  Widget build(BuildContext context) {
    return switch (_step) {
      ImproveCoverStep.selection => ImproveCoverSelection(
          dish: _dish,
          selectedSources: _selectedSources,
          initialDirection: _direction,
          onDirectionChanged: (String value) => _direction = value,
          onToggleSource: _toggleSource,
          onGenerate: _startGeneration,
          onClose: () => Navigator.pop(context),
        ),
      ImproveCoverStep.generating => ImproveCoverGenerating(
          dish: _dish,
          onClose: () => Navigator.pop(context),
        ),
      ImproveCoverStep.result => ImproveCoverResult(
          dish: _dish,
          onUseCover: _useCover,
          onKeepCurrent: () => Navigator.pop(context),
        ),
      ImproveCoverStep.offline => ImproveCoverOffline(
          dish: _dish,
          onClose: () => Navigator.pop(context),
          onRetry: () => setState(() => _step = ImproveCoverStep.selection),
        ),
      ImproveCoverStep.error => ImproveCoverError(
          dish: _dish,
          selectedCount: _selectedSources.length,
          onClose: () => Navigator.pop(context),
          onRetry: _startGeneration,
        ),
    };
  }

  void _toggleSource(int index) {
    setState(() {
      if (_selectedSources.contains(index)) {
        _selectedSources.remove(index);
      } else {
        _selectedSources.add(index);
      }
    });
  }

  void _startGeneration() {
    if (_selectedSources.isEmpty) {
      return;
    }
    setState(() => _step = ImproveCoverStep.generating);
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 900), () {
        if (mounted && _step == ImproveCoverStep.generating) {
          setState(() => _step = ImproveCoverStep.result);
        }
      }),
    );
  }

  void _useCover() {
    widget.state.improveCover(widget.dishId, _direction);
    Navigator.pop(context);
  }
}
