import '../config/app_config.dart';
import 'api_client.dart';
import '../models/active_service.dart';

class ServicesService {
  ServicesService(this._api);

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

  bool _rowActive(Map<String, dynamic> row) {
    final active = row['isActive'] ?? row['is_active'];
    return active != false;
  }

  /// GET /services — server returns only `is_active = true`, sorted by sort_order.
  Future<List<ActiveService>> fetchActiveServices({bool background = false}) async {
    final json = background
        ? await _api.getJson(
            '/services',
            timeout: AppConfig.servicesPollTimeout,
            maxRetries: AppConfig.servicesPollMaxRetries,
          )
        : await _api.getJson('/services');
    if (json == null || json['success'] != true) {
      return [];
    }

    final rows = _asListOfMap(json['data']);
    final services = <ActiveService>[];
    for (final row in rows) {
      if (!_rowActive(row)) continue;
      final item = ActiveService.fromMap(row);
      if (item.slug.isEmpty) continue;
      services.add(item);
    }

    services.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return services;
  }
}
