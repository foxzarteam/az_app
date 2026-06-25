import 'package:http/http.dart' as http;

import '../config/app_config.dart';

/// Real internet check (not just Wi‑Fi icon). Used by [NetworkGuard].
class NetworkReachabilityService {
  NetworkReachabilityService._();
  static final NetworkReachabilityService instance =
      NetworkReachabilityService._();

  static const Duration _probeTimeout = Duration(seconds: 2);

  static List<Uri> get _probeUrls => [
        Uri.parse(AppConfig.connectivityProbeUrl),
        Uri.parse('${AppConfig.apiBaseUrl}/health'),
      ];

  Future<bool> hasInternet() async {
    final probes = _probeUrls.map(_probe).toList(growable: false);
    final results = await Future.wait(probes);
    return results.any((ok) => ok);
  }

  Future<bool> _probe(Uri uri) async {
    try {
      final response = await http.get(uri).timeout(_probeTimeout);
      if (response.statusCode == 204) return true;
      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (_) {
      return false;
    }
  }
}
