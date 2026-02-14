import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BubbleBackground extends StatelessWidget {
  final Widget child;

  const BubbleBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Container(decoration: BoxDecoration(gradient: AppTheme.primaryGradient)),
        Positioned(
          top: size.height * 0.08,
          left: -30,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentOrange.withOpacity(0.15),
            ),
          ),
        ),
        Positioned(
          top: size.height * 0.25,
          right: -40,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.yellow.withOpacity(0.12),
            ),
          ),
        ),
        Positioned(
          bottom: size.height * 0.15,
          left: size.width * 0.2,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentOrange.withOpacity(0.1),
            ),
          ),
        ),
        Positioned(
          bottom: size.height * 0.08,
          right: size.width * 0.15,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.yellow.withOpacity(0.15),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
