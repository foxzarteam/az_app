import 'package:flutter/foundation.dart';

import '../../core/utils/constants.dart';
import '../../services/payment_service.dart';
import '../../services/user_service.dart';
import '../../services/wallet_service.dart';

String walletNumToDisplay(dynamic v) {
  if (v == null) return '0.00';
  if (v is int) return v == 0 ? '0.00' : v.toString();
  if (v is double) return v.toStringAsFixed(2);
  final s = v.toString().trim();
  return s.isEmpty ? '0.00' : s;
}

class WalletController extends ChangeNotifier {
  WalletController({
    required UserService users,
    required WalletService wallet,
    required PaymentService payments,
  })  : _users = users,
        _wallet = wallet,
        _payments = payments;

  final UserService _users;
  final WalletService _wallet;
  final PaymentService _payments;

  String balanceStr = '0.00';
  String earningStr = '0.00';
  bool summaryLoading = false;
  String? summaryErrorKey;

  Future<void> refreshWalletSummary(String mobile) async {
    if (mobile.isEmpty || mobile == AppConstants.defaultMaskedMobile) {
      return;
    }
    summaryLoading = true;
    summaryErrorKey = null;
    notifyListeners();
    try {
      final user = await _users.getUserByMobile(mobile);
      final userId = user?['id']?.toString();
      if (userId == null || userId.isEmpty) {
        return;
      }
      final data = await _wallet.getWallet(userId);
      if (data != null) {
        balanceStr = walletNumToDisplay(data['balance']);
        earningStr = walletNumToDisplay(data['earning']);
      }
    } catch (_) {
      summaryErrorKey = 'msgErrorTryAgain';
    } finally {
      summaryLoading = false;
      notifyListeners();
    }
  }

  bool loading = false;
  String? userId;
  String balanceDisplay = '0.00';
  String? savedUpi;
  String? savedBankName;
  String? savedIfscCode;
  String? errorKey;

  static String numToDisplay(dynamic v) {
    if (v == null) return '0.00';
    if (v is int) return v.toString();
    if (v is double) return v.toStringAsFixed(2);
    final s = v.toString().trim();
    return s.isEmpty ? '0.00' : s;
  }

  Future<void> refresh(String mobile) async {
    if (mobile.isEmpty || mobile == AppConstants.defaultMaskedMobile) {
      userId = null;
      notifyListeners();
      return;
    }
    loading = true;
    errorKey = null;
    notifyListeners();
    try {
      final user = await _users.getUserByMobile(mobile);
      final uid = user?['id']?.toString();
      if (uid == null || uid.isEmpty) {
        userId = null;
        return;
      }
      final results = await Future.wait<dynamic>([
        _payments.getPaymentAccounts(uid),
        _wallet.getWallet(uid),
      ]);
      final list = results[0] as List<Map<String, dynamic>>;
      final wallet = results[1] as Map<String, dynamic>?;

      String? upi;
      String? bankName;
      String? ifsc;
      for (final row in list) {
        final type = row['payment_type']?.toString();
        if (type == 'upi') {
          upi = row['upi_id']?.toString();
        } else if (type == 'bank') {
          bankName = row['bank_name']?.toString();
          ifsc = row['ifsc_code']?.toString();
        }
      }

      userId = uid;
      savedUpi = upi;
      savedBankName = bankName;
      savedIfscCode = ifsc;
      if (wallet != null) {
        balanceDisplay = numToDisplay(wallet['balance']);
      }
    } catch (_) {
      errorKey = 'msgErrorTryAgain';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> saveUpiAccount(String uid, String upiId) {
    return _payments.savePaymentAccount(
      uid,
      paymentType: 'upi',
      upiId: upiId,
    );
  }

  Future<bool> saveBankAccount(
    String uid, {
    required String bankName,
    required String ifscCode,
  }) {
    return _payments.savePaymentAccount(
      uid,
      paymentType: 'bank',
      bankName: bankName,
      ifscCode: ifscCode,
    );
  }
}
