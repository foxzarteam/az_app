import 'api_client.dart';

class BannerService {
  BannerService(this._api);

  final ApiClient _api;

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

  Future<List<Map<String, dynamic>>> fetchActiveBanners() async {
    final json = await _api.getJson('/banners');
    if (json == null || json['success'] != true) {
      return [];
    }
    return _asListOfMap(json['data']);
  }
}
