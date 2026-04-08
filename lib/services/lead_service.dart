import 'api_client.dart';

class CreateLeadResult {
  final bool success;
  final String? message;
  const CreateLeadResult({required this.success, this.message});
}

class _CacheEntry<T> {
  _CacheEntry(this.value) : createdAt = DateTime.now();
  final T value;
  final DateTime createdAt;
  bool isExpired(Duration ttl) => DateTime.now().difference(createdAt) > ttl;
}

class LeadService {
  LeadService(this._api);

  final ApiClient _api;
  static const Duration _ttl = Duration(seconds: 20);
  final Map<String, _CacheEntry<List<Map<String, dynamic>>>> _leadsByUser = {};

  List<Map<String, dynamic>> _asListOfMap(dynamic value) {
    if (value is! List) return [];
    return value
        .map((e) {
          if (e is Map<String, dynamic>) return e;
          if (e is Map) return e.map((k, v) => MapEntry(k.toString(), v));
          return null;
        })
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> getLeadsByUserId(String userId) async {
    final cached = _leadsByUser[userId];
    if (cached != null && !cached.isExpired(_ttl)) {
      return cached.value;
    }
    final json = await _api.getJson('/leads/user/$userId');
    if (json == null || json['success'] != true) {
      return [];
    }
    final leads = _asListOfMap(json['data']);
    _leadsByUser[userId] = _CacheEntry(leads);
    return leads;
  }

  void invalidateLeads(String userId) => _leadsByUser.remove(userId);

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

    final res = await _api.postWithStatus('/leads', body);
    if (res.networkError) {
      return const CreateLeadResult(
        success: false,
        message: 'Network error. Check connection and try again.',
      );
    }
    final json = res.json;
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
        _leadsByUser.remove(userId);
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
  }
}
