import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_locale.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../models/country_model.dart';
import '../widgets/animated_error_banner.dart';
import '../services/auth_flow_service.dart';
import 'mpin_login_screen.dart';
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
      await AuthFlowService.instance.clearStaleSessionIfMobileChanged(
        prefs,
        mobileNumber,
      );

      final userName = await AuthFlowService.instance.ensureUserAndGetUserName(
        mobileNumber,
        prefs,
      );
      if (userName == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'msgFailedCreateAccount';
          });
        }
        return;
      }

      final result = await AuthFlowService.instance.runSignUpFlow(
        mobileNumber: mobileNumber,
        userName: userName,
        isForgotMPIN: widget.isForgotMPIN,
        prefs: prefs,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.route == SignUpNextRoute.stayWithError) {
        setState(() => _errorMessage = result.errorMessage);
        return;
      }

      if (result.route == SignUpNextRoute.mpinLogin) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MPinLoginScreen()),
        );
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OTPVerificationScreen(
            mobileNumber: result.mobileNumber,
            userName: result.userName,
            isExistingUser: result.isExistingUser,
            isResetMPIN: result.isResetMPIN,
          ),
        ),
      );
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
          Positioned(
            bottom: size.height * 0.08,
            right: size.width * 0.15,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: yellow.withOpacity(0.15),
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
                              flex: 3,
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
                                            color: accentOrange.withOpacity(0.3),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.account_balance_rounded,
                                        color: AppTheme.primaryBlue,
                                        size: 56,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${AppConstants.appName.split(' ')[0]} ',
                                          style: GoogleFonts.inter(
                                            fontSize: 36,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        Text(
                                          AppConstants.appName.split(' ')[1],
                                          style: GoogleFonts.inter(
                                            fontSize: 36,
                                            fontWeight: FontWeight.w500,
                                            color: accentOrange,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 40),

                          Expanded(
                            flex: isKeyboardVisible ? 1 : 4,
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
                                  top: 24,
                                  bottom: keyboardHeight + 24,
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        widget.isForgotMPIN
                                            ? context.t('msgResetMpin')
                                            : context.t('msgGetStarted'),
                                        style: GoogleFonts.inter(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w500,
                                          color: primaryBlue,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            context.t('msgMobileNumber'),
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.primaryText,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(18),
                                              border: Border.all(
                                                color: _errorMessage != null
                                                    ? AppTheme.error
                                                    : accentOrange.withOpacity(0.4),
                                                width: 2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: accentOrange.withOpacity(0.15),
                                                  blurRadius: 15,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 16,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    gradient: AppTheme.orangeGradient,
                                                    borderRadius: const BorderRadius.only(
                                                      topLeft: Radius.circular(16),
                                                      bottomLeft: Radius.circular(16),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        Country.india.flagEmoji,
                                                        style: const TextStyle(fontSize: 20),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        Country.india.dialCode,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w500,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                                    child: TextFormField(
                                                      controller: _mobileController,
                                                      keyboardType: TextInputType.phone,
                                                      maxLength: 10,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 17,
                                                        fontWeight: FontWeight.w500,
                                                        color: AppTheme.primaryText,
                                                        letterSpacing: 1,
                                                      ),
                                                      decoration: InputDecoration(
                                                        hintText: context.t('hintMobilePlaceholder'),
                                                        hintStyle: GoogleFonts.inter(
                                                          color: AppTheme.lightText,
                                                          fontSize: 17,
                                                        ),
                                                        border: InputBorder.none,
                                                        counterText: '',
                                                      ),
                                                      validator: (value) {
                                                        final k = mobileValidationError(value);
                                                        return k == null ? null : context.t(k);
                                                      },
                                                      onChanged: (value) {
                                                        setState(() {
                                                          _errorMessage = null;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 32),
                                      SizedBox(
                                        width: double.infinity,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppTheme.accentOrange,
                                            borderRadius: BorderRadius.circular(18),
                                            boxShadow: [
                                              BoxShadow(
                                                color: accentOrange.withOpacity(0.4),
                                                blurRadius: 20,
                                                offset: const Offset(0, 8),
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: _isLoading ? null : _handleSubmit,
                                              borderRadius: BorderRadius.circular(18),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 16),
                                                child: _isLoading
                                                    ? const Center(
                                                        child: SizedBox(
                                                          height: 20,
                                                          width: 20,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            valueColor: AlwaysStoppedAnimation<Color>(
                                                              Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            context.t('msgContinue'),
                                                            style: GoogleFonts.inter(
                                                              fontSize: 17,
                                                              fontWeight: FontWeight.w500,
                                                              letterSpacing: 1,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 10),
                                                          const Icon(
                                                            Icons.arrow_forward_rounded,
                                                            color: Colors.white,
                                                            size: 22,
                                                          ),
                                                        ],
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Center(
                                        child: Text(
                                          context.t('msgTermsPrivacy'),
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: AppTheme.lightText,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: keyboardHeight > 0 ? 20 : 0),
                                    ],
                                  ),
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
