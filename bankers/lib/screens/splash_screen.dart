import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../services/api_service.dart';
import 'main_shell_screen.dart';
import 'signup_screen.dart';
import 'mpin_login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    final prefsFuture = SharedPreferences.getInstance();
    // Keep a short minimum splash display for smoother transition,
    // while loading data in parallel.
    await Future.wait([
      prefsFuture,
      Future.delayed(const Duration(milliseconds: 700)),
    ]);
    if (!mounted) return;

    final prefs = await prefsFuture;
    final mobileNumber = prefs.getString(AppConstants.keyMobileNumber);
    final hasSignedUpOnDevice =
        prefs.getBool(AppConstants.keyHasSignedUpOnDevice) ?? false;

    var localMpin = prefs.getString(AppConstants.keyMPin)?.trim();
    if (localMpin != null && localMpin.isEmpty) localMpin = null;

    // 1) MPIN already on device → always open MPIN login after splash (session gate).
    if (localMpin != null) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MPinLoginScreen()),
      );
      return;
    }

    // 2) No local MPIN but we know mobile → sync from server if user already set MPIN.
    if (mobileNumber != null && mobileNumber.isNotEmpty) {
      Map<String, dynamic>? dbUser;
      try {
        dbUser = await ApiService.instance
            .getUserByMobile(mobileNumber)
            .timeout(const Duration(milliseconds: 1500));
      } catch (_) {
        dbUser = null;
      }
      if (dbUser != null) {
        final userName = dbUser['user_name']?.toString();
        if (userName != null && userName.isNotEmpty) {
          await prefs.setString(AppConstants.keyUserName, userName);
        }
        final serverMpin = dbUser['mpin']?.toString().trim() ?? '';
        if (serverMpin.isNotEmpty) {
          await prefs.setString(AppConstants.keyMPin, serverMpin);
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MPinLoginScreen()),
          );
          return;
        }
      }
    }

    if (!mounted) return;

    // 3) Signed up on this device but no MPIN stored or on server → home (finish setup inside app).
    if (hasSignedUpOnDevice) {
      final userName =
          prefs.getString(AppConstants.keyUserName) ??
              AppConstants.defaultUserName;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MainShellScreen(userName: userName),
        ),
      );
      return;
    }

    // 4) No account / first launch → registration.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const primaryDark = AppTheme.primaryBlueDark;
    const primary = AppTheme.primaryBlue;
    const orange = AppTheme.accentOrange;
    const yellow = AppTheme.yellow;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryDark, primary],
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
                color: orange.withOpacity(0.15),
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
                color: orange.withOpacity(0.1),
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 180,
                    child: Lottie.asset(
                      AppConfig.rupeesLottie,
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppConstants.appName,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(orange),
                      backgroundColor: primary.withOpacity(0.3),
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
