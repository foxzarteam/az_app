import 'package:flutter/material.dart';

/// Reusable page transition: slide from right + fade. Use for all in-app screens
/// so nav/footer layout stays consistent and transitions are smooth.
Route<T> slideFromRightRoute<T>(Widget page, {int durationMs = 300}) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: Duration(milliseconds: durationMs),
    reverseTransitionDuration: Duration(milliseconds: durationMs - 20),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;
      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      final fade = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(
          opacity: animation.drive(fade),
          child: child,
        ),
      );
    },
  );
}
