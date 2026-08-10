import 'package:flutter/material.dart';

import 'package:mymenu/domain/covers/generated_cover.dart';
import 'package:mymenu/shared/theme/my_menu_theme.dart';

class ImproveCoverTreatmentSection extends StatelessWidget {
  const ImproveCoverTreatmentSection({
    required this.treatment,
    required this.autoScrollToSelection,
    required this.horizontalPadding,
    required this.onChanged,
    super.key,
  });

  final CoverTreatment treatment;
  final bool autoScrollToSelection;
  final double horizontalPadding;
  final ValueChanged<CoverTreatment> onChanged;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _TreatmentPicker<CoverLook>(
            label: 'Look',
            values: CoverLook.values,
            selected: treatment.look,
            name: _lookLabel,
            previewPath: _lookPreviewPath,
            autoScrollToSelection: autoScrollToSelection,
            horizontalPadding: horizontalPadding,
            onSelected: (CoverLook look) => onChanged(CoverTreatment(
              look: look,
              view: treatment.view,
              finish: treatment.finish,
            )),
          ),
          const SizedBox(height: 14),
          _TreatmentPicker<CoverView>(
            label: 'View',
            values: CoverView.values,
            selected: treatment.view,
            name: _viewLabel,
            previewPath: _viewPreviewPath,
            autoScrollToSelection: autoScrollToSelection,
            horizontalPadding: horizontalPadding,
            onSelected: (CoverView view) => onChanged(CoverTreatment(
              look: treatment.look,
              view: view,
              finish: treatment.finish,
            )),
          ),
          const SizedBox(height: 14),
          _TreatmentPicker<CoverFinish>(
            label: 'Finish',
            values: CoverFinish.values,
            selected: treatment.finish,
            name: _finishLabel,
            previewPath: _finishPreviewPath,
            autoScrollToSelection: autoScrollToSelection,
            horizontalPadding: horizontalPadding,
            onSelected: (CoverFinish finish) => onChanged(CoverTreatment(
              look: treatment.look,
              view: treatment.view,
              finish: finish,
            )),
          ),
        ],
      );
}

class _TreatmentPicker<T> extends StatefulWidget {
  const _TreatmentPicker({
    required this.label,
    required this.values,
    required this.selected,
    required this.name,
    required this.previewPath,
    required this.autoScrollToSelection,
    required this.horizontalPadding,
    required this.onSelected,
  });

  final String label;
  final List<T> values;
  final T selected;
  final String Function(T) name;
  final String Function(T) previewPath;
  final bool autoScrollToSelection;
  final double horizontalPadding;
  final ValueChanged<T> onSelected;

  @override
  State<_TreatmentPicker<T>> createState() => _TreatmentPickerState<T>();
}

class _TreatmentPickerState<T> extends State<_TreatmentPicker<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.autoScrollToSelection) _scheduleSelectedScroll();
  }

  @override
  void didUpdateWidget(covariant _TreatmentPicker<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.autoScrollToSelection && widget.autoScrollToSelection) {
      _scheduleSelectedScroll();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scheduleSelectedScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final int selectedIndex = widget.values.indexOf(widget.selected);
      final ScrollPosition position = _scrollController.position;
      final double selectedCenter =
          widget.horizontalPadding + selectedIndex * 125 + 58;
      final double target = (selectedCenter - position.viewportDimension / 2)
          .clamp(0, position.maxScrollExtent);
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        const SizedBox(height: 7),
        SizedBox(
          height: 112,
          child: ListView.separated(
            key: ValueKey<String>(
              'treatment_picker_${widget.label.toLowerCase()}',
            ),
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
            itemCount: widget.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 9),
            itemBuilder: (BuildContext context, int index) {
              final T value = widget.values[index];
              final bool selected = value == widget.selected;
              final String optionName = widget.name(value);
              return Semantics(
                button: true,
                selected: selected,
                label: '${widget.label} · $optionName',
                child: SizedBox(
                  width: 116,
                  child: Material(
                    clipBehavior: Clip.antiAlias,
                    color: MyMenuColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color:
                            selected ? MyMenuColors.orange : MyMenuColors.line,
                        width: selected ? 2.5 : 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => widget.onSelected(value),
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(
                                child: Image.asset(
                                  widget.previewPath(value),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(9, 7, 9, 7),
                                child: Text(
                                  optionName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ),
                            ],
                          ),
                          if (selected)
                            const Positioned(
                              right: 6,
                              top: 6,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: MyMenuColors.orange,
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(3),
                                  child: Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

String _lookLabel(CoverLook value) => switch (value) {
      CoverLook.naturalPolish => 'Natural',
      CoverLook.brightFresh => 'Bright',
      CoverLook.warmCozy => 'Warm',
      CoverLook.darkRefined => 'Dark',
    };

String _viewLabel(CoverView value) => switch (value) {
      CoverView.automatic => 'Auto',
      CoverView.overhead => 'Overhead',
      CoverView.angled => 'Angled',
      CoverView.closeUp => 'Close-up',
    };

String _finishLabel(CoverFinish value) => switch (value) {
      CoverFinish.lightTouch => 'Light touch',
      CoverFinish.menuReady => 'Menu-ready',
      CoverFinish.editorial => 'Editorial',
    };

String _lookPreviewPath(CoverLook value) => switch (value) {
      CoverLook.naturalPolish => 'assets/cover_treatments/look_natural.png',
      CoverLook.brightFresh => 'assets/cover_treatments/look_bright.png',
      CoverLook.warmCozy => 'assets/cover_treatments/look_warm.png',
      CoverLook.darkRefined => 'assets/cover_treatments/look_dark.png',
    };

String _viewPreviewPath(CoverView value) => switch (value) {
      CoverView.automatic => 'assets/cover_treatments/view_auto.png',
      CoverView.overhead => 'assets/cover_treatments/view_overhead.png',
      CoverView.angled => 'assets/cover_treatments/view_angled.png',
      CoverView.closeUp => 'assets/cover_treatments/view_close_up.png',
    };

String _finishPreviewPath(CoverFinish value) => switch (value) {
      CoverFinish.lightTouch =>
        'assets/cover_treatments/finish_light_touch.png',
      CoverFinish.menuReady => 'assets/cover_treatments/finish_menu_ready.png',
      CoverFinish.editorial => 'assets/cover_treatments/finish_editorial.png',
    };
