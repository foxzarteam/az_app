import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

/// Shared helper for user data from SharedPreferences. Reuse instead of duplicating in screens.
class UserPrefsHelper {
  UserPrefsHelper._();

  static Future<Map<String, String>> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'mobile': prefs.getString(AppConstants.keyMobileNumber) ?? AppConstants.defaultMaskedMobile,
      'email': prefs.getString(AppConstants.keyEmail) ?? '',
    };
  }

  static Future<String> getMobileNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyMobileNumber) ?? AppConstants.defaultMaskedMobile;
  }

  /// Stable referral code for this user; generated and saved on first use.
  /// Uses a single [SharedPreferences] load to avoid slow double [getInstance] calls.
  static Future<String> getOrCreateReferralCode() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(AppConstants.keyReferralCode);
    if (existing != null && existing.length == 8) return existing;
    final mobile =
        prefs.getString(AppConstants.keyMobileNumber) ?? AppConstants.defaultMaskedMobile;
    final code = deriveReferralCodeFromMobile(mobile);
    try {
      await prefs.setString(AppConstants.keyReferralCode, code);
    } catch (_) {
      // Still return code for this session if persist fails.
    }
    return code;
  }

  /// Sync helper for timeouts / error paths (same algorithm as stored code).
  static String deriveReferralCodeFromMobile(String mobile) => _deriveReferralCode(mobile);

  static String _deriveReferralCode(String mobile) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final digits = mobile.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 6) {
      return List.generate(8, (_) => chars[Random().nextInt(chars.length)]).join();
    }
    final seed = digits.hashCode.abs();
    final rnd = Random(seed);
    return List.generate(8, (_) => chars[rnd.nextInt(chars.length)]).join();
  }
}
