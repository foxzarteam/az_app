/// App constants: strings, keys, numbers only. All colors are in app_theme.dart.
class AppConstants {
  // OTP UI configuration (actual sending is done by backend)
  static const int otpLength = 6;
  static const int otpExpirationMinutes = 5;
  static const int otpResendCooldownSeconds = 60;

  // MPIN is fixed-length (separate from OTP length).
  static const int mpinLength = 4;

  static const String appName = 'Apni Zaroorat';

  // Indian mobile validation
  static const int mobileNumberLength = 10;
  static const String mobileNumberPattern = r'^[6-9]\d{9}$';

  // SharedPreferences Keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserName = 'user_name';
  static const String keyMobileNumber = 'mobile_number';
  static const String keyEmail = 'email';
  static const String keyMPin = 'mpin';
  static const String keyPincode = 'pincode';
  static const String keyOtpExpiry = 'otp_expiry';
  static const String keyOtpValue = 'otp_value';
  static const String keyAppLocale = 'app_locale';
  static const String keyHasSignedUpOnDevice = 'has_signed_up_on_device';

  // Default / placeholder strings
  static const String defaultUserName = 'User';
  static const String defaultMaskedMobile = '**********';
  static const String hintMobilePlaceholder = '1234567890';

  // User-facing messages (no hardcoded strings in UI)
  static const String msgFailedCreateAccount =
      'Failed to create account. Please try again.';
  static const String msgNumberNotRegistered = 'This number is not registered';
  static const String msgLeadAlreadyExists =
      'This lead already exists in our system.';
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
  static const String titleInsufficientBalance = 'Insufficient balance';
  static const String msgInsufficientBalanceWithdraw =
      'You do not have sufficient balance to withdraw.';
  static const String labelOk = 'OK';

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
  static const String msgOtpMustBeDigits = 'OTP must be 6 digits';

  // Payment (UPI / IFSC) validation
  static const String msgEnterUpiOrMobile = 'Enter UPI ID or 10-digit mobile number';
  static const String msgInvalidUpi = 'Enter valid UPI ID (e.g. name@upi) or 10-digit mobile';
  static const String msgEnterIfsc = 'Enter IFSC code';
  static const String msgInvalidIfsc = 'IFSC must be 11 characters (e.g. SBIN0001234)';
  static const String msgEnterBankNameAndIfsc = 'Enter bank name and IFSC code';
  static const String labelEdit = 'Edit';

  // Dashboard / Share — Apni Zaroorat service URLs
  static const String shareTitlePersonalLoan = 'Share Personal Loan';
  static const String _shareBaseUrl = 'https://www.apnizaroorat.com/services';

  /// Apply URL for the selected product (Personal Loan, Home Loan, Credit Card, etc.).
  static String shareApplyLinkForProduct(String productName) {
    final slug = productName.toLowerCase().replaceAll(' ', '-');
    return '$_shareBaseUrl/$slug';
  }

  static String get shareMessagePersonalLoan =>
      'Hello 👋\n\n'
      'You can now get a 100% digital personal loan without any paperwork.\n\n'
      '✅ Instant Loan\n'
      '✅ Hassle-Free Process\n'
      '✅ Quick Approval\n'
      '💰 Loan up to ₹5 Lakhs\n\n'
      'Apply Now : ${shareApplyLinkForProduct('Personal Loan')}';
  static const String shareSubjectPersonalLoan = 'Instant Personal Loan - 100% Digital, Up to ₹5 Lakh';

  /// Template message and subject for share sheet by product (e.g. Personal Loan, Home Loan). Uses Apni Zaroorat URL for that product.
  static String shareMessageForProduct(String productName) {
    final applyUrl = shareApplyLinkForProduct(productName);
    return 'Hello 👋\n\n'
        'You can now get a 100% digital $productName without any paperwork.\n\n'
        '✅ Instant Process\n'
        '✅ Hassle-Free\n'
        '✅ Quick Approval\n'
        '💰 Best offers\n\n'
        'Apply Now : $applyUrl';
  }
  static String shareSubjectForProduct(String productName) =>
      'Instant $productName - 100% Digital';

  static const String shareLabelMail = 'Mail';
  static const String shareLabelWhatsApp = 'WhatsApp';
  static const String shareLabelInstagram = 'Instagram';

  // Profile drawer
  static const String labelProfile = 'Profile';
  static const String labelPersonalDetails = 'Personal Details';
  static const String labelMyLead = 'My Lead';
  static const String labelPrivacyPolicy = 'Privacy Policy';
  static const String labelSettings = 'Settings';
  static const String labelPaymentSettings = 'Payment Settings';
  static const String labelWallet = 'Wallet';
  static const String subtitleWallet = 'Withdraw & payment methods';
  static const String subtitlePersonalDetails = 'View and edit your profile';
  static const String subtitleMyLead = 'Manage your leads';
  static const String subtitlePrivacyPolicy = 'Read our privacy policy';
  static const String subtitleSettings = 'App preferences and more';
  static const String subtitlePaymentSettings = 'UPI & bank account details';
  static const String labelEarning = 'Earning';
  static const String subtitleEarning = 'Withdraw & payment methods';
  static const String labelWithdraw = 'WITHDRAW';
  static const String labelWithdrawAmount = 'Withdraw amount';
  static const String hintEnterAmount = 'Enter amount';
  static const String labelUpi = 'UPI';
  static const String labelUpiSubtitle = 'GPay, PhonePe, BHIM & more';
  static const String labelBankTransfer = 'Transfer to';
  static const String labelBankAc = 'Bank A/C';

  // Leads screen
  static const String titleAddLeadsEarn = 'Add leads & earn instantly';
  static const String subtitleReferLeads = 'Refer leads & get paid directly';
  static const String labelTotalEarnings = '₹ Total Earnings';
  static const String labelTotalAddedLeads = 'Total Added Leads';
  static const String subtitleSeeAllLeads = 'See all leads here';
  static const String labelViewDetails = 'View Details';
  static const String labelSuccess = 'Success';
  static const String labelInProcess = 'Pending';
  static const String labelRejected = 'Rejected';
  static const String labelActionRequired = 'Action Required';
  static const String titleAddLeadsEarnRewards = 'Add Leads & Earn Rewards!';
  static const String subtitleGetPaidPerLead = 'Get paid for every successful lead';
  static const String bannerEarnPerLead = 'Earn Up to ₹1000 Per Lead';
  static const String buttonAddLeadNow = 'Add Lead Now';
  static const String buttonAddLeadManually = 'Add a New Lead Manually';
  static const String shareToCustomer = 'Share to Customer';
  static const String labelFavourite = 'Favourite';
  static const String labelInstantPayouts = 'INSTANT PAYOUTS';
  static const String earnUptoPrefix = 'Earn Upto';

  // Bottom nav
  static const String labelToGold = 'To Gold';
  static const String labelHome = 'Home';
  static const String labelLeads = 'Leads';
  static const String labelReferral = 'Referral';
  static const String labelMyLeads = 'Earning';
}
