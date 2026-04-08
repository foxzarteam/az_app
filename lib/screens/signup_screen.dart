import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_locale.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/animated_error_banner.dart';
import '../services/api_service.dart';
import 'main_shell_screen.dart';
import 'mpin_set_screen.dart';
import 'otp_verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  final bool isForgotMPIN;

  const SignUpScreen({super.key, this.isForgotMPIN = false});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final mobileNumber = _mobileController.text.trim();
    final validationError = mobileValidationError(mobileNumber);
    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear stale MPIN if user changes mobile.
      final storedMobile = prefs.getString(AppConstants.keyMobileNumber);
      if (storedMobile != null && storedMobile != mobileNumber) {
        await prefs.remove(AppConstants.keyMPin);
        await prefs.setBool(AppConstants.keyIsLoggedIn, false);
      }
      await prefs.setString(AppConstants.keyMobileNumber, mobileNumber);

      final dbUser = await ApiService.instance.getUserByMobile(mobileNumber);
      final accountExists = dbUser != null;

      // Forgot MPIN: only allow if number is already registered.
      if (widget.isForgotMPIN && !accountExists) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'msgNumberNotRegistered';
          });
        }
        return;
      }

      final live = await ApiService.instance.getLiveFlag();

      if (live) {
        // LIVE=true: Firebase Phone Auth sends OTP to phone.
        bool didNavigate = false;

        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: '+91$mobileNumber',
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) async {
            if (didNavigate || !mounted) return;
            try {
              setState(() => _isLoading = true);
              await FirebaseAuth.instance.signInWithCredential(credential);

              final refreshedUser =
                  await ApiService.instance.getUserByMobile(mobileNumber);

              if (refreshedUser == null) {
                if (widget.isForgotMPIN) {
                  setState(() {
                    _isLoading = false;
                    _errorMessage = 'msgNumberNotRegistered';
                  });
                  return;
                }

                final ok = await ApiService.instance.upsertUser(
                  mobileNumber: mobileNumber,
                  userName: AppConstants.defaultUserName,
                  isLoggedIn: true,
                );
                if (!ok) {
                  setState(() {
                    _isLoading = false;
                    _errorMessage = 'msgFailedCreateAccount';
                  });
                  return;
                }
              }

              final userName =
                  refreshedUser?['user_name']?.toString() ??
                      AppConstants.defaultUserName;
              final prefs2 = await SharedPreferences.getInstance();
              await prefs2.setString(
                AppConstants.keyMobileNumber,
                mobileNumber,
              );
              await prefs2.setString(
                AppConstants.keyUserName,
                userName,
              );
              await prefs2.setBool(AppConstants.keyIsLoggedIn, true);
              await prefs2.setBool(
                AppConstants.keyHasSignedUpOnDevice,
                true,
              );
              await ApiService.instance.updateUserLoginStatus(
                mobileNumber,
                true,
              );

              if (!mounted) return;

              didNavigate = true;
              if (widget.isForgotMPIN) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => MPinSetScreen(
                      userName: userName,
                      mobileNumber: mobileNumber,
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
            } catch (_) {
              if (!mounted || didNavigate) return;
              setState(() {
                _isLoading = false;
                _errorMessage = 'msgErrorTryAgain';
              });
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            if (didNavigate || !mounted) return;
            debugPrint(
              'Firebase verifyPhoneNumber failed: code=${e.code} message=${e.message}',
            );
            setState(() {
              _isLoading = false;
              // Missing SHA / Play Integrity often surfaces as generic or web errors.
              if (e.code == 'web-context-cancelled' ||
                  e.code == 'missing-client-identifier' ||
                  (e.message?.contains('sessionStorage') ?? false) ||
                  (e.message?.contains('initial state') ?? false)) {
                _errorMessage = 'msgFirebasePhoneSetup';
              } else {
                _errorMessage = 'msgErrorTryAgain';
              }
            });
          },
          codeSent: (verificationId, _) {
            if (didNavigate || !mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => OTPVerificationScreen(
                  mobileNumber: mobileNumber,
                  mode: OtpVerifyMode.firebasePhone,
                  verificationId: verificationId,
                  isResetMPIN: widget.isForgotMPIN,
                ),
              ),
            );
          },
          codeAutoRetrievalTimeout: (_) {},
        );
      } else {
        // LIVE=false: create OTP session in DB, user can see OTP at /api/otp/dev.
        final otpRes = await ApiService.instance.sendOTP(mobileNumber);
        if (!otpRes.success) {
          setState(() {
            _isLoading = false;
            _errorMessage = otpRes.message ?? 'msgErrorTryAgain';
          });
          return;
        }

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OTPVerificationScreen(
              mobileNumber: mobileNumber,
              mode: OtpVerifyMode.backendDb,
              isResetMPIN: widget.isForgotMPIN,
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'msgErrorTryAgain';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const accentOrange = AppTheme.accentOrange;

    final title = widget.isForgotMPIN ? context.t('msgResetMpin') : 'Register';

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
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 42,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.app_registration_rounded,
                    size: 62,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _mobileController,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryText,
                              letterSpacing: 1,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: context.t('msgValidTenDigit'),
                              hintStyle: GoogleFonts.inter(
                                color: AppTheme.lightText,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
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
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: accentOrange.withValues(alpha: 0.35),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                            validator: (value) {
                              final k = mobileValidationError(value);
                              return k == null ? null : context.t(k);
                            },
                            onChanged: (value) {
                              setState(() => _errorMessage = null);
                            },
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              color: accentOrange,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: accentOrange.withValues(alpha: 0.35),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: _isLoading ? null : _handleSubmit,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: Center(
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            context.t('msgGetStarted'),
                                            style: GoogleFonts.inter(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_errorMessage != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedErrorBanner(
                message: context.tOrRaw(_errorMessage!),
                onDismiss: () => setState(() => _errorMessage = null),
              ),
            ),
        ],
      ),
    );
  }
}

