import 'package:flutter/foundation.dart';

import '../../services/banner_service.dart';

bool _isCarouselCategory(Map<String, dynamic> b) {
  final c = b['category']?.toString().toLowerCase().trim() ?? '';
  return c == 'carousel';
}

bool _isAbsoluteHttpUrl(String u) {
  final t = u.trim().toLowerCase();
  return t.startsWith('http://') || t.startsWith('https://');
}

class BannerController extends ChangeNotifier {
  BannerController({required BannerService banners}) : _banners = banners;

  final BannerService _banners;

  bool loading = false;
  String? errorKey;
  List<String> imageUrls = const [];

  Future<void> refresh() async {
    loading = true;
    errorKey = null;
    notifyListeners();
    try {
      final list = await _banners.fetchActiveBanners();
      final urls = <String>[];
      for (final b in list) {
        if (!_isCarouselCategory(b)) continue;
        final raw = b['imageUrl']?.toString().trim() ??
            b['image_url']?.toString().trim() ??
            '';
        if (raw.isEmpty) continue;
        // Only real network URLs. Relative paths like "images/banner.jpg" are not
        // Flutter asset paths — they were incorrectly sent to [Image.asset] and failed.
        if (_isAbsoluteHttpUrl(raw)) urls.add(raw);
      }
      imageUrls = urls;
    } catch (_) {
      errorKey = 'msgErrorTryAgain';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
