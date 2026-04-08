/// Non-asset configuration. Asset paths: [AppAssets].
class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = 'https://server-nu-bay-20.vercel.app/api';

  static const String connectivityProbeUrl =
      'https://clients3.google.com/generate_204';

  static const String servicesShareBaseUrl =
      'https://www.apnizaroorat.com/services';

  static String shareApplyLinkForProduct(String productName) {
    final slug = productName.toLowerCase().replaceAll(' ', '-');
    return '$servicesShareBaseUrl/$slug';
  }
}
