import 'api_client.dart';

class _CacheEntry<T> {
  _CacheEntry(this.value) : createdAt = DateTime.now();
  final T value;
  final DateTime createdAt;
  bool isExpired(Duration ttl) => DateTime.now().difference(createdAt) > ttl;
}

class WalletService {
  WalletService(this._api);

  final ApiClient _api;
  static const Duration _ttl = Duration(seconds: 20);
  final Map<String, _CacheEntry<Map<String, dynamic>?>> _walletByUser = {};

  Future<Map<String, dynamic>?> getWallet(String userId) async {
    final cached = _walletByUser[userId];
    if (cached != null && !cached.isExpired(_ttl)) {
      return cached.value;
    }
    final json = await _api.getJson('/wallet/user/$userId');
    if (json == null || json['success'] != true) return null;
    final data = json['data'];
    Map<String, dynamic>? result;
    if (data is Map<String, dynamic>) {
      result = data;
    } else if (data is Map) {
      result = data.map((k, v) => MapEntry(k.toString(), v));
    }
    _walletByUser[userId] = _CacheEntry(result);
    return result;
  }

  void invalidateWallet(String userId) => _walletByUser.remove(userId);
}
