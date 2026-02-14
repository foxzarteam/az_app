import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Shows an illustration from assets. If image is missing, shows a placeholder.
class IllustrationImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const IllustrationImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(AppConstants.mainBackground),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.image_outlined,
        size: (height != null ? height! : 80) * 0.4,
        color: const Color(AppConstants.lightText),
      ),
    );
  }
}
