/// Result of a raw POST (status + parsed body when possible).
class ApiPostResult {
  const ApiPostResult({
    this.json,
    required this.statusCode,
    this.networkError = false,
  });

  final Map<String, dynamic>? json;
  final int statusCode;
  final bool networkError;
}

/// Central HTTP contract. Single implementation: [ApiService].
abstract class ApiClient {
  Future<Map<String, dynamic>?> getJson(String path);
  Future<Map<String, dynamic>?> postJson(String path, Map<String, dynamic> body);
  Future<Map<String, dynamic>?> putJson(String path, Map<String, dynamic> body);
  Future<Map<String, dynamic>?> patchJson(
    String path,
    Map<String, dynamic> body,
  );
  Future<ApiPostResult> postWithStatus(String path, Map<String, dynamic> body);
}
