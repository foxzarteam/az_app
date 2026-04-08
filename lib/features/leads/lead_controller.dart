import 'package:flutter/foundation.dart';

import '../../core/utils/constants.dart';
import '../../services/lead_service.dart';
import '../../services/user_service.dart';

class LeadController extends ChangeNotifier {
  LeadController({
    required UserService users,
    required LeadService leads,
  })  : _users = users,
        _leads = leads;

  final UserService _users;
  final LeadService _leads;

  static List<Map<String, dynamic>>? sharedCache;

  List<Map<String, dynamic>> items = sharedCache ?? const [];
  bool loading = false;
  String? errorKey;

  bool submitting = false;
  String? formErrorKey;

  static String _statusOf(Map<String, dynamic> lead) =>
      lead['status']?.toString().trim().toLowerCase() ?? '';

  static Map<String, dynamic> _normalizeLead(Map<String, dynamic> lead) {
    return {
      ...lead,
      'status': _statusOf(lead),
      'full_name': lead['full_name']?.toString() ?? '',
      'mobile_number': lead['mobile_number']?.toString() ?? '',
    };
  }

  Future<void> refresh(String mobile) async {
    loading = true;
    errorKey = null;
    notifyListeners();
    try {
      if (mobile.isEmpty || mobile == AppConstants.defaultMaskedMobile) {
        items = const [];
        return;
      }
      final user = await _users.getUserByMobile(mobile);
      final userId = user?['id']?.toString();
      if (userId == null || userId.isEmpty) {
        items = const [];
        return;
      }
      final raw = await _leads.getLeadsByUserId(userId);
      final normalized =
          raw.map(_normalizeLead).toList(growable: false);
      sharedCache = normalized;
      items = normalized;
    } catch (_) {
      errorKey = 'msgErrorTryAgain';
      items = sharedCache ?? const [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<CreateLeadResult> createLead({
    required String pan,
    required String mobileNumber,
    required String fullName,
    String? email,
    String? pincode,
    double? requiredAmount,
    required String category,
    String? userId,
  }) async {
    submitting = true;
    formErrorKey = null;
    notifyListeners();
    try {
      return _leads.createLead(
        pan: pan,
        mobileNumber: mobileNumber,
        fullName: fullName,
        email: email,
        pincode: pincode,
        requiredAmount: requiredAmount,
        category: category,
        userId: userId,
      );
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getUserByMobile(String mobile) =>
      _users.getUserByMobile(mobile);
}
