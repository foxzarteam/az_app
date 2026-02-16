/// Asset paths for illustrations (FreePik-style images).
/// App images in res/images/ to avoid Flutter Web "assets/assets/" 404 bug.
class AppImages {
  AppImages._();

  static const String dashboardHero = 'res/images/dashboard_hero.png';
  static const String kycSuccess = 'res/images/kyc_success.png';
  static const List<String> carouselImages = [
    'res/images/dashboard_hero.png',
    'res/images/kyc_success.png',
  ];

  /// Personal loan share banner. Add personal_loan_share.png in res/images/.
  static const String personalLoanShare = 'res/images/personal_loan_share.png';

  /// Splash screen center logo (round). AZ icon image.
  static const String splashLogo = 'assets/icon.png';

  /// Lead form header banner. Place share.png in res/images/.
  static const String leadFormHeader = 'res/images/share.png';
}
