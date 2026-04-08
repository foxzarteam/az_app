import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_image.dart';

bool _isNetworkImagePath(String path) {
  final p = path.toLowerCase().trim();
  return p.startsWith('http://') || p.startsWith('https://');
}

bool _isBundledAssetPath(String path) {
  final p = path.trim();
  return p.startsWith('assets/');
}

class CarouselBanner extends StatefulWidget {
  final List<String> assetPaths;
  final Duration autoScrollDuration;

  const CarouselBanner({
    super.key,
    required this.assetPaths,
    this.autoScrollDuration = const Duration(seconds: 4),
  });

  @override
  State<CarouselBanner> createState() => _CarouselBannerState();
}

class _CarouselBannerState extends State<CarouselBanner> {
  late PageController _pageController;
  Timer? _autoScrollTimer;
  bool _isPaused = false;
  static const int _initialPage = 1000;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  List<String> get _allImages => widget.assetPaths;

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (_isPaused || _allImages.isEmpty) return;
    _autoScrollTimer = Timer.periodic(widget.autoScrollDuration, (_) {
      if (_isPaused) return;
      final next = (_pageController.page ?? 0).round() + 1;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _pause() {
    if (!_isPaused) {
      setState(() => _isPaused = true);
      _autoScrollTimer?.cancel();
    }
  }

  void _resume() {
    if (_isPaused) {
      setState(() => _isPaused = false);
      _startAutoScroll();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_allImages.isEmpty) return const SizedBox.shrink();
    return Listener(
      onPointerDown: (_) => _pause(),
      onPointerUp: (_) => Future.delayed(const Duration(seconds: 2), _resume),
      onPointerCancel: (_) => Future.delayed(const Duration(seconds: 2), _resume),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = width / 3;
            return SizedBox(
              width: width,
              height: height,
              child: PageView.builder(
                controller: _pageController,
                itemCount: 10000,
                itemBuilder: (context, index) {
                  final path = _allImages[index % _allImages.length];
                  if (_isNetworkImagePath(path)) {
                    return Image.network(
                      path,
                      width: width,
                      height: height,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _carouselImagePlaceholder(width, height),
                    );
                  }
                  if (_isBundledAssetPath(path)) {
                    return AppImage(
                      assetPath: path,
                      width: width,
                      height: height,
                      fit: BoxFit.cover,
                    );
                  }
                  // e.g. "images/banner.jpg" — not a Flutter asset, would fail in [Image.asset].
                  return _carouselImagePlaceholder(width, height);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget _carouselImagePlaceholder(double? width, double? height) {
  return Container(
    width: width,
    height: height,
    color: AppTheme.secondaryBackground,
    child: Icon(
      Icons.image_not_supported,
      color: AppTheme.lightText,
      size: (height ?? 40) * 0.4,
    ),
  );
}
