import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  Country _selectedCountry = Country.countries[0];

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
            _errorMessage = AppConstants.msgFailedCreateAccount;
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
          _errorMessage = AppConstants.msgErrorTryAgain;
        });
      }
    }
  }

  void _showCountryPicker() {
    const accentOrange = Color(AppConstants.accentColor);
    const darkGrayText = Color(AppConstants.primaryText);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(AppConstants.borderColor),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                AppConstants.msgSelectCountry,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: darkGrayText,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: Country.countries.length,
                itemBuilder: (context, index) {
                  final country = Country.countries[index];
                  final isSelected = country.code == _selectedCountry.code;

                  return InkWell(
                    onTap: () {
                      setState(() => _selectedCountry = country);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? accentOrange.withOpacity(0.1) : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(AppConstants.borderColor),
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: Image.network(
                                country.flagUrl,
                                width: 40,
                                height: 30,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Text(
                                      country.flagEmoji,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              country.name,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                color: darkGrayText,
                              ),
                            ),
                          ),
                          Text(
                            country.dialCode,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? accentOrange
                                  : const Color(AppConstants.secondaryText),
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.check_circle, color: accentOrange, size: 22),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const primaryBlue = Color(AppConstants.primaryColor);
    const primaryBlueDark = Color(AppConstants.primaryColorDark);
    const accentOrange = Color(AppConstants.accentColor);
    const yellow = Color(AppConstants.yellowAccent);

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
                                    FadeInDown(
                                      duration: const Duration(milliseconds: 600),
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: accentOrange.withOpacity(0.4),
                                              blurRadius: 30,
                                              offset: const Offset(0, 10),
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.account_balance_rounded,
                                          color: primaryBlue,
                                          size: 50,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    FadeInUp(
                                      duration: const Duration(milliseconds: 600),
                                      delay: const Duration(milliseconds: 200),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Apni',
                                            style: GoogleFonts.poppins(
                                              fontSize: 36,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                          Text(
                                            'Zaroorat',
                                            style: GoogleFonts.poppins(
                                              fontSize: 36,
                                              fontWeight: FontWeight.w900,
                                              color: yellow,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    FadeInUp(
                                      duration: const Duration(milliseconds: 600),
                                      delay: const Duration(milliseconds: 400),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: List.generate(5, (index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 3),
                                            child: Icon(
                                              Icons.star_rounded,
                                              color: yellow,
                                              size: 20,
                                            ),
                                          );
                                        }),
                                      ),
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
                                      FadeInUp(
                                        duration: const Duration(milliseconds: 700),
                                        delay: const Duration(milliseconds: 200),
                                        child: Text(
                                          widget.isForgotMPIN
                                              ? AppConstants.msgResetMpin
                                              : AppConstants.msgGetStarted,
                                          style: GoogleFonts.poppins(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w800,
                                            color: primaryBlue,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      FadeInUp(
                                        duration: const Duration(milliseconds: 800),
                                        delay: const Duration(milliseconds: 400),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Mobile Number',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(AppConstants.primaryText),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(18),
                                                border: Border.all(
                                                  color: _errorMessage != null
                                                      ? const Color(AppConstants.errorColor)
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
                                                  GestureDetector(
                                                    onTap: _showCountryPicker,
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 16,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          colors: [accentOrange, accentOrange.withOpacity(0.8)],
                                                        ),
                                                        borderRadius: const BorderRadius.only(
                                                          topLeft: Radius.circular(16),
                                                          bottomLeft: Radius.circular(16),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            width: 26,
                                                            height: 18,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(5),
                                                              border: Border.all(
                                                                color: Colors.white,
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius: BorderRadius.circular(4),
                                                              child: Image.network(
                                                                _selectedCountry.flagUrl,
                                                                fit: BoxFit.cover,
                                                                errorBuilder: (context, error, stackTrace) {
                                                                  return Center(
                                                                    child: Text(
                                                                      _selectedCountry.flagEmoji,
                                                                      style: const TextStyle(fontSize: 12),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Text(
                                                            _selectedCountry.dialCode,
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.w700,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 4),
                                                          const Icon(
                                                            Icons.arrow_drop_down,
                                                            color: Colors.white,
                                                            size: 18,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                                      child: TextFormField(
                                                        controller: _mobileController,
                                                        keyboardType: TextInputType.phone,
                                                        maxLength: 10,
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 17,
                                                          fontWeight: FontWeight.w600,
                                                          color: const Color(AppConstants.primaryText),
                                                          letterSpacing: 1,
                                                        ),
                                                        decoration: InputDecoration(
                                                          hintText: AppConstants.hintMobilePlaceholder,
                                                          hintStyle: GoogleFonts.poppins(
                                                            color: const Color(AppConstants.lightText),
                                                            fontSize: 17,
                                                          ),
                                                          border: InputBorder.none,
                                                          counterText: '',
                                                        ),
                                                        validator: (value) => mobileValidationError(value),
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
                                      ),
                                      const SizedBox(height: 32),
                                      FadeInUp(
                                        duration: const Duration(milliseconds: 900),
                                        delay: const Duration(milliseconds: 500),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [accentOrange, accentOrange.withOpacity(0.8)],
                                              ),
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
                                                      ? const SizedBox(
                                                          height: 22,
                                                          width: 22,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2.5,
                                                            valueColor: AlwaysStoppedAnimation<Color>(
                                                              Colors.white,
                                                            ),
                                                          ),
                                                        )
                                                      : Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(
                                                              'Continue',
                                                              style: GoogleFonts.poppins(
                                                                fontSize: 17,
                                                                fontWeight: FontWeight.w700,
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
                                      ),
                                      const SizedBox(height: 16),
                                      Center(
                                        child: Text(
                                          AppConstants.msgTermsPrivacy,
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: const Color(AppConstants.lightText),
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
                message: _errorMessage!,
                onDismiss: () => setState(() => _errorMessage = null),
              ),
            ),
        ],
      ),
    );
  }
}
