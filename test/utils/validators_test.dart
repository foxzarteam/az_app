import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/validators.dart';

void main() {
  group('mobile validation', () {
    test('accepts valid indian number', () {
      expect(isValidIndianMobile('9876543210'), isTrue);
      expect(mobileValidationError('9876543210'), isNull);
    });

    test('rejects invalid indian numbers', () {
      expect(isValidIndianMobile('5876543210'), isFalse);
      expect(mobileValidationError('12345'), isNotNull);
      expect(mobileValidationError(''), equals('msgPleaseEnterMobile'));
    });
  });

  group('UPI validation', () {
    test('accepts valid upi and mobile', () {
      expect(isValidUpiIdOrMobile('name@ybl'), isTrue);
      expect(isValidUpiIdOrMobile('9876543210'), isTrue);
      expect(upiValidationError('name@okaxis'), isNull);
    });

    test('rejects invalid upi/mobile', () {
      expect(isValidUpiIdOrMobile('abcd'), isFalse);
      expect(upiValidationError('abcd'), equals('msgInvalidUpi'));
      expect(upiValidationError(''), equals('msgEnterUpiOrMobile'));
    });
  });

  group('IFSC validation', () {
    test('accepts valid IFSC', () {
      expect(isValidIfsc('SBIN0001234'), isTrue);
      expect(ifscValidationError('SBIN0001234'), isNull);
    });

    test('rejects invalid IFSC', () {
      expect(isValidIfsc('ABCDE123456'), isFalse);
      expect(ifscValidationError('ABCDE123456'), equals('msgInvalidIfsc'));
    });
  });

  group('account validation', () {
    test('accepts valid account number', () {
      expect(isValidAccountNumber('123456789012'), isTrue);
      expect(accountNumberValidationError('123456789012'), isNull);
    });

    test('rejects invalid account number', () {
      expect(isValidAccountNumber('12345'), isFalse);
      expect(
        accountNumberValidationError('12345'),
        equals('msgInvalidAccountNumber'),
      );
    });
  });
}
