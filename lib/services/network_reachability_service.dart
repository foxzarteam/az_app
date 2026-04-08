import 'package:http/http.dart' as http;

import '../config/app_config.dart';

/// HTTP reachability probe — used by [NetworkGuard], not by feature screens.
class NetworkReachabilityService {
  NetworkReachabilityService._();
  static final NetworkReachabilityService instance = NetworkReachabilityService._();

  static const Duration _timeout = Duration(seconds: 2);

  Future<bool> hasInternet() async {
    try {
      final response = await http
          .get(Uri.parse(AppConfig.connectivityProbeUrl))
          .timeout(_timeout);
      return response.statusCode == 204 ||
          (response.statusCode >= 200 && response.statusCode < 400);
    } catch (_) {
      return false;
    }
  }
}
