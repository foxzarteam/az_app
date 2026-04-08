import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/otp_models.dart';
import '../../core/utils/constants.dart';
import '../../services/firebase_bootstrap.dart';
import '../../services/otp_service.dart';
import '../../services/splash_flow_service.dart';
import '../../services/user_service.dart';

enum MpinLoginStatus {
  ok,
  mobileMissing,
  userNotFound,
  mobileMismatch,
  mpinNotSet,
  incorrectMpin,
}

class MpinLoginResult {
  const MpinLoginResult(this.status, {this.userName});

  final MpinLoginStatus status;
  final String? userName;
}

class AuthController extends ChangeNotifier {
  AuthController({
    required UserService users,
    required OtpService otp,
    required SplashFlowService splashFlow,
  })  : _users = users,
        _otp = otp,
        _splashFlow = splashFlow;

  final UserService _users;
  final OtpService _otp;
  final SplashFlowService _splashFlow;

  bool splashBusy = false;
  String? splashErrorKey;

  bool mpinBusy = false;

  Future<SplashRouteResult?> resolveSplash(SharedPreferences prefs) async {
    splashBusy = true;
    splashErrorKey = null;
    notifyListeners();
    try {
      return await _splashFlow.resolve(prefs);
    } catch (_) {
      splashErrorKey = 'msgErrorTryAgain';
      return null;
    } finally {
      splashBusy = false;
      notifyListeners();
    }
  }

  Future<bool> getLiveFlag() => _otp.getLiveFlag();

  Future<OTPResponse> sendOTP(String mobileNumber) =>
      _otp.sendOTP(mobileNumber);

  Future<OTPVerificationResponse> verifyOTP(String mobileNumber, String otp) =>
      _otp.verifyOTP(mobileNumber, otp);

  Future<void> signInWithFirebaseCredential(PhoneAuthCredential credential) {
    return FirebaseBootstrap.signInWithPhoneCredential(credential);
  }

  Future<MpinLoginResult> verifyMpin({
    required String enteredMpin,
    required SharedPreferences prefs,
  }) async {
    mpinBusy = true;
    notifyListeners();
    try {
      final mobileNumber = prefs.getString(AppConstants.keyMobileNumber) ?? '';
      if (mobileNumber.isEmpty) {
        return const MpinLoginResult(MpinLoginStatus.mobileMissing);
      }

      final dbUser = await _users.getUserByMobile(mobileNumber);
      if (dbUser == null) {
        await _clearStoredAuth(prefs);
        return const MpinLoginResult(MpinLoginStatus.userNotFound);
      }

      final dbMobileNumber = dbUser['mobile_number']?.toString() ?? '';
      if (dbMobileNumber != mobileNumber) {
        await _clearStoredAuth(prefs);
        return const MpinLoginResult(MpinLoginStatus.mobileMismatch);
      }

      final savedMPin = dbUser['mpin']?.toString().trim() ?? '';
      final userName = dbUser['user_name']?.toString() ??
          prefs.getString(AppConstants.keyUserName) ??
          AppConstants.defaultUserName;

      if (savedMPin.isEmpty) {
        return const MpinLoginResult(MpinLoginStatus.mpinNotSet);
      }

      if (savedMPin == enteredMpin) {
        await prefs.setString(AppConstants.keyMPin, enteredMpin);
        await prefs.setString(AppConstants.keyUserName, userName);
        await prefs.setBool(AppConstants.keyIsLoggedIn, true);
        await _users.updateUserLoginStatus(mobileNumber, true);
        return MpinLoginResult(MpinLoginStatus.ok, userName: userName);
      }

      return const MpinLoginResult(MpinLoginStatus.incorrectMpin);
    } finally {
      mpinBusy = false;
      notifyListeners();
    }
  }

  Future<void> _clearStoredAuth(SharedPreferences prefs) async {
    await prefs.remove(AppConstants.keyMobileNumber);
    await prefs.remove(AppConstants.keyMPin);
    await prefs.setBool(AppConstants.keyIsLoggedIn, false);
  }
}
