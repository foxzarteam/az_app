import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/constants.dart';

void main() {
  test('maps product to banner asset', () {
    expect(
      AppConstants.shareBannerAssetForProduct('Personal Loan'),
      equals('assets/images/w1.png'),
    );
    expect(
      AppConstants.shareBannerAssetForProduct('Credit Card'),
      equals('assets/images/w6.png'),
    );
    expect(AppConstants.shareBannerAssetForProduct('Unknown'), isNull);
  });

  test('builds product apply link slug correctly', () {
    final url = AppConstants.shareApplyLinkForProduct('Home Loan');
    expect(url, contains('/home-loan'));
  });

  test('builds referral whatsapp message with code', () {
    final msg = AppConstants.referralWhatsAppMessage('AB12CD34');
    expect(msg, contains('AB12CD34'));
    expect(msg, contains(AppConstants.referralMarketingSiteUrl));
    expect(msg, contains(AppConstants.appName));
  });
}
