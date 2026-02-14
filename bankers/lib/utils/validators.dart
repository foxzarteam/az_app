import 'constants.dart';

bool isValidIndianMobile(String value) {
  if (value.length != AppConstants.mobileNumberLength) return false;
  return RegExp(AppConstants.mobileNumberPattern).hasMatch(value);
}

String? mobileValidationError(String? value) {
  if (value == null || value.isEmpty) return AppConstants.msgPleaseEnterMobile;
  if (value.length != AppConstants.mobileNumberLength) {
    return AppConstants.msgValidTenDigit;
  }
  if (!RegExp(AppConstants.mobileNumberPattern).hasMatch(value)) {
    return AppConstants.msgValidIndianNumber;
  }
  return null;
}
