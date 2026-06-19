import 'package:flutter/material.dart';

extension DebugWidget on Widget {
  Widget debug([
    Color color = const Color(0x8000FF00),
  ]) {
    Widget current = this;

    assert(() {
      current = ColoredBox(
        color: color,
        child: this,
      );
      return true;
    }(), 'DebugWidget.debug() should only wrap in debug mode.');

    return current;
  }
}
