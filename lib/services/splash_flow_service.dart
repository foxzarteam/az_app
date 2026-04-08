import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/constants.dart';
import 'user_service.dart';

sealed class SplashRouteResult {
  const SplashRouteResult();
}

class SplashRouteMpinLogin extends SplashRouteResult {
  const SplashRouteMpinLogin();
}

class SplashRouteMainShell extends SplashRouteResult {
  const SplashRouteMainShell(this.userName);
  final String userName;
}

class SplashRouteSignup extends SplashRouteResult {
  const SplashRouteSignup();
}

class SplashFlowService {
  SplashFlowService({required UserService users}) : _users = users;

  final UserService _users;

  static const Duration _syncTimeout = Duration(milliseconds: 900);

  Future<SplashRouteResult> resolve(SharedPreferences prefs) async {
    final mobileNumber = prefs.getString(AppConstants.keyMobileNumber);
    final hasSignedUpOnDevice =
        prefs.getBool(AppConstants.keyHasSignedUpOnDevice) ?? false;

    var localMpin = prefs.getString(AppConstants.keyMPin)?.trim();
    if (localMpin != null && localMpin.isEmpty) localMpin = null;

    if (localMpin != null) {
      return const SplashRouteMpinLogin();
    }

    if (mobileNumber != null && mobileNumber.isNotEmpty) {
      Map<String, dynamic>? dbUser;
      try {
        dbUser = await _users
            .getUserByMobile(mobileNumber)
            .timeout(_syncTimeout);
      } catch (_) {
        dbUser = null;
      }
      if (dbUser != null) {
        final userName = dbUser['user_name']?.toString();
        if (userName != null && userName.isNotEmpty) {
          await prefs.setString(AppConstants.keyUserName, userName);
        }
        final serverMpin = dbUser['mpin']?.toString().trim() ?? '';
        if (serverMpin.isNotEmpty) {
          await prefs.setString(AppConstants.keyMPin, serverMpin);
          return const SplashRouteMpinLogin();
        }
      }
    }

    if (hasSignedUpOnDevice) {
      final userName =
          prefs.getString(AppConstants.keyUserName) ??
              AppConstants.defaultUserName;
      return SplashRouteMainShell(userName);
    }

    return const SplashRouteSignup();
  }
}
