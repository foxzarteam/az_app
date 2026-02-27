import 'package:flutter/material.dart';
class WhiteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const WhiteCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: child,
        ),
      ),
    );
  }
}
