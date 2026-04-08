import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/l10n/app_locale.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/constants.dart';
import '../../core/widgets/message_banner.dart';
import '../shell/main_shell_screen.dart';
import 'mpin_set_screen.dart';
import 'auth_controller.dart';
import '../profile/user_controller.dart';

enum OtpVerifyMode { firebasePhone, backendDb }

class OTPVerificationScreen extends StatefulWidget {
  final String mobileNumber;
  final OtpVerifyMode mode;
  final String? verificationId; // required for firebasePhone mode
  final bool isResetMPIN;

  const OTPVerificationScreen({
    super.key,
    required this.mobileNumber,
    required this.mode,
    this.verificationId,
    this.isResetMPIN = false,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();

  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  int _resendCooldown = 0;

  bool get _isFirebaseMode => widget.mode == OtpVerifyMode.firebasePhone;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _otpFocusNode.requestFocus();
      if (!_isFirebaseMode) {
        _startResendCooldown();
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _startResendCooldown() {
    _resendCooldown = AppConstants.otpResendCooldownSeconds;
    setState(() {});
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendCooldown--);
      return _resendCooldown > 0;
    });
  }

  Future<void> _saveAndRoute({required String userName}) async {
    final users = context.read<UserController>();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyMobileNumber, widget.mobileNumber);
    await prefs.setString(AppConstants.keyUserName, userName);
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
    await prefs.setBool(AppConstants.keyHasSignedUpOnDevice, true);

    await users.updateUserLoginStatus(widget.mobileNumber, true);

    if (!mounted) return;

    if (widget.isResetMPIN) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MPinSetScreen(
            userName: userName,
            mobileNumber: widget.mobileNumber,
            isResetMPIN: true,
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MainShellScreen(userName: userName),
      ),
    );
  }

  Future<void> _continueAfterSuccess() async {
    final refreshedUser = await context
        .read<UserController>()
        .getUserByMobile(widget.mobileNumber);

    final userName = refreshedUser?['user_name']?.toString() ??
        AppConstants.defaultUserName;
    await _saveAndRoute(userName: userName);
  }

  Future<void> _verifyViaFirebase(String otp) async {
    final verificationId = widget.verificationId;
    if (verificationId == null) {
      setState(() => _errorMessage = 'msgErrorTryAgain');
      return;
    }

    final auth = context.read<AuthController>();
    final users = context.read<UserController>();
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    await auth.signInWithFirebaseCredential(credential);

    final dbUser = await users.getUserByMobile(widget.mobileNumber);
    if (dbUser == null && !widget.isResetMPIN) {
      final ok = await users.upsertUser(
        mobileNumber: widget.mobileNumber,
        userName: AppConstants.defaultUserName,
        isLoggedIn: true,
      );
      if (!ok) {
        setState(() => _errorMessage = 'msgFailedCreateAccount');
        return;
      }
    }

    await _continueAfterSuccess();
  }

  Future<void> _verifyViaBackend(String otp) async {
    final auth = context.read<AuthController>();
    final users = context.read<UserController>();
    final response = await auth.verifyOTP(widget.mobileNumber, otp);
    if (!response.success) {
      setState(() {
        _errorMessage = response.message ?? 'msgInvalidOtp';
      });
      _otpController.clear();
      _otpFocusNode.requestFocus();
      return;
    }

    final dbUser = await users.getUserByMobile(widget.mobileNumber);
    if (dbUser == null) {
      if (widget.isResetMPIN) {
        setState(() => _errorMessage = 'msgNumberNotRegistered');
        return;
      }

      final ok = await users.upsertUser(
        mobileNumber: widget.mobileNumber,
        userName: AppConstants.defaultUserName,
        isLoggedIn: true,
      );
      if (!ok) {
        setState(() => _errorMessage = 'msgFailedCreateAccount');
        return;
      }
    }

    await _continueAfterSuccess();
  }

  Future<void> _onOtpChanged(String value) async {
    setState(() {
      _errorMessage = null;
    });

    if (value.length != AppConstants.otpLength) return;
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isFirebaseMode) {
        await _verifyViaFirebase(value.trim());
      } else {
        await _verifyViaBackend(value.trim());
      }
    } catch (_) {
      setState(() => _errorMessage = 'msgErrorTryAgain');
      _otpController.clear();
      _otpFocusNode.requestFocus();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_isFirebaseMode) return; // firebase mode resend handled by firebase flow
    if (_resendCooldown > 0 || _isResending) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    final res =
        await context.read<AuthController>().sendOTP(widget.mobileNumber);

    if (!mounted) return;

    setState(() => _isResending = false);

    if (!res.success) {
      setState(() => _errorMessage = res.message ?? 'msgErrorTryAgain');
      return;
    }

    _otpController.clear();
    _otpFocusNode.requestFocus();
    _startResendCooldown();
  }

  @override
  Widget build(BuildContext context) {
    const accentOrange = AppTheme.accentOrange;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryBlueDark,
                  AppTheme.primaryBlue,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 55),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.t('msgVerifyOtp'),
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _otpController,
                          focusNode: _otpFocusNode,
                          keyboardType: TextInputType.number,
                          maxLength: AppConstants.otpLength,
                          enabled: !_isLoading && !_isResending,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(
                              AppConstants.otpLength,
                            ),
                          ],
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: accentOrange,
                            letterSpacing: 1.5,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: 'Enter 6 digit OTP here',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.lightText,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: accentOrange.withValues(alpha: 0.35),
                                width: 2,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: _errorMessage != null
                                    ? AppTheme.error
                                    : accentOrange,
                                width: 3,
                              ),
                            ),
                          ),
                          onChanged: _onOtpChanged,
                        ),
                        const SizedBox(height: 12),
                        if (_errorMessage != null)
                          MessageBanner(
                            message: context.tOrRaw(_errorMessage!),
                            type: MessageBannerType.error,
                          ),
                        if (_isResending || _isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: CircularProgressIndicator(),
                          ),
                        if (!_isFirebaseMode) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: (_resendCooldown > 0 ||
                                    _isLoading ||
                                    _isResending)
                                ? null
                                : _resendOtp,
                            child: Text(
                              _resendCooldown > 0
                                  ? AppConstants.otpResendCountdown(
                                      _resendCooldown,
                                    )
                                  : AppConstants.labelResendOtp,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: accentOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

