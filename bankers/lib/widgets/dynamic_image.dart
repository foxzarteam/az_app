import 'package:flutter/material.dart';

class DynamicImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const DynamicImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _errorWidget();
    }

    return Image.network(
      imageUrl!,
      width: width,
      height: height,
      fit: fit,
      headers: const {'Accept': 'image/*'},
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _loadingWidget();
      },
      errorBuilder: (context, error, stackTrace) => _errorWidget(),
    );
  }

  Widget _loadingWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _errorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Icon(
        Icons.image_not_supported,
        color: Colors.grey[400],
        size: (height != null ? height! : 40) * 0.4,
      ),
    );
  }
}
