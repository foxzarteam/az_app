import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../config/app_config.dart';
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
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Deep base background
    paint
      ..color = primaryDark
      ..maskFilter = null;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Helper to draw a soft blurred bubble
    void drawBubble({
      required Offset center,
      required double radius,
      required Color color,
      double blurSigma = 18,
    }) {
      paint
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);
      canvas.drawCircle(center, radius, paint);
    }

    final width = size.width;
    final height = size.height;

    // Main large background bubbles
    drawBubble(
      center: Offset(width * 0.2, height * 0.2),
      radius: 110,
      color: primary.withOpacity(0.55),
    );
    drawBubble(
      center: Offset(width * 0.85, height * 0.18),
      radius: 100,
      color: orange.withOpacity(0.45),
    );
    drawBubble(
      center: Offset(width * 0.15, height * 0.8),
      radius: 120,
      color: primary.withOpacity(0.35),
    );
    drawBubble(
      center: Offset(width * 0.8, height * 0.78),
      radius: 130,
      color: orange.withOpacity(0.35),
    );

    // Extra smaller accent bubbles for richer look
    drawBubble(
      center: Offset(width * 0.5, height * 0.12),
      radius: 40,
      color: primary.withOpacity(0.4),
      blurSigma: 14,
    );
    drawBubble(
      center: Offset(width * 0.9, height * 0.45),
      radius: 55,
      color: orange.withOpacity(0.35),
      blurSigma: 16,
    );
    drawBubble(
      center: Offset(width * 0.1, height * 0.5),
      radius: 50,
      color: primary.withOpacity(0.3),
      blurSigma: 16,
    );
    drawBubble(
      center: Offset(width * 0.55, height * 0.85),
      radius: 60,
      color: primary.withOpacity(0.35),
      blurSigma: 18,
    );

    // Light subtle glow behind the center logo area
    drawBubble(
      center: Offset(width * 0.5, height * 0.45),
      radius: 140,
      color: orange.withOpacity(0.18),
      blurSigma: 22,
    );
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
      precacheImage(AssetImage(AppConfig.splashLogo), context);
    }
    final size = MediaQuery.of(context).size;
    const primaryDark = Color(AppConstants.primaryColorDark);
    const primary = Color(AppConstants.primaryColor);
    const orange = Color(AppConstants.accentColor);
    const yellow = Color(AppConstants.yellowAccent);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Same gradient + bubbles style as SignUpScreen
          Container(
            decoration: BoxDecoration(
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
                              AppConfig.splashLogo,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [Colors.white, Colors.white.withOpacity(0.9)],
                        ).createShader(bounds),
                        child: Text(
                          '${AppConstants.appName.split(' ')[0]} ',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w600,
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
                      Text(
                        AppConstants.appName.split(' ')[1],
                        style: GoogleFonts.inter(
                          color: const Color(AppConstants.accentColor),
                          fontSize: 42,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: primary.withOpacity(0.5),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ],
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
