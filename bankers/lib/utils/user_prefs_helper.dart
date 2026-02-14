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
}
