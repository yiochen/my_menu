import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mymenu/shared/debug_feedback/debug_feedback_models.dart';
import 'package:mymenu/shared/debug_feedback/debug_feedback_widget_classifier.dart';
import 'package:mymenu/shared/debug_feedback/feedback_target.dart';

typedef _CandidateElement = ({Element element, bool explicit});

class DebugFeedbackTargetFinder {
  const DebugFeedbackTargetFinder({
    this.classifier = const DebugFeedbackWidgetClassifier(),
  });

  final DebugFeedbackWidgetClassifier classifier;

  List<DebugFeedbackCandidate> find({
    required Offset position,
    required RenderObject root,
  }) {
    final List<RenderObject> hits = _findRenderObjects(position, root);
    final Set<Element> visited = <Element>{};
    final List<_CandidateElement> elements = <_CandidateElement>[];

    for (final RenderObject hit in hits) {
      final Object? creator = hit.debugCreator;
      if (creator is! DebugCreator) {
        continue;
      }
      Element? current = creator.element;
      while (current != null) {
        if (_isExcluded(current)) {
          break;
        }
        if (visited.add(current) && classifier.isMeaningful(current.widget)) {
          elements.add(
            (
              element: current,
              explicit: current.widget is FeedbackTarget,
            ),
          );
        }
        current = _parentOf(current);
      }
    }

    if (elements.isEmpty) {
      return const <DebugFeedbackCandidate>[];
    }
    return elements.map(_buildCandidate).toList(growable: false);
  }

  List<RenderObject> _findRenderObjects(Offset position, RenderObject root) {
    final List<RenderObject> hits = <RenderObject>[];
    _collectHits(
      hits,
      position,
      root,
      root.getTransformTo(null),
    );
    hits.sort((RenderObject first, RenderObject second) {
      return _area(first).compareTo(_area(second));
    });
    return hits;
  }

  bool _collectHits(
    List<RenderObject> hits,
    Offset position,
    RenderObject object,
    Matrix4 transform,
  ) {
    final Matrix4? inverse = Matrix4.tryInvert(transform);
    if (inverse == null) {
      return false;
    }
    final Offset localPosition = MatrixUtils.transformPoint(inverse, position);
    bool hit = false;
    final List<DiagnosticsNode> children = object.debugDescribeChildren();
    for (int index = children.length - 1; index >= 0; index -= 1) {
      final DiagnosticsNode childNode = children[index];
      if (childNode.style == DiagnosticsTreeStyle.offstage ||
          childNode.value is! RenderObject) {
        continue;
      }
      final RenderObject child = childNode.value! as RenderObject;
      final Rect? clip = object.describeApproximatePaintClip(child);
      if (clip != null && !clip.contains(localPosition)) {
        continue;
      }
      final Matrix4 childTransform = transform.clone();
      object.applyPaintTransform(child, childTransform);
      hit = _collectHits(hits, position, child, childTransform) || hit;
    }
    if (object.semanticBounds.contains(localPosition)) {
      hit = true;
    }
    if (hit) {
      hits.add(object);
    }
    return hit;
  }

  double _area(RenderObject object) {
    final Size size = object.semanticBounds.size;
    return size.width * size.height;
  }

  bool _isExcluded(Element element) {
    if (element.widget is ExcludeFromFeedback) {
      return true;
    }
    bool excluded = false;
    element.visitAncestorElements((Element ancestor) {
      if (ancestor.widget is ExcludeFromFeedback) {
        excluded = true;
        return false;
      }
      return true;
    });
    return excluded;
  }

  DebugFeedbackCandidate _buildCandidate(_CandidateElement candidate) {
    final Element element = candidate.element;
    final FeedbackTarget? annotation = element.widget is FeedbackTarget
        ? element.widget as FeedbackTarget
        : null;
    final String? visibleText = _visibleText(element);
    final String widgetType = annotation == null
        ? element.widget.runtimeType.toString()
        : _annotatedWidgetType(element);
    final String? semantics =
        _semantics(element) ?? _defaultSemantics(widgetType, visibleText);
    return DebugFeedbackCandidate(
      element: element,
      bounds: _globalBounds(element),
      explicit: candidate.explicit,
      snapshot: DebugFeedbackTargetSnapshot(
        id: annotation?.id ?? _keyId(element.widget.key),
        label: annotation?.label ??
            semantics ??
            _labelFor(widgetType, visibleText),
        route: _routeFor(element),
        widgetType: widgetType,
        widgetPath: _widgetPath(element, leafType: widgetType),
        visibleText: visibleText,
        semantics: semantics,
      ),
    );
  }

  String _annotatedWidgetType(Element element) {
    String? result;
    element.visitChildElements((Element child) {
      result ??= child.widget.runtimeType.toString();
    });
    return result ?? element.widget.runtimeType.toString();
  }

  Rect _globalBounds(Element element) {
    final RenderObject? renderObject = element.renderObject;
    if (renderObject == null || !renderObject.attached) {
      return Rect.zero;
    }
    return MatrixUtils.transformRect(
      renderObject.getTransformTo(null),
      renderObject.semanticBounds,
    );
  }

  List<String> _widgetPath(Element element, {required String leafType}) {
    final List<String> path = <String>[leafType];
    element.visitAncestorElements((Element ancestor) {
      if (classifier.isMeaningful(ancestor.widget)) {
        path.add(ancestor.widget.runtimeType.toString());
      }
      return path.length < 8;
    });
    return path.reversed.toList(growable: false);
  }

  String? _visibleText(Element element) {
    final List<String> values = <String>[];
    void collect(Element current) {
      if (values.length >= 3 || current.widget is ExcludeFromFeedback) {
        return;
      }
      final Widget widget = current.widget;
      if (widget is Text) {
        final String value =
            widget.data ?? widget.textSpan?.toPlainText() ?? '';
        if (value.trim().isNotEmpty) {
          values.add(value.trim());
        }
      } else if (widget is RichText) {
        final String value = widget.text.toPlainText().trim();
        if (value.isNotEmpty) {
          values.add(value);
        }
      }
      current.visitChildElements(collect);
    }

    collect(element);
    if (values.isEmpty) {
      return null;
    }
    final String combined = values.toSet().join(' · ');
    return combined.length <= 160
        ? combined
        : '${combined.substring(0, 157)}...';
  }

  String? _semantics(Element element) {
    String? result;
    void inspect(Element current) {
      final Widget widget = current.widget;
      if (widget is Semantics) {
        final String? label = widget.properties.label;
        final String? role = _semanticsRole(widget.properties);
        if ((label != null && label.trim().isNotEmpty) || role != null) {
          result = <String>[
            if (label != null && label.trim().isNotEmpty) label.trim(),
            if (role != null) role,
          ].join(', ');
        }
      }
    }

    inspect(element);
    element.visitAncestorElements((Element ancestor) {
      inspect(ancestor);
      return result == null;
    });
    return result;
  }

  String? _semanticsRole(SemanticsProperties properties) {
    if (properties.button ?? false) {
      return 'button';
    }
    if (properties.link ?? false) {
      return 'link';
    }
    if (properties.textField ?? false) {
      return 'text field';
    }
    if (properties.slider ?? false) {
      return 'slider';
    }
    if (properties.checked != null) {
      return 'checkbox';
    }
    if (properties.toggled != null) {
      return 'toggle';
    }
    return null;
  }

  String? _defaultSemantics(String widgetType, String? visibleText) {
    final String? role = switch (widgetType) {
      final String type when type.contains('Button') => 'button',
      final String type when type.contains('TextField') => 'text field',
      final String type when type.contains('Switch') => 'toggle',
      final String type when type.contains('Checkbox') => 'checkbox',
      final String type when type.contains('Slider') => 'slider',
      _ => null,
    };
    if (role == null) {
      return null;
    }
    return <String>[
      if (visibleText != null) visibleText,
      role,
    ].join(', ');
  }

  String? _routeFor(Element element) {
    final String? routeName = ModalRoute.of(element)?.settings.name;
    if (routeName != null && routeName.trim().isNotEmpty && routeName != '/') {
      return routeName;
    }
    String? screen;
    element.visitAncestorElements((Element ancestor) {
      final String type = ancestor.widget.runtimeType.toString();
      if (type.endsWith('Screen') || type.endsWith('Page')) {
        screen = type;
        return false;
      }
      return true;
    });
    return screen;
  }

  String? _keyId(Key? key) {
    if (key is ValueKey<String>) {
      return 'key:${key.value}';
    }
    return null;
  }

  String _labelFor(String type, String? visibleText) {
    final String humanType =
        type.replaceFirst(RegExp(r'^_'), '').replaceAllMapped(
              RegExp('([a-z0-9])([A-Z])'),
              (Match match) => '${match.group(1)} ${match.group(2)}',
            );
    if (visibleText == null) {
      return humanType;
    }
    return '$humanType “$visibleText”';
  }

  Element? _parentOf(Element element) {
    Element? parent;
    element.visitAncestorElements((Element ancestor) {
      parent = ancestor;
      return false;
    });
    return parent;
  }
}
