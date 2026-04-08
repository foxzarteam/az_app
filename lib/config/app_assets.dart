/// Centralized asset paths — do not hardcode paths in widgets.
class AppAssets {
  AppAssets._();

  static const String imagesPath = 'assets/images';

  static const List<String> carousel = [
    '$imagesPath/carousel_1.png',
    '$imagesPath/carousel_2.png',
  ];

  static const String kycBanner = '$imagesPath/kyc_banner.png';
  static const String leadsPromo = '$imagesPath/leads_promo.png';
  static const String leadFormHeader = '$imagesPath/lead_form_header.png';
  static const String personalLoanPromo = '$imagesPath/personal_loan_promo.png';
  static const String creditCardPromo = '$imagesPath/credit_card_promo.png';
  static const String insurancePromo = '$imagesPath/insurance_promo.png';
  static const String splashLogo = 'assets/icon.png';
  static const String moneyLottie = 'assets/animation/money.json';
  static const String rupeesLottie = 'assets/animation/rupees.json';
  static const String referLottie = 'assets/animation/refer.json';

  /// Share-sheet product banners (`w1.png`–`w6.png`).
  static String? shareBannerForProduct(String productName) {
    switch (productName) {
      case 'Personal Loan':
        return '$imagesPath/w1.png';
      case 'Insurance':
        return '$imagesPath/w2.png';
      case 'Business Loan':
        return '$imagesPath/w3.png';
      case 'Home Loan':
        return '$imagesPath/w4.png';
      case 'Vehicle Loan':
        return '$imagesPath/w5.png';
      case 'Credit Card':
        return '$imagesPath/w6.png';
      default:
        return null;
    }
  }
}
