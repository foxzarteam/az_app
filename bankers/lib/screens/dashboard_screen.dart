import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/constants.dart';
import '../utils/user_prefs_helper.dart';
import '../utils/page_routes.dart';
import '../theme/app_theme.dart';
import '../widgets/user_qr_code_widget.dart';
import '../widgets/carousel_banner.dart';
import '../widgets/dynamic_image.dart';
import '../widgets/common_nav_bar.dart';
import '../widgets/common_bottom_nav.dart';
import '../widgets/drawer_menu_item.dart';
import '../services/api_service.dart';
import 'personal_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;

  const DashboardScreen({super.key, required this.userName});

  static void showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _ShareSheetContent(message: AppConstants.shareMessagePersonalLoan),
    );
  }

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<String> _bannerUrls = [];
  String? _kycBannerUrl;
  bool _isLoadingBanners = true;
  bool _isLoadingKyc = true;

  @override
  void initState() {
    super.initState();
    _loadBanners();
    _loadKycBanner();
  }

  Future<void> _loadBanners() async {
    try {
      final bannersData = await ApiService.instance.getBanners(category: 'carousel');
      if (mounted) {
        setState(() {
          _bannerUrls = bannersData
              .map((banner) => banner['imageUrl'] as String? ?? '')
              .where((url) => url.isNotEmpty)
              .toList();
          _isLoadingBanners = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _bannerUrls = [];
          _isLoadingBanners = false;
        });
      }
    }
  }

  Future<void> _loadKycBanner() async {
    try {
      final kycBanners = await ApiService.instance.getBanners(category: 'kyc');
      if (mounted) {
        setState(() {
          _kycBannerUrl = kycBanners.isNotEmpty
              ? (kycBanners.first['imageUrl'] as String? ?? '')
              : null;
          _isLoadingKyc = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _kycBannerUrl = null;
          _isLoadingKyc = false;
        });
      }
    }
  }

  void _openPersonalDetails(BuildContext context) {
    Navigator.of(context).pop();
    UserPrefsHelper.getUserDetails().then((details) {
      if (!context.mounted) return;
      final mobile = details['mobile'] ?? '';
      Navigator.of(context).push(
        slideFromRightRoute(
          PersonalDetailsScreen(
            userName: widget.userName,
            mobileNumber: mobile,
          ),
        ),
      );
    });
  }

  void _showProfileDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => _buildProfileDrawer(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final slideAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(curvedAnimation);
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation);
        final scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(curvedAnimation);
        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          ),
        );
      },
    );
  }

  void _showShareOptions() {
    DashboardScreen.showShareOptions(context);
  }

  Widget _buildProfileDrawer() {
    final size = MediaQuery.of(context).size;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: size.width * 0.9,
        height: size.height,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(-5, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppConstants.labelProfile,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.darkBlue,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(AppConstants.borderColor).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppTheme.primaryText,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    FutureBuilder<Map<String, String>>(
                      future: UserPrefsHelper.getUserDetails(),
                      builder: (context, snapshot) {
                        final mobile = snapshot.data?['mobile'] ?? AppConstants.defaultMaskedMobile;
                        return UserQrCodeWidget(
                          userName: widget.userName,
                          mobileNumber: mobile,
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    DrawerMenuItem(
                      icon: Icons.person_outline_rounded,
                      title: AppConstants.labelPersonalDetails,
                      subtitle: AppConstants.subtitlePersonalDetails,
                      color: AppTheme.accentOrange,
                      onTap: () => _openPersonalDetails(context),
                    ),
                    const SizedBox(height: 16),
                    DrawerMenuItem(
                      icon: Icons.people_outline_rounded,
                      title: AppConstants.labelMyLead,
                      subtitle: AppConstants.subtitleMyLead,
                      color: AppTheme.primaryBlue,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 16),
                    DrawerMenuItem(
                      icon: Icons.privacy_tip_outlined,
                      title: AppConstants.labelPrivacyPolicy,
                      subtitle: AppConstants.subtitlePrivacyPolicy,
                      color: AppTheme.primaryBlue,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 16),
                    DrawerMenuItem(
                      icon: Icons.settings_outlined,
                      title: AppConstants.labelSettings,
                      subtitle: AppConstants.subtitleSettings,
                      color: AppTheme.accentOrange,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          CommonNavBar(
            userName: widget.userName,
            onAvatarTap: _showProfileDrawer,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _DashboardBodyBuilder(
              onShare: _showShareOptions,
              bannerUrls: _bannerUrls,
              isLoadingBanners: _isLoadingBanners,
              kycBannerUrl: _kycBannerUrl,
              isLoadingKyc: _isLoadingKyc,
            ),
          ),
        ],
      ),
      bottomNavigationBar: CommonBottomNav(
        currentIndex: 0,
        onLeadsTap: () {},
      ),
    );
  }
}

class _ShareSheetContent extends StatelessWidget {
  final String message;

  const _ShareSheetContent({required this.message});

  /// Shares the personal loan message (text). User can paste image manually if needed.
  static Future<void> _shareWithImage(String message) async {
    await Share.share(
      message,
      subject: AppConstants.shareSubjectPersonalLoan,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            AppConstants.shareTitlePersonalLoan,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.darkBlue,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShareOption(
                context: context,
                icon: Icons.email_outlined,
                label: AppConstants.shareLabelMail,
                color: Colors.blue,
                onTap: () async {
                  Navigator.pop(context);
                  await _shareWithImage(message);
                },
              ),
              _buildShareOption(
                context: context,
                icon: Icons.chat_bubble_outline,
                label: AppConstants.shareLabelWhatsApp,
                color: const Color(0xFF25D366),
                onTap: () async {
                  Navigator.pop(context);
                  await _shareWithImage(message);
                },
              ),
              _buildShareOption(
                context: context,
                icon: Icons.camera_alt_outlined,
                label: AppConstants.shareLabelInstagram,
                color: const Color(0xFFE4405F),
                onTap: () async {
                  Navigator.pop(context);
                  await _shareWithImage(message);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildShareOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

/// Body-only for shell (no nav/footer). Uses same content as dashboard.
class DashboardBody extends StatefulWidget {
  final VoidCallback onSharePersonalLoan;

  const DashboardBody({super.key, required this.onSharePersonalLoan});

  @override
  State<DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<DashboardBody> {
  List<String> _bannerUrls = [];
  String? _kycBannerUrl;
  bool _isLoadingBanners = true;
  bool _isLoadingKyc = true;

  @override
  void initState() {
    super.initState();
    _loadBanners();
    _loadKycBanner();
  }

  Future<void> _loadBanners() async {
    try {
      final bannersData = await ApiService.instance.getBanners(category: 'carousel');
      if (mounted) {
        setState(() {
          _bannerUrls = bannersData
              .map((banner) => banner['imageUrl'] as String? ?? '')
              .where((url) => url.isNotEmpty)
              .toList();
          _isLoadingBanners = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _bannerUrls = [];
          _isLoadingBanners = false;
        });
      }
    }
  }

  Future<void> _loadKycBanner() async {
    try {
      final kycBanners = await ApiService.instance.getBanners(category: 'kyc');
      if (mounted) {
        setState(() {
          _kycBannerUrl = kycBanners.isNotEmpty
              ? (kycBanners.first['imageUrl'] as String? ?? '')
              : null;
          _isLoadingKyc = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _kycBannerUrl = null;
          _isLoadingKyc = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _DashboardBodyBuilder(
      onShare: widget.onSharePersonalLoan,
      bannerUrls: _bannerUrls,
      isLoadingBanners: _isLoadingBanners,
      kycBannerUrl: _kycBannerUrl,
      isLoadingKyc: _isLoadingKyc,
    );
  }
}

/// Wraps horizontal scroll with Scrollbar using a single ScrollController (fixes "no ScrollPosition attached").
class _HorizontalScrollWithBar extends StatefulWidget {
  const _HorizontalScrollWithBar({required this.child});
  final Widget child;

  @override
  State<_HorizontalScrollWithBar> createState() => _HorizontalScrollWithBarState();
}

class _HorizontalScrollWithBarState extends State<_HorizontalScrollWithBar> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controller,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        child: widget.child,
      ),
    );
  }
}

class _DashboardBodyBuilder extends StatelessWidget {
  final VoidCallback onShare;
  final List<String> bannerUrls;
  final bool isLoadingBanners;
  final String? kycBannerUrl;
  final bool isLoadingKyc;

  const _DashboardBodyBuilder({
    required this.onShare,
    this.bannerUrls = const [],
    this.isLoadingBanners = false,
    this.kycBannerUrl,
    this.isLoadingKyc = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(AppTheme.primaryBlueDark, AppTheme.primaryBlue, AppTheme.accentOrange, AppTheme.yellow),
            const SizedBox(height: 32),
            _buildSellAndEarnSection(AppTheme.primaryBlue, AppTheme.accentOrange, AppTheme.primaryBlueDark),
            const SizedBox(height: 24),
            _buildCarouselBanner(),
            const SizedBox(height: 24),
            _buildKYCBanner(AppTheme.primaryBlue, AppTheme.accentOrange),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(Color primaryDark, Color primary, Color accentOrange, Color yellow) {
    return _copyOfBuildBalanceCard(primaryDark, primary, accentOrange, yellow);
  }

  Widget _buildSellAndEarnSection(Color primary, Color accentOrange, Color primaryDark) {
    return _copyOfBuildSellAndEarnSection(primary, accentOrange, primaryDark);
  }

  Widget _buildKYCBanner(Color darkBlue, Color accentOrange) {
    return _copyOfBuildKYCBanner(darkBlue, accentOrange, kycBannerUrl, isLoadingKyc);
  }


  Widget _buildCarouselBanner() {
    if (bannerUrls.isNotEmpty) {
      return CarouselBanner(
        imageUrls: bannerUrls,
        height: 120,
        autoScrollDuration: const Duration(seconds: 4),
      );
    }
    if (isLoadingBanners) {
      return Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          'No banners',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ),
    );
  }


  static Widget _copyOfBuildBalanceCard(Color primaryDark, Color primary, Color accentOrange, Color yellow) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryDark, primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10), spreadRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [accentOrange.withOpacity(0.3), accentOrange.withOpacity(0.1)]),
                  shape: BoxShape.circle,
                  border: Border.all(color: accentOrange.withOpacity(0.3), width: 2),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 24),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [accentOrange, accentOrange.withOpacity(0.8)]),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: accentOrange.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Text('ADD LEAD', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Balance', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text('₹0.00', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.8)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.only(top: 14),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withOpacity(0.2), width: 1))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Earning', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500)),
                Text('₹0.00', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _copyOfBuildSellAndEarnSection(Color primary, Color accentOrange, Color primaryDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, accentOrange.withOpacity(0.3), Colors.transparent])))),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('SELL & EARN', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: accentOrange, letterSpacing: 1))),
            Expanded(child: Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, accentOrange.withOpacity(0.3), Colors.transparent])))),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 132,
          child: _HorizontalScrollWithBar(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 118, child: _buildServiceCard(icon: Icons.account_balance_wallet_rounded, title: 'Personal Loan', subtitle: 'Earn upto 4.00%', iconColor: accentOrange, bottomColor: accentOrange.withOpacity(0.2), onTap: onShare)),
                const SizedBox(width: 6),
                SizedBox(width: 118, child: _buildServiceCard(icon: Icons.credit_card_rounded, title: 'Credit Card', subtitle: 'Earn upto ₹3000', iconColor: Colors.blue, bottomColor: accentOrange.withOpacity(0.2))),
                const SizedBox(width: 6),
                SizedBox(width: 118, child: _buildServiceCard(icon: Icons.shield_rounded, title: 'Insurance', subtitle: 'Earn upto ₹2000', iconColor: Colors.green, bottomColor: accentOrange.withOpacity(0.2))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard({required IconData icon, required String title, required String subtitle, required Color iconColor, required Color bottomColor, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.accentOrange.withOpacity(0.2), width: 1.5),
          boxShadow: [BoxShadow(color: AppTheme.accentOrange.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4), spreadRadius: 0)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [iconColor.withOpacity(0.2), iconColor.withOpacity(0.1)]),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: iconColor.withOpacity(0.3), width: 1),
                      ),
                      child: Icon(icon, color: iconColor, size: 28),
                    ),
                    const Spacer(),
                    Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryText)),
                    const SizedBox(height: 2),
                    Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.accentOrange)),
                  ],
                ),
              ),
            ),
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [bottomColor, bottomColor.withOpacity(0.5)]),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _copyOfBuildKYCBanner(
    Color darkBlue,
    Color accentOrange,
    String? kycBannerUrl,
    bool isLoadingKyc,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [accentOrange.withOpacity(0.1), accentOrange.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentOrange.withOpacity(0.3), width: 2),
        boxShadow: [BoxShadow(color: accentOrange.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 64,
              height: 64,
              child: isLoadingKyc
                  ? Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : DynamicImage(
                      imageUrl: kycBannerUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Complete Your KYC', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: darkBlue)),
                const SizedBox(height: 4),
                Text('check leads Now!', style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.secondaryText, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: accentOrange.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_forward_ios_rounded, color: Color(AppConstants.accentColor), size: 18),
          ),
        ],
      ),
    );
  }
}
