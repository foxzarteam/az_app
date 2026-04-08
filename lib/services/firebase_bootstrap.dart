import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Call [ensureInitialized] before [runApp] so [FirebaseAuth.instance] is safe.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static Future<void>? _future;

  static Future<void> ensureInitialized() {
    return _future ??= _init();
  }

  static Future<void> _init() async {
    if (Firebase.apps.isNotEmpty) return;
    try {
      await Firebase.initializeApp().timeout(const Duration(seconds: 8));
    } catch (e, st) {
      debugPrint('Firebase.initializeApp failed: $e\n$st');
    }
  }

  /// Await [ensureInitialized] first; throws if Firebase did not start (e.g. missing config).
  static Future<void> signInWithPhoneCredential(PhoneAuthCredential credential) async {
    await ensureInitialized();
    if (Firebase.apps.isEmpty) {
      throw StateError(
        'Firebase is not initialized. Add Firebase config or use backend OTP (live=false).',
      );
    }
    await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
