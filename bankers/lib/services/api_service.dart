import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/otp_models.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  static String get _base => ApiConfig.baseUrl;

  static const _jsonHeaders = {'Content-Type': 'application/json'};

  Future<Map<String, dynamic>?> _parseResponse(
    Future<http.Response> Function() request,
    String method,
    String path,
  ) async {
    try {
      final res = await request();
      if (res.statusCode >= 400) {
        return null;
      }
      return jsonDecode(res.body) as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _get(String path) async {
    return _parseResponse(
      () => http.get(Uri.parse('$_base$path')),
      'GET',
      path,
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
      'POST',
      path,
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
      'PUT',
      path,
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
      'PATCH',
      path,
    );
  }

  Future<Map<String, dynamic>?> getUserByMobile(String mobile) async {
    final json = await _get('/users/mobile/$mobile');
    if (json == null) return null;
    if (json['success'] != true) return null;
    final data = json['data'];
    return data is Map<String, dynamic> ? data : null;
  }

  Future<Map<String, dynamic>?> createUser({
    required String mobileNumber,
    String? userName,
    String? email,
  }) async {
    final body = <String, dynamic>{
      'mobileNumber': mobileNumber,
      if (userName != null) 'userName': userName,
      if (email != null) 'email': email,
    };
    final json = await _post('/users', body: body);
    if (json == null) return null;
    if (json['success'] != true) return null;
    final data = json['data'];
    return data is Map<String, dynamic> ? data : null;
  }

  Future<bool> updateUserMPin(String mobile, String mpin) async {
    final json = await _patch(
      '/users/mobile/$mobile/mpin',
      body: {'mpin': mpin},
    );
    return json != null && json['success'] == true;
  }

  Future<bool> updateUserLoginStatus(String mobile, bool isLoggedIn) async {
    final json = await _patch(
      '/users/mobile/$mobile/login-status',
      body: {'isLoggedIn': isLoggedIn},
    );
    return json != null && json['success'] == true;
  }

  Future<bool> updateUserProfile(
    String mobile, {
    String? userName,
    String? email,
  }) async {
    final body = <String, dynamic>{};
    if (userName != null) body['userName'] = userName;
    if (email != null) body['email'] = email;
    final json = await _patch('/users/mobile/$mobile/profile', body: body);
    return json != null && json['success'] == true;
  }

  Future<bool> upsertUser({
    required String mobileNumber,
    String? userName,
    String? email,
    String? mpin,
    bool? isLoggedIn,
  }) async {
    final body = <String, dynamic>{
      'mobileNumber': mobileNumber,
      if (userName != null) 'userName': userName,
      if (email != null) 'email': email,
      if (mpin != null) 'mpin': mpin,
      if (isLoggedIn != null) 'isLoggedIn': isLoggedIn,
    };
    final json = await _put('/users/upsert', body: body);
    return json != null && json['success'] == true;
  }

  Future<OTPResponse> sendOTP(String mobileNumber) async {
    final error = mobileValidationError(mobileNumber);
    if (error != null) {
      return OTPResponse(success: false, message: error);
    }
    final json = await _post('/otp/send', body: {'mobileNumber': mobileNumber});
    if (json == null) {
      return OTPResponse(
        success: false,
        message: AppConstants.msgNetworkError,
      );
    }
    return OTPResponse(
      success: json['success'] == true,
      message: json['message'] as String?,
    );
  }

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
        message: AppConstants.msgOtpMustBeDigits,
      );
    }
    final json = await _post(
      '/otp/verify',
      body: {'mobileNumber': mobileNumber, 'otp': otp},
    );
    if (json == null) {
      return OTPVerificationResponse(
        success: false,
        message: AppConstants.msgNetworkError,
      );
    }
    return OTPVerificationResponse(
      success: json['success'] == true,
      message: json['message'] as String?,
    );
  }

  Future<bool> createLead({
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
      if (email != null && email.isNotEmpty) 'email': email,
      if (pincode != null && pincode.isNotEmpty) 'pincode': pincode,
      if (requiredAmount != null) 'requiredAmount': requiredAmount,
      if (userId != null && userId.isNotEmpty) 'userId': userId,
    };
    final json = await _post('/leads', body: body);
    return json != null && json['success'] == true;
  }

  Future<List<Map<String, dynamic>>> getBanners({String? category}) async {
    final path = category != null ? '/banners/category/$category' : '/banners';
    final json = await _get(path);
    if (json == null || json['success'] != true) {
      return [];
    }
    final data = json['data'];
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
