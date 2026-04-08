import '../core/models/otp_models.dart';
import '../core/utils/constants.dart';
import '../core/utils/validators.dart';
import 'api_client.dart';

class OtpService {
  OtpService(this._api);

  final ApiClient _api;

  Future<OTPResponse> sendOTP(String mobileNumber) async {
    final error = mobileValidationError(mobileNumber);
    if (error != null) {
      return OTPResponse(success: false, message: error);
    }
    final json = await _api.postJson('/otp/send', {
      'mobileNumber': mobileNumber,
    });
    if (json == null) {
      return OTPResponse(success: false, message: 'msgNetworkError');
    }
    return OTPResponse(
      success: json['success'] == true,
      message: json['message'] as String?,
    );
  }

  Future<bool> getLiveFlag() async {
    final json = await _api.getJson('/otp/live');
    final value = json?['live'];
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return true;
  }

  Future<OTPVerificationResponse> verifyOTP(String mobileNumber, String otp) async {
    final mobileError = mobileValidationError(mobileNumber);
    if (mobileError != null) {
      return OTPVerificationResponse(success: false, message: mobileError);
    }
    if (otp.length != AppConstants.otpLength) {
      return OTPVerificationResponse(
        success: false,
        message: 'msgOtpMustBeDigits',
      );
    }
    final json = await _api.postJson('/otp/verify', {
      'mobileNumber': mobileNumber,
      'otp': otp,
    });
    if (json == null) {
      return OTPVerificationResponse(
        success: false,
        message: 'msgNetworkError',
      );
    }
    return OTPVerificationResponse(
      success: json['success'] == true,
      message: json['message'] as String?,
    );
  }
}
