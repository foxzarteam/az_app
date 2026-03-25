import 'package:flutter/services.dart';

/// Preloads [refer.json] so the referral page shows Lottie quickly after first shell frame.
abstract final class ReferralLottieCache {
  static const String assetPath = 'assets/animation/refer.json';

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
