import 'dart:async';
import 'package:flutter/material.dart';
import 'illustration_image.dart';

class CarouselBanner extends StatefulWidget {
  final List<String> imagePaths;
  final List<String>? imageUrls; // Network image URLs
  final double height;
  final Duration autoScrollDuration;

  const CarouselBanner({
    super.key,
    this.imagePaths = const [],
    this.imageUrls,
    this.height = 120,
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

  List<String> get _allImages {
    final urls = widget.imageUrls ?? [];
    return urls.isNotEmpty ? urls : widget.imagePaths;
  }

  bool get _isNetworkImage {
    return widget.imageUrls != null && widget.imageUrls!.isNotEmpty;
  }

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
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: 10000,
            itemBuilder: (context, index) {
              final image = _allImages[index % _allImages.length];
              if (_isNetworkImage) {
                return Image.network(
                  image,
                  width: double.infinity,
                  height: widget.height,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: widget.height,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                        size: 40,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: double.infinity,
                      height: widget.height,
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                );
              } else {
                return IllustrationImage(
                  assetPath: image,
                  width: double.infinity,
                  height: widget.height,
                  fit: BoxFit.cover,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
