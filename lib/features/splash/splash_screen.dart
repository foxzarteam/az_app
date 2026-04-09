import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_assets.dart';
import '../../core/theme/app_theme.dart';
import '../../services/splash_flow_service.dart';
import '../auth/auth_controller.dart';
import '../auth/mpin_login_screen.dart';
import '../auth/signup_screen.dart';
import '../shell/main_shell_screen.dart';

const Color _kSplashOrange = Color(0xFFF24C00);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
      _runSplashFlow();
    });
  }

  Future<void> _runSplashFlow() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final route = await context.read<AuthController>().resolveSplash(prefs);
    if (!mounted) return;

    if (route == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const SignUpScreen()),
      );
      return;
    }
    switch (route) {
      case SplashRouteMpinLogin():
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const MPinLoginScreen()),
        );
      case SplashRouteMainShell(:final userName):
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => MainShellScreen(userName: userName),
          ),
        );
      case SplashRouteSignup():
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const SignUpScreen()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      height: 1.2,
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppTheme.primaryBlueDark,
      body: ColoredBox(
        color: AppTheme.primaryBlueDark,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text.rich(
                    TextSpan(
                      style: titleStyle,
                      children: [
                        TextSpan(
                          text: 'Apni',
                          style: titleStyle.copyWith(color: _kSplashOrange),
                        ),
                        TextSpan(
                          text: ' Zaroorat',
                          style: titleStyle.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: Lottie.asset(
                      AppAssets.rupeesLottie,
                      fit: BoxFit.contain,
                      repeat: true,
                      frameRate: FrameRate.composition,
                      errorBuilder: (_, _, _) {
                        return Icon(
                          Icons.currency_rupee_rounded,
                          size: 100,
                          color: Colors.amber.shade400,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _kSplashOrange,
                      backgroundColor:
                          AppTheme.primaryBlue.withValues(alpha: 0.35),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
