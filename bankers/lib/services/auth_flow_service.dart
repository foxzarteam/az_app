import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';
import 'api_service.dart';

enum SignUpNextRoute {
  otpVerification,
  mpinLogin,
  stayWithError,
}

class SignUpFlowResult {
  final SignUpNextRoute route;
  final String? errorMessage;
  final String mobileNumber;
  final String userName;
  final bool isExistingUser;
  final bool isResetMPIN;

  SignUpFlowResult({
    required this.route,
    this.errorMessage,
    required this.mobileNumber,
    required this.userName,
    this.isExistingUser = false,
    this.isResetMPIN = false,
  });
}

class AuthFlowService {
  AuthFlowService._();
  static final AuthFlowService instance = AuthFlowService._();

  final _api = ApiService.instance;

  Future<void> clearStaleSessionIfMobileChanged(
    SharedPreferences prefs,
    String currentMobile,
  ) async {
    final storedMobile = prefs.getString(AppConstants.keyMobileNumber);
    if (storedMobile != null && storedMobile != currentMobile) {
      await prefs.remove(AppConstants.keyMPin);
      await prefs.setBool(AppConstants.keyIsLoggedIn, false);
    }
  }

  Future<String> resolveUserName(
    String mobileNumber,
    SharedPreferences prefs,
  ) async {
    final dbUser = await _api.getUserByMobile(mobileNumber);
    if (dbUser != null) {
      return dbUser['user_name']?.toString() ??
          prefs.getString(AppConstants.keyUserName) ??
          AppConstants.defaultUserName;
    }
    final created = await _api.createUser(
      mobileNumber: mobileNumber,
      userName: AppConstants.defaultUserName,
    );
    return created?['user_name']?.toString() ?? AppConstants.defaultUserName;
  }

  Future<SignUpFlowResult> runSignUpFlow({
    required String mobileNumber,
    required String userName,
    required bool isForgotMPIN,
    required SharedPreferences prefs,
  }) async {
    await prefs.setString(AppConstants.keyMobileNumber, mobileNumber);
    await prefs.setString(AppConstants.keyUserName, userName);

    final dbUser = await _api.getUserByMobile(mobileNumber);
    final accountExists = dbUser != null;
    final existingMPin = dbUser?['mpin']?.toString();
    final hasMPin =
        existingMPin != null && existingMPin.isNotEmpty;

    if (isForgotMPIN) {
      if (!accountExists) {
        return SignUpFlowResult(
          route: SignUpNextRoute.stayWithError,
          errorMessage: AppConstants.msgNumberNotRegistered,
          mobileNumber: mobileNumber,
          userName: userName,
        );
      }
      return SignUpFlowResult(
        route: SignUpNextRoute.otpVerification,
        mobileNumber: mobileNumber,
        userName: userName,
        isExistingUser: true,
        isResetMPIN: true,
      );
    }

    if (accountExists && hasMPin) {
      await prefs.setString(AppConstants.keyMPin, existingMPin);
      await prefs.setBool(AppConstants.keyIsLoggedIn, true);
      await _api.updateUserLoginStatus(mobileNumber, true);
      return SignUpFlowResult(
        route: SignUpNextRoute.mpinLogin,
        mobileNumber: mobileNumber,
        userName: userName,
      );
    }

    return SignUpFlowResult(
      route: SignUpNextRoute.otpVerification,
      mobileNumber: mobileNumber,
      userName: userName,
      isExistingUser: accountExists,
    );
  }

  Future<String?> ensureUserAndGetUserName(
    String mobileNumber,
    SharedPreferences prefs,
  ) async {
    final dbUser = await _api.getUserByMobile(mobileNumber);
    if (dbUser != null) {
      return dbUser['user_name']?.toString() ??
          prefs.getString(AppConstants.keyUserName) ??
          AppConstants.defaultUserName;
    }
    final created = await _api.createUser(
      mobileNumber: mobileNumber,
      userName: AppConstants.defaultUserName,
    );
    if (created == null) return null;
    return created['user_name']?.toString() ?? AppConstants.defaultUserName;
  }
}
