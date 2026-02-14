import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../utils/app_images.dart';
import '../services/api_service.dart';
import 'signup_screen.dart';
import 'mpin_login_screen.dart';

class GeometricPatternPainter extends CustomPainter {
  final Color primaryDark;
  final Color primary;
  final Color orange;

  GeometricPatternPainter({
    required this.primaryDark,
    required this.primary,
    required this.orange,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = primaryDark;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    paint.color = primary.withOpacity(0.15);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.15), 80, paint);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.85), 60, paint);

    final wavePath = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.35, size.width * 0.5, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.45, size.width, size.height * 0.4)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    paint.color = primary.withOpacity(0.3);
    canvas.drawPath(wavePath, paint);

    paint.color = orange.withOpacity(0.2);
    final orangePath = Path()
      ..moveTo(size.width * 0.7, 0)
      ..lineTo(size.width, size.height * 0.3)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(orangePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  bool _imagePrecached = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
    _animationController.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final mobileNumber = prefs.getString(AppConstants.keyMobileNumber);

    String? mpin;

    if (mobileNumber != null && mobileNumber.isNotEmpty) {
      final dbUser = await ApiService.instance.getUserByMobile(mobileNumber);
      if (dbUser != null) {
        mpin = dbUser['mpin']?.toString();
        final userName = dbUser['user_name']?.toString();
        if (userName != null) {
          await prefs.setString(AppConstants.keyUserName, userName);
        }
      } else {
        mpin = prefs.getString(AppConstants.keyMPin);
      }
    } else {
      mpin = prefs.getString(AppConstants.keyMPin);
    }

    if (!mounted) return;

    if (mpin != null && mpin.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MPinLoginScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SignUpScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildStars() {
    const yellow = Color(AppConstants.yellowAccent);
    final angle = _rotationAnimation.value * 2 * math.pi;
    const radius = 70.0;
    const centerX = 90.0;
    const centerY = 90.0;
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: List.generate(6, (index) {
          final starAngle = (index * 2 * math.pi / 6) + angle;
          return Positioned(
            left: centerX + math.cos(starAngle) * radius - 10,
            top: centerY + math.sin(starAngle) * radius - 10,
            child: Transform.rotate(
              angle: angle,
              child: const Icon(Icons.star, color: yellow, size: 20),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_imagePrecached) {
      _imagePrecached = true;
      precacheImage(AssetImage(AppImages.splashLogo), context);
    }
    final size = MediaQuery.of(context).size;
    const primaryDark = Color(AppConstants.primaryColorDark);
    const primary = Color(AppConstants.primaryColor);
    const orange = Color(AppConstants.accentColor);
    const yellow = Color(AppConstants.yellowAccent);

    return Scaffold(
      backgroundColor: primaryDark,
      body: Stack(
        children: [
          CustomPaint(
            size: size,
            painter: GeometricPatternPainter(
              primaryDark: primaryDark,
              primary: primary,
              orange: orange,
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [orange.withOpacity(0.3), Colors.transparent],
                          ),
                        ),
                      ),
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: yellow.withOpacity(0.5), width: 2),
                        ),
                      ),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: orange.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              AppImages.splashLogo,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              cacheWidth: 200,
                              cacheHeight: 200,
                              filterQuality: FilterQuality.medium,
                            ),
                          ),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, _) {
                          return _buildStars();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Colors.white, Colors.white.withOpacity(0.9)],
                    ).createShader(bounds),
                    child: Text(
                      'Apni Zaroorat',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        height: 1.2,
                        shadows: [
                          Shadow(
                            color: primary.withOpacity(0.8),
                            offset: const Offset(0, 4),
                            blurRadius: 20,
                          ),
                          Shadow(
                            color: orange.withOpacity(0.6),
                            offset: const Offset(0, 2),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
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
