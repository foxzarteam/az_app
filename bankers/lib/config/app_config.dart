class AppConfig {
  AppConfig._();

  static const String baseUrl =  'https://az-app-khaki.vercel.app/api';

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
}
