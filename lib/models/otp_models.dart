/// Data models for OTP operations.
class OTPRequest {
  final String mobileNumber;
  final String? message;
  final String route;

  OTPRequest({
    required this.mobileNumber,
    this.message,
    this.route = 'otp',
  });

  Map<String, dynamic> toJson() {
    return {
      'numbers': mobileNumber,
      if (message != null) 'message': message,
      'route': route,
    };
  }
}

class OTPResponse {
  final bool success;
  final String? message;
  final String? requestId;
  final Map<String, dynamic>? data;

  OTPResponse({
    required this.success,
    this.message,
    this.requestId,
    this.data,
  });

  factory OTPResponse.fromJson(Map<String, dynamic> json) {
    return OTPResponse(
      success: json['return'] == true,
      message: json['message'] as String?,
      requestId: json['request_id'] as String?,
      data: json,
    );
  }
}

class OTPVerificationRequest {
  final String mobileNumber;
  final String otp;

  OTPVerificationRequest({
    required this.mobileNumber,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'mobile_number': mobileNumber,
      'otp': otp,
    };
  }
}

class OTPVerificationResponse {
  final bool success;
  final String? message;

  OTPVerificationResponse({
    required this.success,
    this.message,
  });
}
