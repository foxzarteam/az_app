import 'api_client.dart';

class _CacheEntry<T> {
  _CacheEntry(this.value) : createdAt = DateTime.now();
  final T value;
  final DateTime createdAt;
  bool isExpired(Duration ttl) => DateTime.now().difference(createdAt) > ttl;
}

class UserService {
  UserService(this._api);

  final ApiClient _api;

  static const Duration _userTtl = Duration(seconds: 45);
  final Map<String, _CacheEntry<Map<String, dynamic>?>> _byMobile = {};

  Future<Map<String, dynamic>?> getUserByMobile(String mobile) async {
    final cached = _byMobile[mobile];
    if (cached != null && !cached.isExpired(_userTtl)) {
      return cached.value;
    }
    final json = await _api.getJson('/users/mobile/$mobile');
    if (json == null || json['success'] != true) {
      _byMobile[mobile] = _CacheEntry(null);
      return null;
    }
    final data = json['data'];
    final result = data is Map<String, dynamic> ? data : null;
    _byMobile[mobile] = _CacheEntry(result);
    return result;
  }

  void invalidateMobile(String mobile) => _byMobile.remove(mobile);

  Future<Map<String, dynamic>?> createUser({
    required String mobileNumber,
    String? userName,
    String? email,
  }) async {
    final body = <String, dynamic>{'mobileNumber': mobileNumber};
    if (userName != null) body['userName'] = userName;
    if (email != null) body['email'] = email;
    final json = await _api.postJson('/users', body);
    if (json == null) return null;
    if (json['success'] != true) return null;
    final data = json['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }
    return null;
  }

  Future<bool> updateUserMPin(String mobile, String mpin) async {
    final json = await _api.patchJson(
      '/users/mobile/$mobile/mpin',
      {'mpin': mpin},
    );
    _byMobile.remove(mobile);
    return json != null && json['success'] == true;
  }

  Future<bool> updateUserLoginStatus(String mobile, bool isLoggedIn) async {
    final json = await _api.patchJson(
      '/users/mobile/$mobile/login-status',
      {'isLoggedIn': isLoggedIn},
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
    final json = await _api.patchJson('/users/mobile/$mobile/profile', body);
    _byMobile.remove(mobile);
    return json != null && json['success'] == true;
  }

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
    final json = await _api.putJson('/users/upsert', body);
    _byMobile.remove(mobileNumber);
    return json != null && json['success'] == true;
  }
}
