import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../services/api_service.dart';
import 'main_shell_screen.dart';
import 'signup_screen.dart';

class MPinSetScreen extends StatefulWidget {
  final String userName;
  final String mobileNumber;
  final bool isResetMPIN;
  final bool launchedFromSettings;

  const MPinSetScreen({
    super.key,
    required this.userName,
    required this.mobileNumber,
    this.isResetMPIN = false,
    this.launchedFromSettings = false,
  });

  @override
  State<MPinSetScreen> createState() => _MPinSetScreenState();
}

class _MPinSetScreenState extends State<MPinSetScreen> {
  final TextEditingController _mpinController = TextEditingController();
  final FocusNode _mpinFocusNode = FocusNode();
  bool _isSaving = false;

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
    if (value.length == AppConstants.mpinLength && !_isSaving) {
      _saveMPin(value);
    }
  }

  void _goBack() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (widget.launchedFromSettings) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
      (route) => false,
    );
  }

  Future<void> _saveMPin(String pin) async {
    if (pin.length != AppConstants.mpinLength) return;
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    final trimmedPin = pin.trim();

    if (trimmedPin.length != AppConstants.mpinLength) {
      if (mounted) _showSnackBar(AppConstants.msgInvalidMpin, isError: true);
      return;
    }

    final success = await ApiService.instance.upsertUser(
      mobileNumber: widget.mobileNumber,
      userName: widget.userName,
      mpin: trimmedPin,
      isLoggedIn: true,
    );

    if (!success) {
      if (mounted) setState(() => _isSaving = false);
      if (mounted) _showSnackBar(AppConstants.msgFailedSaveMpin, isError: true);
      return;
    }

    final verifyUser =
        await ApiService.instance.getUserByMobile(widget.mobileNumber);
    final savedMPin = verifyUser?['mpin']?.toString().trim() ?? '';
    if (savedMPin != trimmedPin) {
      if (mounted) setState(() => _isSaving = false);
      if (mounted) _showSnackBar(AppConstants.msgMpinVerifyFailed, isError: true);
      return;
    }

    await prefs.setString(AppConstants.keyMPin, trimmedPin);
    await prefs.setString(AppConstants.keyUserName, widget.userName);
    await prefs.setString(AppConstants.keyMobileNumber, widget.mobileNumber);
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
    await prefs.setBool(AppConstants.keyHasSignedUpOnDevice, true);

    if (mounted) {
      setState(() => _isSaving = false);
      if (widget.isResetMPIN) {
        _showSnackBar(AppConstants.msgMpinResetSuccess, isError: false);
        await Future.delayed(const Duration(milliseconds: 500));
      }
      if (mounted) {
        if (widget.launchedFromSettings) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) =>
                  MainShellScreen(userName: widget.userName, initialIndex: 0),
            ),
            (route) => false,
          );
        }
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        backgroundColor: isError
            ? Colors.red
            : AppTheme.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _goBack();
      },
      child: Scaffold(
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      color: Colors.white,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppConstants.msgSetMpinTitle,
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
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
                            enabled: true,
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
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppTheme.accentOrange.withValues(alpha: 0.35),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppTheme.accentOrange,
                                  width: 3,
                                ),
                              ),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppTheme.accentOrange.withValues(alpha: 0.35),
                                  width: 2,
                                ),
                              ),
                              hintText: AppConstants.msgEnterMpin,
                              hintStyle: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.lightText,
                              ),
                            ),
                            onChanged: _onMpinChanged,
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
                            onTap: () {
                              final v = _mpinController.text.trim();
                              if (v.length != AppConstants.mpinLength) {
                                _showSnackBar(AppConstants.msgInvalidMpin,
                                    isError: true);
                                return;
                              }
                              _saveMPin(v);
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'Submit',
                                  style: TextStyle(
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
                    // Small hint for reset flow.
                    if (widget.isResetMPIN)
                      Text(
                        AppConstants.msgMpinResetSuccess,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.accentOrange.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
