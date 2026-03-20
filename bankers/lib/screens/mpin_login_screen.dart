import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/bubble_background.dart';
import '../widgets/auth_header.dart';
import '../widgets/message_banner.dart';
import 'main_shell_screen.dart';
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
    if (value.length == AppConstants.mpinLength) {
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
    final mobileNumber = prefs.getString(AppConstants.keyMobileNumber) ?? '';

    if (mobileNumber.isEmpty) {
      _setErrorAndClear(AppConstants.msgMobileNotFound);
      return;
    }

    final dbUser = await ApiService.instance.getUserByMobile(mobileNumber);

    if (dbUser == null) {
      await _clearStoredAuth(prefs);
      _setErrorAndClear(AppConstants.msgUserNotFound);
      return;
    }

    final dbMobileNumber = dbUser['mobile_number']?.toString() ?? '';
    if (dbMobileNumber != mobileNumber) {
      await _clearStoredAuth(prefs);
      _setErrorAndClear(AppConstants.msgMobileMismatch);
      return;
    }

    final savedMPin = dbUser['mpin']?.toString().trim() ?? '';
    final userName = dbUser['user_name']?.toString() ??
        prefs.getString(AppConstants.keyUserName) ??
        AppConstants.defaultUserName;

    if (!mounted) return;

    if (savedMPin.isEmpty) {
      _setErrorAndClear(AppConstants.msgMpinNotSet);
      return;
    }

    if (savedMPin == enteredMPin) {
      await prefs.setString(AppConstants.keyMPin, enteredMPin);
      await prefs.setString(AppConstants.keyUserName, userName);
      await prefs.setBool(AppConstants.keyIsLoggedIn, true);
      await ApiService.instance.updateUserLoginStatus(mobileNumber, true);
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => MainShellScreen(userName: userName)),
          (route) => false,
        );
      }
    } else {
      _setErrorAndClear(AppConstants.msgIncorrectMpin);
    }
  }

  Future<void> _clearStoredAuth(SharedPreferences prefs) async {
    await prefs.remove(AppConstants.keyMobileNumber);
    await prefs.remove(AppConstants.keyMPin);
    await prefs.setBool(AppConstants.keyIsLoggedIn, false);
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
      body: BubbleBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Expanded(
                      flex: 45,
                      child: AuthHeader(
                        icon: Icons.lock_outline_rounded,
                        title: AppConstants.msgLoginByMpin,
                        subtitle: AppConstants.msgEnterMpin,
                        compact: true,
                      ),
                    ),
                    Expanded(
                      flex: 55,
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                          const SizedBox(height: 24),
                          AnimatedPadding(
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.easeOut,
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: TextField(
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
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                border: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: _errorMessage != null
                                        ? AppTheme.error
                                        : AppTheme.accentOrange.withOpacity(0.35),
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: _errorMessage != null
                                        ? AppTheme.error
                                        : AppTheme.accentOrange.withOpacity(0.35),
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
                          ),
                          const SizedBox(height: 32),
                          if (_isLoading)
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentOrange),
                            )
                          else if (_errorMessage != null)
                            MessageBanner(
                              message: _errorMessage!,
                              type: MessageBannerType.error,
                            ),
                          const SizedBox(height: 24),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const SignUpScreen(isForgotMPIN: true),
                                ),
                              );
                            },
                            child: Text(
                              AppConstants.msgForgotMpinClick,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
