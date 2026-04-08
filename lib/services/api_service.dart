import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/otp_models.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

abstract class ApiServiceBase {
  Future<Map<String, dynamic>?> getUserByMobile(String mobile);
  Future<Map<String, dynamic>?> createUser({
    required String mobileNumber,
    String? userName,
    String? email,
  });
  Future<bool> updateUserMPin(String mobile, String mpin);
  Future<bool> updateUserLoginStatus(String mobile, bool isLoggedIn);
  Future<bool> updateUserProfile(
    String mobile, {
    String? userName,
    String? email,
  });
  Future<bool> upsertUser({
    required String mobileNumber,
    String? userName,
    String? email,
    String? mpin,
    bool? isLoggedIn,
  });
  Future<OTPResponse> sendOTP(String mobileNumber);
  Future<bool> getLiveFlag();
  Future<OTPVerificationResponse> verifyOTP(String mobileNumber, String otp);
  Future<List<Map<String, dynamic>>> getLeadsByUserId(String userId);
  Future<CreateLeadResult> createLead({
    required String pan,
    required String mobileNumber,
    required String fullName,
    String? email,
    String? pincode,
    double? requiredAmount,
    required String category,
    String? userId,
  });
  Future<Map<String, dynamic>?> getWallet(String userId);
  Future<List<Map<String, dynamic>>> getPaymentAccounts(String userId);
  Future<bool> savePaymentAccount(
    String userId, {
    required String paymentType,
    String? upiId,
    String? bankName,
    String? ifscCode,
  });
}

class CreateLeadResult {
  final bool success;
  final String? message;
  const CreateLeadResult({required this.success, this.message});
}

class ApiService implements ApiServiceBase {
  ApiService._();
  static final ApiService instance = ApiService._();

  static String get _base => AppConfig.baseUrl;
  static const Duration _requestTimeout = Duration(seconds: 8);
  static const int _maxRetries = 2;
  static const _retryableStatusCodes = {408, 429, 500, 502, 503, 504};

  static const _jsonHeaders = {'Content-Type': 'application/json'};
  final Map<String, _CacheEntry<Map<String, dynamic>?>> _userByMobileCache = {};
  final Map<String, _CacheEntry<Map<String, dynamic>?>> _walletCache = {};
  final Map<String, _CacheEntry<List<Map<String, dynamic>>>> _leadsCache = {};
  final Map<String, _CacheEntry<List<Map<String, dynamic>>>> _paymentAccountsCache = {};
  final Map<String, Future<dynamic>> _inFlightRequests = {};

  static const Duration _userCacheTtl = Duration(seconds: 45);
  static const Duration _walletCacheTtl = Duration(seconds: 20);
  static const Duration _leadsCacheTtl = Duration(seconds: 20);
  static const Duration _paymentAccountsCacheTtl = Duration(seconds: 30);

  Future<T> _runDeduped<T>(String key, Future<T> Function() task) {
    final existing = _inFlightRequests[key];
    if (existing != null) {
      return existing as Future<T>;
    }
    final future = task();
    _inFlightRequests[key] = future;
    future.whenComplete(() => _inFlightRequests.remove(key));
    return future;
  }

  Future<http.Response?> _sendWithRetry(
    Future<http.Response> Function() request,
  ) async {
    Object? lastError;
    for (var attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final res = await request().timeout(_requestTimeout);
        if (!_retryableStatusCodes.contains(res.statusCode) ||
            attempt == _maxRetries) {
          return res;
        }
      } catch (e) {
        lastError = e;
        if (attempt == _maxRetries) return null;
      }
      final backoffMs = 250 * (attempt + 1);
      await Future.delayed(Duration(milliseconds: backoffMs));
    }
    if (lastError != null) return null;
    return null;
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  List<Map<String, dynamic>> _asListOfMap(dynamic value) {
    if (value is! List) return [];
    return value
        .map(_asMap)
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }

  Future<Map<String, dynamic>?> _parseResponse(
    Future<http.Response> Function() request,
  ) async {
    try {
      final res = await _sendWithRetry(request);
      if (res == null) return null;
      if (res.statusCode >= 400) return null;
      if (res.body.trim().isEmpty) return null;
      return _asMap(jsonDecode(res.body));
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _get(String path) async {
    return _runDeduped(
      'GET:$path',
      () => _parseResponse(() => http.get(Uri.parse('$_base$path'))),
    );
  }

  Future<Map<String, dynamic>?> _post(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    return _parseResponse(
      () => http.post(
        Uri.parse('$_base$path'),
        headers: _jsonHeaders,
        body: jsonEncode(body),
      ),
    );
  }

  Future<Map<String, dynamic>?> _put(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    return _parseResponse(
      () => http.put(
        Uri.parse('$_base$path'),
        headers: _jsonHeaders,
        body: jsonEncode(body),
      ),
    );
  }

  Future<Map<String, dynamic>?> _patch(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    return _parseResponse(
      () => http.patch(
        Uri.parse('$_base$path'),
        headers: _jsonHeaders,
        body: jsonEncode(body),
      ),
    );
  }

  @override
  Future<Map<String, dynamic>?> getUserByMobile(String mobile) async {
    final cached = _userByMobileCache[mobile];
    if (cached != null && !cached.isExpired(_userCacheTtl)) {
      return cached.value;
    }
    final json = await _get('/users/mobile/$mobile');
    if (json == null || json['success'] != true) {
      _userByMobileCache[mobile] = _CacheEntry(null);
      return null;
    }
    final data = json['data'];
    final result = data is Map<String, dynamic> ? data : null;
    _userByMobileCache[mobile] = _CacheEntry(result);
    return result;
  }

  @override
  Future<Map<String, dynamic>?> createUser({
    required String mobileNumber,
    String? userName,
    String? email,
  }) async {
    final body = <String, dynamic>{'mobileNumber': mobileNumber};
    if (userName != null) body['userName'] = userName;
    if (email != null) body['email'] = email;
    final json = await _post('/users', body: body);
    if (json == null) return null;
    if (json['success'] != true) return null;
    final data = json['data'];
    return _asMap(data);
  }

  @override
  Future<bool> updateUserMPin(String mobile, String mpin) async {
    final json = await _patch(
      '/users/mobile/$mobile/mpin',
      body: {'mpin': mpin},
    );
    _userByMobileCache.remove(mobile);
    return json != null && json['success'] == true;
  }

  @override
  Future<bool> updateUserLoginStatus(String mobile, bool isLoggedIn) async {
    final json = await _patch(
      '/users/mobile/$mobile/login-status',
      body: {'isLoggedIn': isLoggedIn},
    );
    return json != null && json['success'] == true;
  }

  @override
  Future<bool> updateUserProfile(
    String mobile, {
    String? userName,
    String? email,
  }) async {
    final body = <String, dynamic>{};
    if (userName != null) body['userName'] = userName;
    if (email != null) body['email'] = email;
    final json = await _patch('/users/mobile/$mobile/profile', body: body);
    _userByMobileCache.remove(mobile);
    return json != null && json['success'] == true;
  }

  @override
  Future<bool> upsertUser({
    required String mobileNumber,
    String? userName,
    String? email,
    String? mpin,
    bool? isLoggedIn,
  }) async {
    final body = <String, dynamic>{'mobileNumber': mobileNumber};
    if (userName != null) body['userName'] = userName;
    if (email != null) body['email'] = email;
    if (mpin != null) body['mpin'] = mpin;
    if (isLoggedIn != null) body['isLoggedIn'] = isLoggedIn;
    final json = await _put('/users/upsert', body: body);
    _userByMobileCache.remove(mobileNumber);
    return json != null && json['success'] == true;
  }

  @override
  Future<OTPResponse> sendOTP(String mobileNumber) async {
    final error = mobileValidationError(mobileNumber);
    if (error != null) {
      return OTPResponse(success: false, message: error);
    }
    final json = await _post('/otp/send', body: {'mobileNumber': mobileNumber});
    if (json == null) {
      return OTPResponse(
        success: false,
        message: 'msgNetworkError',
      );
    }
    return OTPResponse(
      success: json['success'] == true,
      message: json['message'] as String?,
    );
  }

  @override
  Future<bool> getLiveFlag() async {
    final json = await _get('/otp/live');
    final value = json?['live'];
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    // If the flag can't be read (network/server issue), default to the safer path:
    // use Firebase phone auth.
    return true;
  }

  @override
  Future<OTPVerificationResponse> verifyOTP(
    String mobileNumber,
    String otp,
  ) async {
    final mobileError = mobileValidationError(mobileNumber);
    if (mobileError != null) {
      return OTPVerificationResponse(success: false, message: mobileError);
    }
    if (otp.length != AppConstants.otpLength) {
      return OTPVerificationResponse(
        success: false,
        message: 'msgOtpMustBeDigits',
      );
    }
    final json = await _post(
      '/otp/verify',
      body: {'mobileNumber': mobileNumber, 'otp': otp},
    );
    if (json == null) {
      return OTPVerificationResponse(
        success: false,
        message: 'msgNetworkError',
      );
    }
    return OTPVerificationResponse(
      success: json['success'] == true,
      message: json['message'] as String?,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getLeadsByUserId(String userId) async {
    final cached = _leadsCache[userId];
    if (cached != null && !cached.isExpired(_leadsCacheTtl)) {
      return cached.value;
    }
    final json = await _get('/leads/user/$userId');
    if (json == null || json['success'] != true) {
      return [];
    }
    final leads = _asListOfMap(json['data']);
    _leadsCache[userId] = _CacheEntry(leads);
    return leads;
  }

  @override
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
    final body = <String, dynamic>{
      'pan': pan,
      'mobileNumber': mobileNumber,
      'fullName': fullName,
      'category': category,
    };
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (pincode != null && pincode.isNotEmpty) body['pincode'] = pincode;
    if (requiredAmount != null) body['requiredAmount'] = requiredAmount;
    if (userId != null && userId.isNotEmpty) body['userId'] = userId;
    try {
      final res = await _sendWithRetry(
        () => http.post(
          Uri.parse('$_base/leads'),
          headers: _jsonHeaders,
          body: jsonEncode(body),
        ),
      );
      if (res == null) {
        return const CreateLeadResult(
          success: false,
          message: 'Network error. Check connection and try again.',
        );
      }
      final json = _asMap(jsonDecode(res.body));
      if (json == null) {
        return CreateLeadResult(
          success: false,
          message: res.statusCode >= 400
              ? 'Server error. Please try again.'
              : 'Invalid response from server.',
        );
      }
      final success = json['success'] == true;
      final data = json['data'];
      final msg = json['message']?.toString();
      if (success && data != null) {
        if (userId != null && userId.isNotEmpty) {
          _leadsCache.remove(userId);
        }
        return const CreateLeadResult(success: true);
      }
      final fallback = res.statusCode >= 400
          ? 'Request failed. Please try again.'
          : 'Lead could not be saved. Please try again.';
      return CreateLeadResult(
        success: false,
        message: (msg != null && msg.trim().isNotEmpty) ? msg : fallback,
      );
    } catch (_) {
      return const CreateLeadResult(
        success: false,
        message: 'Network error. Check connection and try again.',
      );
    }
  }

  @override
  Future<Map<String, dynamic>?> getWallet(String userId) async {
    final cached = _walletCache[userId];
    if (cached != null && !cached.isExpired(_walletCacheTtl)) {
      return cached.value;
    }
    final json = await _get('/wallet/user/$userId');
    if (json == null || json['success'] != true) return null;
    final data = json['data'];
    final result = _asMap(data);
    _walletCache[userId] = _CacheEntry(result);
    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> getPaymentAccounts(String userId) async {
    final cached = _paymentAccountsCache[userId];
    if (cached != null && !cached.isExpired(_paymentAccountsCacheTtl)) {
      return cached.value;
    }
    final json = await _get('/payment-accounts/user/$userId');
    if (json == null || json['success'] != true) return [];
    final accounts = _asListOfMap(json['data']);
    _paymentAccountsCache[userId] = _CacheEntry(accounts);
    return accounts;
  }

  @override
  Future<bool> savePaymentAccount(
    String userId, {
    required String paymentType,
    String? upiId,
    String? bankName,
    String? ifscCode,
  }) async {
    final body = <String, dynamic>{'paymentType': paymentType};
    if (upiId != null) body['upiId'] = upiId;
    if (bankName != null) body['bankName'] = bankName;
    if (ifscCode != null) body['ifscCode'] = ifscCode;
    final json = await _put('/payment-accounts/user/$userId', body: body);
    _walletCache.remove(userId);
    _paymentAccountsCache.remove(userId);
    return json != null && json['success'] == true;
  }
}

class _CacheEntry<T> {
  _CacheEntry(this.value) : createdAt = DateTime.now();

  final T value;
  final DateTime createdAt;

  bool isExpired(Duration ttl) => DateTime.now().difference(createdAt) > ttl;
}
