import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/referral_lottie_cache.dart';
import '../utils/user_prefs_helper.dart';
import '../widgets/common_bottom_nav.dart';
import '../widgets/common_nav_bar.dart';
import '../widgets/wallet_shell_nav.dart';

/// Referral link + code + Lottie; opened from bottom nav or wallet flows.
class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key, this.userName, this.shellNav});

  final String? userName;
  final WalletShellNav? shellNav;

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen>
    with SingleTickerProviderStateMixin {
  String _code = '';
  bool _loading = true;

  /// Nullable so [build] never reads uninitialized `late` fields after hot reload.
  AnimationController? _entrance;
  Animation<double>? _entranceFade;
  Animation<Offset>? _entranceSlide;

  static final AlwaysStoppedAnimation<double> _fadeOpaque =
      AlwaysStoppedAnimation<double>(1);
  static final AlwaysStoppedAnimation<Offset> _slideNone =
      AlwaysStoppedAnimation<Offset>(Offset.zero);

  static const Color _referralGold = Color(0xFFC9A227);
  static const Color _referralCream = Color(0xFFFFF8E7);

  @override
  void initState() {
    super.initState();
    final c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _entrance = c;
    _entranceFade = CurvedAnimation(
      parent: c,
      curve: Curves.easeOutCubic,
    );
    _entranceSlide = Tween<Offset>(
      begin: const Offset(0, 0.035),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic));
    scheduleMicrotask(_loadReferralCode);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) c.forward();
    });
  }

  @override
  void dispose() {
    _entrance?.dispose();
    super.dispose();
  }

  static String _randomLocalCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random();
    return List.generate(8, (_) => chars[r.nextInt(chars.length)]).join();
  }

  Future<void> _loadReferralCode() async {
    var code = _randomLocalCode();
    try {
      final c = await UserPrefsHelper.getOrCreateReferralCode().timeout(
        const Duration(milliseconds: 2500),
      );
      if (c.length == 8) code = c;
    } catch (_) {
      try {
        final mobile = await UserPrefsHelper.getMobileNumber().timeout(
          const Duration(seconds: 2),
        );
        code = UserPrefsHelper.deriveReferralCodeFromMobile(mobile);
      } catch (_) {
        code = _randomLocalCode();
      }
    }
    if (!mounted) return;
    setState(() {
      _code = code;
      _loading = false;
    });
  }

  Future<void> _shareReferral(BuildContext context) async {
    if (_loading || _code.length != 8) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppConstants.msgErrorTryAgain)));
      return;
    }
    final text = AppConstants.referralWhatsAppMessage(_code);
    final uri = Uri.parse(
      'https://wa.me/?text=${Uri.encodeComponent(text)}',
    );
    try {
      FocusManager.instance.primaryFocus?.unfocus();
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        await SharePlus.instance.share(
          ShareParams(
            text: text,
            subject: AppConstants.referralShareSubject,
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      try {
        await SharePlus.instance.share(
          ShareParams(
            text: text,
            subject: AppConstants.referralShareSubject,
          ),
        );
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppConstants.msgWhatsAppOpenFailed)),
          );
        }
      }
    }
  }

  Future<void> _copyCode(BuildContext context) async {
    if (_loading || _code.length != 8) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppConstants.msgErrorTryAgain)));
      return;
    }
    await Clipboard.setData(ClipboardData(text: _code));
    if (!context.mounted) return;
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppConstants.msgReferralCopied,
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(viewInsets: EdgeInsets.zero),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppTheme.mainBackground,
        body: Column(
          children: [
            CommonNavBar(
              userName: widget.userName ?? AppConstants.defaultUserName,
              showBackButton: true,
              onBackPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: FadeTransition(
                  opacity: _entranceFade ?? _fadeOpaque,
                  child: SlideTransition(
                    position: _entranceSlide ?? _slideNone,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppConstants.referralUiTitle,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppConstants.referralUiSubtitle,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.secondaryText,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _loading
                                ? null
                                : () => _shareReferral(context),
                            borderRadius: BorderRadius.circular(16),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: AppTheme.orangeGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentOrange.withValues(
                                      alpha: 0.35,
                                    ),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: Center(
                                      child: Text(
                                        '\u20B9',
                                        style: GoogleFonts.inter(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.white,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      AppConstants.referralUiShareButton,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.white,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          AppConstants.referralUiOrCode,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _DashedReferralCodeCard(
                          code: _code,
                          loading: _loading,
                          cream: _referralCream,
                          gold: _referralGold,
                          onCopy: () => _copyCode(context),
                          copyLabel: AppConstants.referralUiCopy,
                        ),
                        const SizedBox(height: 32),
                        const SizedBox(height: 220, child: _ReferralLottie()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (widget.shellNav != null)
              CommonBottomNav(
                currentIndex: 2,
                onHomeTap: widget.shellNav!.onHome,
                onLeadsTap: widget.shellNav!.onLeads,
                onCenterTap: widget.shellNav!.onCenterPlus,
                onReferralTap: widget.shellNav!.onReferral,
                onMyLeadsTap: widget.shellNav!.onWallet,
              ),
          ],
        ),
      ),
    );
  }
}

/// **Only** [ReferralLottieCache.assetPath] — uses [ReferralLottieCache] when warmed up.
class _ReferralLottie extends StatefulWidget {
  const _ReferralLottie();

  @override
  State<_ReferralLottie> createState() => _ReferralLottieState();
}

class _ReferralLottieState extends State<_ReferralLottie> {
  Future<ByteData>? _bytesFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bytesFuture ??= _loadReferJsonBytes(context);
  }

  Future<ByteData> _loadReferJsonBytes(BuildContext context) async {
    try {
      return await rootBundle.load(ReferralLottieCache.assetPath);
    } catch (e, st) {
      debugPrint('refer.json rootBundle.load failed: $e\n$st');
    }
    return DefaultAssetBundle.of(context).load(ReferralLottieCache.assetPath);
  }

  Widget _lottieFromBytes(Uint8List bytes) {
    return Lottie.memory(
      bytes,
      repeat: true,
      fit: BoxFit.contain,
      backgroundLoading: true,
      options: LottieOptions(
        enableMergePaths: true,
        enableApplyingOpacityToLayers: true,
      ),
      frameBuilder: (context, child, composition) {
        if (composition == null) {
          return const SizedBox.expand();
        }
        return child;
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('refer.json Lottie.memory parse error: $error\n$stackTrace');
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'refer.json could not be played.\nTry re-export from LottieFiles for mobile.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.secondaryText,
                height: 1.35,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cached = ReferralLottieCache.bytes;
    if (cached != null) {
      return _lottieFromBytes(cached);
    }
    return FutureBuilder<ByteData>(
      future: _bytesFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('refer.json FutureBuilder error: ${snapshot.error}');
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'refer.json load failed.\nRun flutter clean && flutter pub get.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.secondaryText,
                  height: 1.35,
                ),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const SizedBox.expand();
        }
        final bytes = snapshot.data!.buffer.asUint8List();
        ReferralLottieCache.remember(bytes);
        return _lottieFromBytes(bytes);
      },
    );
  }
}

class _DashedReferralCodeCard extends StatelessWidget {
  const _DashedReferralCodeCard({
    required this.code,
    required this.loading,
    required this.cream,
    required this.gold,
    required this.onCopy,
    required this.copyLabel,
  });

  final String code;
  final bool loading;
  final Color cream;
  final Color gold;
  final VoidCallback onCopy;
  final String copyLabel;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(color: gold, strokeWidth: 1.5, radius: 12),
      child: Padding(
        padding: const EdgeInsets.all(1.5),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cream,
            borderRadius: BorderRadius.circular(10.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        code,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryText,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
              TextButton(
                onPressed: loading ? null : onCopy,
                style: TextButton.styleFrom(
                  foregroundColor: gold,
                  minimumSize: const Size(88, 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy_rounded, size: 18, color: gold),
                    const SizedBox(width: 6),
                    Text(
                      copyLabel,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: gold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rounded-rectangle dashed stroke drawn on widget bounds.
class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.radius = 12,
  });

  final Color color;
  final double strokeWidth;
  final double radius;

  static const double _dashWidth = 6;
  static const double _gapWidth = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final half = strokeWidth / 2;
    final rect = Rect.fromLTWH(
      half,
      half,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(radius.clamp(0, rect.shortestSide / 2)),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = min(distance + _dashWidth, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += _dashWidth + _gapWidth;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius;
  }
}
