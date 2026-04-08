import 'package:flutter/widgets.dart';

/// Provides device insets captured once (first build), so UI doesn't jump
/// when system overlays (status/navigation bars) temporarily hide/show.
class FixedInsets {
  static double? _statusBarTop;

  static double statusBarTop(BuildContext context) {
    final cached = _statusBarTop;
    if (cached != null) return cached;
    final top = MediaQuery.of(context).padding.top;
    _statusBarTop = top;
    return top;
  }
}
