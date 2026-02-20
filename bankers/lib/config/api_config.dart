import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    const String? envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    }
    
    return 'http://localhost:3000/api';
  }
}
