import 'api_client.dart';
import 'wallet_service.dart';

class _CacheEntry<T> {
  _CacheEntry(this.value) : createdAt = DateTime.now();
  final T value;
  final DateTime createdAt;
  bool isExpired(Duration ttl) => DateTime.now().difference(createdAt) > ttl;
}

class PaymentService {
  PaymentService(this._api, this._wallet);

  final ApiClient _api;
  final WalletService _wallet;
  static const Duration _ttl = Duration(seconds: 30);
  final Map<String, _CacheEntry<List<Map<String, dynamic>>>> _accountsByUser =
      {};

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

  Future<List<Map<String, dynamic>>> getPaymentAccounts(String userId) async {
    final cached = _accountsByUser[userId];
    if (cached != null && !cached.isExpired(_ttl)) {
      return cached.value;
    }
    final json = await _api.getJson('/payment-accounts/user/$userId');
    if (json == null || json['success'] != true) {
      return [];
    }
    final accounts = _asListOfMap(json['data']);
    _accountsByUser[userId] = _CacheEntry(accounts);
    return accounts;
  }

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
    final json = await _api.putJson('/payment-accounts/user/$userId', body);
    _wallet.invalidateWallet(userId);
    _accountsByUser.remove(userId);
    return json != null && json['success'] == true;
  }
}
