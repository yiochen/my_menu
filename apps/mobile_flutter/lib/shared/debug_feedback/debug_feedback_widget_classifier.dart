import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:mymenu/shared/debug_feedback/feedback_target.dart';

class DebugFeedbackWidgetClassifier {
  const DebugFeedbackWidgetClassifier();

  static const Set<String> structuralTypes = <String>{
    'AbsorbPointer',
    'Align',
    'AnimatedAlign',
    'AnimatedBuilder',
    'AnimatedContainer',
    'AnimatedOpacity',
    'AnimatedPadding',
    'AnimatedPositioned',
    'AnimatedSize',
    'AspectRatio',
    'BackdropFilter',
    'Baseline',
    'Builder',
    'Center',
    'ClipOval',
    'ClipPath',
    'ClipRect',
    'ClipRRect',
    'ColoredBox',
    'Column',
    'ConstrainedBox',
    'Container',
    'DecoratedBox',
    'DefaultTextStyle',
    'Directionality',
    'Expanded',
    'Flexible',
    'FractionallySizedBox',
    'IgnorePointer',
    'IndexedStack',
    'InheritedTheme',
    'IntrinsicHeight',
    'IntrinsicWidth',
    'KeyedSubtree',
    'LayoutBuilder',
    'LimitedBox',
    'ListenableBuilder',
    'Material',
    'MediaQuery',
    'MouseRegion',
    'NotificationListener',
    'Offstage',
    'Opacity',
    'OverflowBox',
    'Padding',
    'Positioned',
    'RepaintBoundary',
    'Row',
    'SafeArea',
    'Scaffold',
    'SizedBox',
    'SliverPadding',
    'Stack',
    'StreamBuilder',
    'Theme',
    'TickerMode',
    'Transform',
    'TweenAnimationBuilder',
    'UnconstrainedBox',
    'ValueListenableBuilder',
    'Visibility',
    'Wrap',
  };

  bool isMeaningful(Widget widget) {
    if (widget is FeedbackTarget) {
      return true;
    }
    if (structuralTypes.contains(widget.runtimeType.toString()) ||
        !debugIsWidgetLocalCreation(widget)) {
      return false;
    }
    if (_isStandardMeaningfulWidget(widget)) {
      return true;
    }
    return widget is StatelessWidget || widget is StatefulWidget;
  }

  bool _isStandardMeaningfulWidget(Widget widget) {
    return widget is Text ||
        widget is RichText ||
        widget is Image ||
        widget is Icon ||
        widget is ButtonStyleButton ||
        widget is IconButton ||
        widget is FloatingActionButton ||
        widget is InkWell ||
        widget is ListTile ||
        widget is TextField ||
        widget is EditableText ||
        widget is Switch ||
        widget is Checkbox ||
        widget is Radio<Object?> ||
        widget is Slider ||
        (widget is Semantics && _hasMeaningfulSemantics(widget.properties)) ||
        (widget is GestureDetector &&
            (widget.onTap != null || widget.onLongPress != null));
  }

  bool _hasMeaningfulSemantics(SemanticsProperties properties) {
    return (properties.label?.trim().isNotEmpty ?? false) ||
        properties.button != null ||
        properties.link != null ||
        properties.textField != null ||
        properties.slider != null ||
        properties.checked != null ||
        properties.toggled != null;
  }
}
