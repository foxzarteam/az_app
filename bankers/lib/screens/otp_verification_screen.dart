import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_locale.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/message_banner.dart';
import '../widgets/digit_code_input_field.dart';
import 'mpin_set_screen.dart';
import 'mpin_login_screen.dart';

class _OtpBackspaceIntent extends Intent {
  const _OtpBackspaceIntent();
}

class OTPVerificationScreen extends StatefulWidget {
  final String mobileNumber;
  final String userName;
  final String? email;
  final bool isExistingUser;
  final bool isResetMPIN;

  const OTPVerificationScreen({
    super.key,
    required this.mobileNumber,
    required this.userName,
    this.email,
    this.isExistingUser = false,
    this.isResetMPIN = false,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(AppConstants.otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(AppConstants.otpLength, (_) => FocusNode());
  final _api = ApiService.instance;

  bool _isLoading = false;
  bool _isVerifying = false;
  bool _isResending = false;
  String? _errorMessage;
  String? _successMessage;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
      _sendOTP();
    });
    _startResendCooldown();
  }

  Future<void> _sendOTP() async {
    setState(() => _isLoading = true);
    final response = await _api.sendOTP(widget.mobileNumber);
    if (mounted) setState(() => _isLoading = false);
    if (!response.success && mounted) {
      setState(() => _errorMessage = response.message);
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendCooldown() {
    _resendCooldown = AppConstants.otpResendCooldownSeconds;
    setState(() {});
    
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _resendCooldown--;
        });
      }
      return _resendCooldown > 0 && mounted;
    });
  }

  void _onOtpChanged(int index, String value) {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    if (value.isNotEmpty) {
      if (index < AppConstants.otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        final otp = _otpControllers.map((c) => c.text).join();
        if (otp.length == AppConstants.otpLength) {
          _verifyOTP(otp);
        }
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  Future<void> _verifyOTP(String otp) async {
    setState(() {
      _isVerifying = true;
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _api.verifyOTP(widget.mobileNumber, otp);

    setState(() {
      _isVerifying = false;
      _isLoading = false;
    });

    if (mounted) {
      if (response.success) {
        setState(() {
          _successMessage = response.message;
        });

        final prefs = await SharedPreferences.getInstance();
        final existingMPin = prefs.getString(AppConstants.keyMPin);
        final hasMPin = existingMPin != null && existingMPin.isNotEmpty;

        if (!widget.isExistingUser) {
          await _saveUserData();
        } else {
          await prefs.setBool(AppConstants.keyIsLoggedIn, true);
        }

        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          if (widget.isResetMPIN) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => MPinSetScreen(
                  userName: widget.userName,
                  mobileNumber: widget.mobileNumber,
                  isResetMPIN: true,
                ),
              ),
            );
            return;
          }
          
          if (widget.isExistingUser && hasMPin) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const MPinLoginScreen(),
              ),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => MPinSetScreen(
                  userName: widget.userName,
                  mobileNumber: widget.mobileNumber,
                ),
              ),
            );
          }
        }
      } else {
        setState(() {
          _errorMessage =
              response.message ?? 'msgInvalidOtp';
        });
        _clearOtpFields();
      }
    }
  }

  void _clearOtpFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserName, widget.userName);
    await prefs.setString(AppConstants.keyMobileNumber, widget.mobileNumber);
    if (widget.email != null && widget.email!.isNotEmpty) {
      await prefs.setString(AppConstants.keyEmail, widget.email!);
    }
  }

  Future<void> _resendOTP() async {
    if (_resendCooldown > 0 || _isResending) return;
    setState(() {
      _isResending = true;
      _errorMessage = null;
    });
    final response = await _api.sendOTP(widget.mobileNumber);
    if (!mounted) return;
    setState(() => _isResending = false);

    if (mounted) {
      if (response.success) {
        setState(() {
          _successMessage = 'OTP resent successfully!';
        });

        for (var controller in _otpControllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();

        _startResendCooldown();
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Failed to resend OTP';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const primaryBlue = AppTheme.primaryBlue;
    const primaryBlueDark = AppTheme.primaryBlueDark;
    const accentOrange = AppTheme.accentOrange;
    const yellow = AppTheme.yellow;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryBlueDark, primaryBlue],
              ),
            ),
          ),

          Positioned(
            top: size.height * 0.08,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentOrange.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.25,
            right: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: yellow.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.15,
            left: size.width * 0.2,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentOrange.withOpacity(0.1),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
                final isKeyboardVisible = keyboardHeight > 0;
                
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          if (!isKeyboardVisible)
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 110,
                                      height: 110,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.accentOrange.withOpacity(0.3),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.verified_user_rounded,
                                        color: AppTheme.primaryBlue,
                                        size: 56,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      context.t('msgVerifyOtp'),
                                      style: GoogleFonts.inter(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 40),
                          Expanded(
                            flex: isKeyboardVisible ? 1 : 3,
                            child: Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(40),
                                  topRight: Radius.circular(40),
                                ),
                              ),
                              child: SingleChildScrollView(
                                padding: EdgeInsets.only(
                                  left: 24,
                                  right: 24,
                                  top: 32,
                                  bottom: keyboardHeight + 32,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 24),
                                    Shortcuts(
                                      shortcuts: const {
                                        SingleActivator(LogicalKeyboardKey.backspace): _OtpBackspaceIntent(),
                                      },
                                      child: Actions(
                                        actions: {
                                          _OtpBackspaceIntent: CallbackAction<_OtpBackspaceIntent>(
                                            onInvoke: (_) {
                                              for (var i = 0; i < AppConstants.otpLength; i++) {
                                                if (_focusNodes[i].hasFocus &&
                                                    _otpControllers[i].text.isEmpty &&
                                                    i > 0) {
                                                  _otpControllers[i - 1].clear();
                                                  _focusNodes[i - 1].requestFocus();
                                                  return null;
                                                }
                                              }
                                              return null;
                                            },
                                          ),
                                        },
                                        child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: List.generate(AppConstants.otpLength, (index) {
                                        return DigitCodeInputField(
                                          controller: _otpControllers[index],
                                          focusNode: _focusNodes[index],
                                          onChanged: (value) =>
                                              _onOtpChanged(index, value),
                                          enabled: !_isLoading,
                                          hasError: _errorMessage != null,
                                          width: 52,
                                          height: 52,
                                          fontSize: 22,
                                          letterSpacing: 1.5,
                                        );
                                      }),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 32),

                                    if (_isVerifying)
                                      const CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          AppTheme.accentOrange,
                                        ),
                                      )
                                    else if (_errorMessage != null)
                                      MessageBanner(
                                        message: context.tOrRaw(_errorMessage!),
                                        type: MessageBannerType.error,
                                      )
                                    else if (_successMessage != null)
                                      MessageBanner(
                                        message: _successMessage!,
                                        type: MessageBannerType.success,
                                      ),
                                    const SizedBox(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          context.t('msgDidntReceiveOtp'),
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: AppTheme.secondaryText,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: _resendCooldown > 0 ? null : _resendOTP,
                                          child: Text(
                                            _resendCooldown > 0
                                                ? '${context.t('msgResendOtp')} (${_resendCooldown}s)'
                                                : context.t('msgResendOtp'),
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: _resendCooldown > 0
                                                  ? AppTheme.lightText
                                                  : accentOrange,
                                              decoration: _resendCooldown > 0
                                                  ? TextDecoration.none
                                                  : TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: keyboardHeight > 0 ? 20 : 0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
