import 'constants.dart';

bool isValidIndianMobile(String value) {
  if (value.length != AppConstants.mobileNumberLength) return false;
  return RegExp(AppConstants.mobileNumberPattern).hasMatch(value);
}

/// Returns translation key for UI (use context.t(key)); null when valid.
String? mobileValidationError(String? value) {
  if (value == null || value.isEmpty) return 'msgPleaseEnterMobile';
  if (value.length != AppConstants.mobileNumberLength) return 'msgValidTenDigit';
  if (!RegExp(AppConstants.mobileNumberPattern).hasMatch(value)) return 'msgValidIndianNumber';
  return null;
}

/// UPI: either 10-digit Indian mobile OR UPI ID (contains @, e.g. name@paytm, name@ybl)
bool isValidUpiIdOrMobile(String value) {
  final t = value.trim();
  if (t.isEmpty) return false;
  if (t.length == AppConstants.mobileNumberLength &&
      RegExp(AppConstants.mobileNumberPattern).hasMatch(t)) {
    return true;
  }
  if (t.contains('@') && t.length >= 5 && t.length <= 100) return true;
  return false;
}

String? upiValidationError(String? value) {
  if (value == null || value.trim().isEmpty) return 'msgEnterUpiOrMobile';
  if (!isValidUpiIdOrMobile(value)) return 'msgInvalidUpi';
  return null;
}

/// IFSC: 11 chars, first 4 letters, 5th is 0, last 6 alphanumeric
bool isValidIfsc(String value) {
  final t = value.trim().toUpperCase();
  if (t.length != 11) return false;
  return RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(t);
}

String? ifscValidationError(String? value) {
  if (value == null || value.trim().isEmpty) return 'msgEnterIfsc';
  if (!isValidIfsc(value)) return 'msgInvalidIfsc';
  return null;
}

/// Account number: 9–18 digits (Indian bank account)
bool isValidAccountNumber(String value) {
  final t = value.trim();
  if (t.length < 9 || t.length > 18) return false;
  return RegExp(r'^\d{9,18}$').hasMatch(t);
}

String? accountNumberValidationError(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  if (!isValidAccountNumber(value)) return 'msgInvalidAccountNumber';
  return null;
}
