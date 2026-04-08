import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/validators.dart';

void main() {
  test('mobile validator accepts valid number', () {
    expect(mobileValidationError('9876543210'), isNull);
  });

  test('mobile validator rejects invalid number', () {
    expect(mobileValidationError('12345'), isNotNull);
  });
}
