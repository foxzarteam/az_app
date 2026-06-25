class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = 'https://server-nu-bay-20.vercel.app/api';
  static const bool forceBackendOtp = false;

  static const Duration servicesStaleAfter = Duration(minutes: 3);
  static const Duration servicesMinRefreshGap = Duration(seconds: 10);
  static const Duration servicesPollTimeout = Duration(seconds: 5);
  static const int servicesPollMaxRetries = 0;
  static const bool servicesEnableSoftBackgroundPoll = false;
  static const Duration servicesSoftPollInterval = Duration(minutes: 5);

  static const String connectivityProbeUrl =
      'https://clients3.google.com/generate_204';

  static const String servicesShareBaseUrl =
      'https://www.apnizaroorat.com/services';

  static String shareApplyLinkForProduct(String productName) {
    final slug = productName.toLowerCase().replaceAll(' ', '-');
    return '$servicesShareBaseUrl/$slug';
  }
}
