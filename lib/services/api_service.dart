import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'api_client.dart';

/// Central HTTP layer: GET, POST, PUT, PATCH. Base URL: [AppConfig.apiBaseUrl] only.
class ApiService implements ApiClient {
  ApiService._();
  static final ApiService instance = ApiService._();

  static String get _base => AppConfig.apiBaseUrl;
  static const Duration _requestTimeout = Duration(seconds: 8);
  static const int _maxRetries = 2;
  static const _retryableStatusCodes = {408, 429, 500, 502, 503, 504};

  static const _jsonHeaders = {'Content-Type': 'application/json'};

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

  Future<Map<String, dynamic>?> _parseMapResponse(
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

  @override
  Future<Map<String, dynamic>?> getJson(String path) {
    return _parseMapResponse(
      () => http.get(Uri.parse('$_base$path')),
    );
  }

  @override
  Future<Map<String, dynamic>?> postJson(
    String path,
    Map<String, dynamic> body,
  ) {
    return _parseMapResponse(
      () => http.post(
        Uri.parse('$_base$path'),
        headers: _jsonHeaders,
        body: jsonEncode(body),
      ),
    );
  }

  @override
  Future<Map<String, dynamic>?> putJson(
    String path,
    Map<String, dynamic> body,
  ) {
    return _parseMapResponse(
      () => http.put(
        Uri.parse('$_base$path'),
        headers: _jsonHeaders,
        body: jsonEncode(body),
      ),
    );
  }

  @override
  Future<Map<String, dynamic>?> patchJson(
    String path,
    Map<String, dynamic> body,
  ) {
    return _parseMapResponse(
      () => http.patch(
        Uri.parse('$_base$path'),
        headers: _jsonHeaders,
        body: jsonEncode(body),
      ),
    );
  }

  @override
  Future<ApiPostResult> postWithStatus(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await _sendWithRetry(
        () => http.post(
          Uri.parse('$_base$path'),
          headers: _jsonHeaders,
          body: jsonEncode(body),
        ),
      );
      if (res == null) {
        return const ApiPostResult(statusCode: 0, networkError: true);
      }
      Map<String, dynamic>? json;
      if (res.body.trim().isNotEmpty) {
        try {
          json = _asMap(jsonDecode(res.body));
        } catch (_) {
          json = null;
        }
      }
      return ApiPostResult(json: json, statusCode: res.statusCode);
    } catch (_) {
      return const ApiPostResult(statusCode: 0, networkError: true);
    }
  }
}
