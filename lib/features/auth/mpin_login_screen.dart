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
import 'auth_controller.dart';
import 'signup_screen.dart';

class MPinLoginScreen extends StatefulWidget {
  const MPinLoginScreen({super.key});

  @override
  State<MPinLoginScreen> createState() => _MPinLoginScreenState();
}

class _MPinLoginScreenState extends State<MPinLoginScreen> {
  final TextEditingController _mpinController = TextEditingController();
  final FocusNode _mpinFocusNode = FocusNode();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mpinFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _mpinController.dispose();
    _mpinFocusNode.dispose();
    super.dispose();
  }

  void _onMpinChanged(String value) {
    setState(() => _errorMessage = null);
    if (value.length == AppConstants.mpinLength && !_isLoading) {
      _verifyMPin(value.trim());
    }
  }

  Future<void> _verifyMPin(String enteredMPin) async {
    if (enteredMPin.length != AppConstants.mpinLength) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final result = await context.read<AuthController>().verifyMpin(
          enteredMpin: enteredMPin,
          prefs: prefs,
        );

    if (!mounted) return;

    switch (result.status) {
      case MpinLoginStatus.mobileMissing:
        _setErrorAndClear(AppConstants.msgMobileNotFound);
        return;
      case MpinLoginStatus.userNotFound:
        _setErrorAndClear(AppConstants.msgUserNotFound);
        return;
      case MpinLoginStatus.mobileMismatch:
        _setErrorAndClear(AppConstants.msgMobileMismatch);
        return;
      case MpinLoginStatus.mpinNotSet:
        _setErrorAndClear(AppConstants.msgMpinNotSet);
        return;
      case MpinLoginStatus.incorrectMpin:
        _setErrorAndClear(AppConstants.msgIncorrectMpin);
        return;
      case MpinLoginStatus.ok:
        setState(() => _isLoading = false);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => MainShellScreen(
              userName: result.userName ?? AppConstants.defaultUserName,
            ),
          ),
          (route) => false,
        );
    }
  }

  void _setErrorAndClear(String message) {
    setState(() {
      _isLoading = false;
      _errorMessage = message;
    });
    _mpinController.clear();
    _mpinFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 55,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.msgLoginByMpin,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _mpinController,
                          focusNode: _mpinFocusNode,
                          keyboardType: TextInputType.number,
                          maxLength: AppConstants.mpinLength,
                          obscureText: true,
                          enabled: !_isLoading,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accentOrange,
                            letterSpacing: 1.5,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(
                              AppConstants.mpinLength,
                            ),
                          ],
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: context.t('msgEnterMpin'),
                            hintStyle: GoogleFonts.inter(
                              color: AppTheme.lightText,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: AppTheme.accentOrange.withValues(alpha: 0.35),
                                width: 2,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: _errorMessage != null
                                    ? AppTheme.error
                                    : AppTheme.accentOrange,
                                width: 3,
                              ),
                            ),
                          ),
                          onChanged: _onMpinChanged,
                        ),
                        const SizedBox(height: 10),
                        if (_errorMessage != null)
                          MessageBanner(
                            message: context.tOrRaw(_errorMessage!),
                            type: MessageBannerType.error,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.accentOrange,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentOrange.withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: _isLoading
                              ? null
                              : () {
                                  final v = _mpinController.text.trim();
                                  if (v.length == AppConstants.mpinLength) {
                                    _verifyMPin(v);
                                  } else {
                                    _setErrorAndClear(
                                      context.t('msgInvalidMpin'),
                                    );
                                  }
                                },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      context.t('labelSubmit'),
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
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) =>
                              const SignUpScreen(isForgotMPIN: true),
                        ),
                      );
                    },
                    child: Text(
                      context.t('msgForgotMpinClick'),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.accentOrange,
                        decoration: TextDecoration.underline,
                      ),
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
