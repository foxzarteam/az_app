import 'package:flutter/foundation.dart';

import '../../core/utils/constants.dart';
import '../../services/user_service.dart';

enum MpinSaveStatus {
  ok,
  invalidLength,
  apiFailed,
  verifyMismatch,
}

class UserController extends ChangeNotifier {
  UserController({required UserService users}) : _users = users;

  final UserService _users;

  bool saving = false;
  String? errorKey;

  bool mpinBusy = false;

  Future<Map<String, dynamic>?> getUserByMobile(String mobile) =>
      _users.getUserByMobile(mobile);

  Future<bool> upsertUser({
    required String mobileNumber,
    String? userName,
    String? email,
    String? mpin,
    bool? isLoggedIn,
  }) =>
      _users.upsertUser(
        mobileNumber: mobileNumber,
        userName: userName,
        email: email,
        mpin: mpin,
        isLoggedIn: isLoggedIn,
      );

  Future<bool> updateUserLoginStatus(String mobile, bool isLoggedIn) =>
      _users.updateUserLoginStatus(mobile, isLoggedIn);

  Future<bool> updateUserProfile(
    String mobile, {
    String? userName,
    String? email,
  }) async {
    saving = true;
    errorKey = null;
    notifyListeners();
    try {
      final ok =
          await _users.updateUserProfile(mobile, userName: userName, email: email);
      if (!ok) errorKey = 'msgErrorTryAgain';
      return ok;
    } catch (_) {
      errorKey = 'msgErrorTryAgain';
      return false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<MpinSaveStatus> saveMpin({
    required String mobileNumber,
    required String userName,
    required String trimmedPin,
  }) async {
    if (trimmedPin.length != AppConstants.mpinLength) {
      return MpinSaveStatus.invalidLength;
    }

    mpinBusy = true;
    notifyListeners();
    try {
      final success = await _users.upsertUser(
        mobileNumber: mobileNumber,
        userName: userName,
        mpin: trimmedPin,
        isLoggedIn: true,
      );
      if (!success) return MpinSaveStatus.apiFailed;

      final verifyUser = await _users.getUserByMobile(mobileNumber);
      final savedMPin = verifyUser?['mpin']?.toString().trim() ?? '';
      if (savedMPin != trimmedPin) return MpinSaveStatus.verifyMismatch;

      return MpinSaveStatus.ok;
    } finally {
      mpinBusy = false;
      notifyListeners();
    }
  }
}
