import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Phone Auth opened a browser reCAPTCHA flow and lost state (common without SHA keys).
bool isFirebasePhoneSetupError(FirebaseAuthException e) {
  final code = e.code.toLowerCase();
  final msg = (e.message ?? '').toLowerCase();
  if (code == 'web-context-cancelled' ||
      code == 'web-context-canceled' ||
      code == 'missing-client-identifier' ||
      code == 'invalid-app-credential' ||
      code == 'app-not-authorized') {
    return true;
  }
  return msg.contains('sessionstorage') ||
      msg.contains('initial state') ||
      msg.contains('missing initial state') ||
      msg.contains('signinwithredirect');
}

bool isFirebasePhoneSetupMessage(String? message) {
  final msg = (message ?? '').toLowerCase();
  return msg.contains('sessionstorage') ||
      msg.contains('initial state') ||
      msg.contains('missing initial state') ||
      msg.contains('signinwithredirect');
}
