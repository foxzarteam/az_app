import 'package:flutter/services.dart';

import '../../config/app_assets.dart';

/// Preloads referral Lottie so the referral page shows animation quickly after first shell frame.
abstract final class ReferralLottieCache {
  static String get assetPath => AppAssets.referLottie;

  static Uint8List? _bytes;

  static Uint8List? get bytes => _bytes;

  static void remember(Uint8List data) {
    if (_bytes != null) return;
    _bytes = Uint8List.fromList(data);
  }

  static Future<void> warmUp() async {
    if (_bytes != null) return;
    try {
      final bd = await rootBundle.load(assetPath);
      _bytes = bd.buffer.asUint8List();
    } catch (_) {}
  }
}
