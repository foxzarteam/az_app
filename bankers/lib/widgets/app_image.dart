import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Loads image from app assets. Use paths from AppConfig.
class AppImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: AppTheme.secondaryBackground,
      child: Icon(Icons.image_not_supported, color: AppTheme.lightText, size: (height ?? 40) * 0.4),
    );
  }
}
