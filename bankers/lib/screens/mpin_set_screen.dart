import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../services/api_service.dart';
import 'main_shell_screen.dart';
import 'signup_screen.dart';

class _PinBackspaceIntent extends Intent {
  const _PinBackspaceIntent();
}

class MPinSetScreen extends StatefulWidget {
  final String userName;
  final String mobileNumber;
  final bool isResetMPIN;

  const MPinSetScreen({
    super.key,
    required this.userName,
    required this.mobileNumber,
    this.isResetMPIN = false,
  });

  @override
  State<MPinSetScreen> createState() => _MPinSetScreenState();
}

class _MPinSetScreenState extends State<MPinSetScreen> {
  final List<TextEditingController> _pinControllers =
      List.generate(AppConstants.otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(AppConstants.otpLength, (_) => FocusNode());
  String _pin = '';

  @override
  void initState() {
    super.initState();
    _checkExistingMPin();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  Future<void> _checkExistingMPin() async {
    if (widget.isResetMPIN) {
      return;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final dbUser = await ApiService.instance.getUserByMobile(widget.mobileNumber);
    final existingMPin = dbUser?['mpin']?.toString();
    
    if (existingMPin != null && existingMPin.isNotEmpty && mounted) {
      await prefs.setString(AppConstants.keyMPin, existingMPin);
      await prefs.setString(AppConstants.keyUserName, widget.userName);
      await prefs.setString(AppConstants.keyMobileNumber, widget.mobileNumber);
      await prefs.setBool(AppConstants.keyIsLoggedIn, true);
      await ApiService.instance.updateUserLoginStatus(widget.mobileNumber, true);
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => MainShellScreen(userName: widget.userName, initialIndex: 0),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onPinChanged(int index, String value) {
    if (value.isNotEmpty) {
      setState(() => _pin = _pinControllers.map((c) => c.text).join());
      if (index < AppConstants.otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_pin.length == AppConstants.otpLength) _saveMPin();
      }
    } else {
      // Backspace: current box cleared, move focus to previous
      if (index > 0) {
        setState(() => _pin = _pinControllers.map((c) => c.text).join());
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  void _goBack() {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
      (route) => false,
    );
  }

  Future<void> _saveMPin() async {
    if (_pin.length != AppConstants.otpLength) return;

    final prefs = await SharedPreferences.getInstance();
    final trimmedPin = _pin.trim();

    if (trimmedPin.length != AppConstants.otpLength) {
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
      if (mounted) _showSnackBar(AppConstants.msgFailedSaveMpin, isError: true);
      return;
    }

    final verifyUser =
        await ApiService.instance.getUserByMobile(widget.mobileNumber);
    final savedMPin = verifyUser?['mpin']?.toString().trim() ?? '';
    if (savedMPin != trimmedPin) {
      if (mounted) _showSnackBar(AppConstants.msgMpinVerifyFailed, isError: true);
      return;
    }

    await prefs.setString(AppConstants.keyMPin, trimmedPin);
    await prefs.setString(AppConstants.keyUserName, widget.userName);
    await prefs.setString(AppConstants.keyMobileNumber, widget.mobileNumber);
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);

    if (mounted) {
      if (widget.isResetMPIN) {
        _showSnackBar(AppConstants.msgMpinResetSuccess, isError: false);
        await Future.delayed(const Duration(milliseconds: 500));
      }
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => MainShellScreen(userName: widget.userName, initialIndex: 0),
          ),
          (route) => false,
        );
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
    final size = MediaQuery.of(context).size;
    const primaryBlue = AppTheme.primaryBlue;
    const primaryBlueDark = AppTheme.primaryBlueDark;
    const accentOrange = AppTheme.accentOrange;
    const yellow = AppTheme.yellow;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _goBack();
      },
      child: Scaffold(
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _goBack,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                builder: (context, constraints) {
                  final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
                  final isKeyboardVisible = keyboardHeight > 0;

                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                                              color: accentOrange.withOpacity(0.3),
                                              blurRadius: 20,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.lock_outline_rounded,
                                          color: AppTheme.accentOrange,
                                          size: 56,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        AppConstants.msgSetMpinTitle,
                                        style: GoogleFonts.inter(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
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
                                          SingleActivator(LogicalKeyboardKey.backspace): _PinBackspaceIntent(),
                                        },
                                        child: Actions(
                                          actions: {
                                            _PinBackspaceIntent: CallbackAction<_PinBackspaceIntent>(
                                              onInvoke: (_) {
                                                for (var i = 0; i < 4; i++) {
                                                  if (_focusNodes[i].hasFocus &&
                                                      _pinControllers[i].text.isEmpty &&
                                                      i > 0) {
                                                    _pinControllers[i - 1].clear();
                                                    setState(() => _pin = _pinControllers.map((c) => c.text).join());
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
                                        children: List.generate(4, (index) {
                                          return SizedBox(
                                            width: 65,
                                            height: 65,
                                            child: TextField(
                                              controller: _pinControllers[index],
                                              focusNode: _focusNodes[index],
                                                textAlign: TextAlign.center,
                                                keyboardType: TextInputType.number,
                                                maxLength: 1,
                                                obscureText: true,
                                                style: GoogleFonts.inter(
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.w500,
                                                  color: accentOrange,
                                                  letterSpacing: 2,
                                                ),
                                                decoration: InputDecoration(
                                                  counterText: '',
                                                  filled: true,
                                                  fillColor: AppTheme.mainBackground,
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(18),
                                                    borderSide: BorderSide(
                                                      color: accentOrange.withOpacity(0.3),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(18),
                                                    borderSide: BorderSide(
                                                      color: accentOrange.withOpacity(0.3),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(18),
                                                    borderSide: BorderSide(
                                                      color: accentOrange,
                                                      width: 3,
                                                    ),
                                                  ),
                                                ),
                                                onChanged: (value) => _onPinChanged(index, value),
                                            ),
                                          );
                                        }),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: accentOrange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: accentOrange.withOpacity(0.2),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline_rounded,
                                              color: accentOrange,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                AppConstants.msgRememberPin,
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  color: accentOrange.withOpacity(0.9),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
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
            ),
          ],
        ),
      ),
    );
  }
}
