class AppConstants {
  // OTP UI configuration (actual sending is done by backend)
  static const int otpLength = 4;
  static const int otpExpirationMinutes = 5;
  static const int otpResendCooldownSeconds = 60;

  // Indian mobile validation
  static const int mobileNumberLength = 10;
  static const String mobileNumberPattern = r'^[6-9]\d{9}$';

  // Colors — premium blue theme (orange accent), no purple
  static const int primaryColor = 0xFF2320E7;       // Premium blue
  static const int primaryColorDark = 0xFF1A1BC7;   // Darker blue for gradients
  static const int accentColor = 0xFFFF6B35;        // Orange (kept)
  static const int yellowAccent = 0xFFFFD700;
  static const int primaryColorHover = 0xFF3D3AFF;
  static const int accentColorHover = 0xFFFF8C42;
  static const int mainBackground = 0xFFF0F5FA;
  static const int cardBackground = 0xFFFFFFFF;
  static const int secondaryBackground = 0xFFF0F5FA;
  static const int primaryText = 0xFF3C3C3C;
  static const int secondaryText = 0xFF666666;
  static const int lightText = 0xFF999999;
  static const int borderColor = 0xFFE0E0E0;
  static const int dividerColor = 0xFFF0F5FA;
  static const int successColor = 0xFF10B981;
  static const int errorColor = 0xFFEF4444;
  static const int warningColor = 0xFFF59E0B;

  // SharedPreferences Keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserName = 'user_name';
  static const String keyMobileNumber = 'mobile_number';
  static const String keyEmail = 'email';
  static const String keyMPin = 'mpin';
  static const String keyPincode = 'pincode';
  static const String keyOtpExpiry = 'otp_expiry';
  static const String keyOtpValue = 'otp_value';

  // Default / placeholder strings
  static const String defaultUserName = 'User';
  static const String defaultMaskedMobile = '**********';
  static const String hintMobilePlaceholder = '1234567890';

  // User-facing messages (no hardcoded strings in UI)
  static const String msgFailedCreateAccount =
      'Failed to create account. Please try again.';
  static const String msgNumberNotRegistered = 'This number is not registered';
  static const String msgErrorTryAgain = 'An error occurred. Please try again.';
  static const String msgNetworkError = 'Network error. Please try again.';
  static const String msgInvalidOtp = 'Invalid OTP. Please try again.';
  static const String msgOtpResent = 'OTP resent successfully!';
  static const String msgResendOtpFailed = 'Failed to resend OTP';
  static const String msgDidntReceiveOtp = "Didn't receive OTP? ";
  static const String msgResendOtp = 'Resend OTP';
  static const String msgInvalidMpin = 'Invalid MPIN. Please enter 4 digits.';
  static const String msgFailedSaveMpin = 'Failed to save MPIN. Please try again.';
  static const String msgMpinVerifyFailed =
      'MPIN verification failed. Please try again.';
  static const String msgMpinResetSuccess = 'Your MPIN reset successfully';
  static const String msgMobileNotFound = 'Mobile number not found. Please signup again.';
  static const String msgUserNotFound = 'User not found. Please signup again.';
  static const String msgMobileMismatch = 'Mobile number mismatch. Please signup again.';
  static const String msgMpinNotSet = 'MPIN not set. Please set MPIN first.';
  static const String msgIncorrectMpin = 'Incorrect MPIN. Please try again.';
  static const String msgTermsPrivacy = 'By continuing, you agree to our Terms & Privacy';
  static const String msgSelectCountry = 'Select Country';
  static const String msgContinue = 'Continue';
  static const String msgGetStarted = 'Get Started';
  static const String msgResetMpin = 'Reset MPIN';
  static const String msgMobileNumber = 'Mobile Number';
  static const String msgForgotMpinClick = 'If you forget MPIN click here';
  static const String msgSetMpinTitle = 'Set Your MPIN';
  static const String msgSetMpinSubtitle =
      'Create a 4-digit PIN to secure your account';
  static const String msgRememberPin = "Remember this PIN. You'll need it to login.";
  static const String msgVerifyOtp = 'Verify OTP';
  static const String msgEnterOtpSentTo = 'Enter the OTP sent to';
  static const String msgLoginByMpin = 'Login by MPIN';
  static const String msgEnterMpin = 'Enter your 4-digit MPIN';
  static const String msgMyQrCode = 'My QR Code';

  // Personal details form
  static const String labelFullName = 'Full Name';
  static const String labelMobileNumber = 'Mobile Number';
  static const String labelEmail = 'Email';
  static const String labelPinCode = 'Pin Code';
  static const String labelSubmit = 'Submit';
  static const String hintEmail = 'your@email.com';
  static const String hintPinCode = 'e.g. 110001';
  static const String msgProfileUpdated = 'Profile updated successfully';

  // Validation messages (used by validators)
  static const String msgPleaseEnterMobile = 'Please enter mobile number';
  static const String msgValidTenDigit = 'Enter valid 10-digit number';
  static const String msgValidIndianNumber = 'Enter valid Indian number';
  static const String msgOtpMustBeDigits = 'OTP must be 4 digits';

  // Dashboard / Share — default message + apply link (image shared from assets)
  static const String shareTitlePersonalLoan = 'Share Personal Loan';
  static const String shareApplyLink = 'https://example.com/apply';
  static String get shareMessagePersonalLoan =>
      'Hello 👋\n\n'
      'You can now get a 100% digital personal loan without any paperwork.\n\n'
      '✅ Instant Loan\n'
      '✅ Hassle-Free Process\n'
      '✅ Quick Approval\n'
      '💰 Loan up to ₹5 Lakhs\n\n'
      'Apply Now : $shareApplyLink';
  static const String shareSubjectPersonalLoan = 'Instant Personal Loan - 100% Digital, Up to ₹5 Lakh';
  static const String shareLabelMail = 'Mail';
  static const String shareLabelWhatsApp = 'WhatsApp';
  static const String shareLabelInstagram = 'Instagram';

  // Profile drawer
  static const String labelProfile = 'Profile';
  static const String labelPersonalDetails = 'Personal Details';
  static const String labelMyLead = 'My Lead';
  static const String labelPrivacyPolicy = 'Privacy Policy';
  static const String labelSettings = 'Settings';
  static const String subtitlePersonalDetails = 'View and edit your profile';
  static const String subtitleMyLead = 'Manage your leads';
  static const String subtitlePrivacyPolicy = 'Read our privacy policy';
  static const String subtitleSettings = 'App preferences and more';

  // Leads screen
  static const String titleAddLeadsEarn = 'Add leads & earn instantly';
  static const String subtitleReferLeads = 'Refer leads & get paid directly';
  static const String labelTotalEarnings = '₹ Total Earnings';
  static const String labelTotalAddedLeads = 'Total Added Leads';
  static const String subtitleSeeAllLeads = 'See all leads here';
  static const String labelViewDetails = 'View Details';
  static const String labelSuccess = 'Success';
  static const String labelInProcess = 'In Process';
  static const String labelRejected = 'Rejected';
  static const String labelActionRequired = 'Action Required';
  static const String titleAddLeadsEarnRewards = 'Add Leads & Earn Rewards!';
  static const String subtitleGetPaidPerLead = 'Get paid for every successful lead';
  static const String bannerEarnPerLead = 'Earn Up to ₹1000 Per Lead';
  static const String buttonAddLeadNow = 'Add Lead Now';

  // Bottom nav
  static const String labelToGold = 'To Gold';
  static const String labelHome = 'Home';
  static const String labelLeads = 'Leads';
  static const String labelReferral = 'Referral';
  static const String labelMyLeads = 'My Leads';
}
