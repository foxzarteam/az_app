import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_locale.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../utils/user_prefs_helper.dart';
import '../utils/page_routes.dart';
import '../utils/product_share.dart';
import '../theme/app_theme.dart';
import '../widgets/user_qr_code_widget.dart';
import '../widgets/wallet_shell_nav.dart';
import '../config/app_config.dart';
import '../widgets/carousel_banner.dart';
import '../widgets/common_nav_bar.dart';
import '../widgets/common_bottom_nav.dart';
import '../widgets/drawer_menu_item.dart';
import 'add_lead_screen.dart';
import 'leads_screen.dart';
import 'wallet_screen.dart';
import 'personal_details_screen.dart';
import 'privacy_policy_screen.dart';
import 'referral_screen.dart';

String walletNumToDisplay(dynamic v) {
  if (v == null) return '0.00';
  if (v is int) return v == 0 ? '0.00' : v.toString();
  if (v is double) return v.toStringAsFixed(2);
  final s = v.toString().trim();
  return s.isEmpty ? '0.00' : s;
}

class DashboardScreen extends StatefulWidget {
  final String userName;

  const DashboardScreen({super.key, required this.userName});

  /// Opens device native share sheet directly with template message (no popup).
  static void showShareOptions(BuildContext context) {
    showShareForProduct(context, 'Personal Loan');
  }

  /// Opens share sheet with product-specific template (e.g. Personal Loan, Home Loan). No navigation to lead page.
  /// Each product uses its banner (`w1.png`–`w6.png`) plus text when the asset exists.
  static void showShareForProduct(BuildContext context, String productTitle) {
    ProductShare.shareProduct(context, productTitle);
  }

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static Map<String, String> get _categoryPromoUrls => {
    'personal_loan': AppConfig.personalLoanPromo,
    'credit_card': AppConfig.creditCardPromo,
    'insurance': AppConfig.insurancePromo,
  };

  String _balanceStr = '0.00';
  String _earningStr = '0.00';

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    final mobile = await UserPrefsHelper.getMobileNumber();
    if (mobile.isEmpty || mobile == AppConstants.defaultMaskedMobile) return;
    final user = await ApiService.instance.getUserByMobile(mobile);
    final userId = user?['id']?.toString();
    if (userId == null || userId.isEmpty) return;
    final wallet = await ApiService.instance.getWallet(userId);
    if (!mounted) return;
    if (wallet != null) {
      setState(() {
        _balanceStr = walletNumToDisplay(wallet['balance']);
        _earningStr = walletNumToDisplay(wallet['earning']);
      });
    }
  }

  void _openPersonalDetails(BuildContext context) {
    Navigator.of(context).pop();
    _pushPersonalDetailsScreen(context);
  }

  void _pushPersonalDetailsScreen(BuildContext context) {
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
      barrierColor: AppTheme.overlayDark(0.5),
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

  WalletShellNav _dashboardReferralShellNav() {
    return WalletShellNav(
      onHome: () => Navigator.of(context).pop(),
      onLeads: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          smoothPushRoute(
            LeadsScreen(userName: widget.userName),
          ),
        );
      },
      onReferral: () {},
      onCenterPlus: () {
        final nav = Navigator.of(context);
        nav.pop();
        Future.microtask(() {
          if (!mounted) return;
          nav.push(
            smoothPushRoute(
              AddLeadScreen(
                userName: widget.userName,
                shellNav: _dashboardAddLeadShellNav(),
              ),
            ),
          );
        });
      },
      onWallet: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          smoothPushRoute(
            WalletScreen(
              userName: widget.userName,
              shellNav: _dashboardWalletShellNav(),
            ),
          ),
        );
      },
    );
  }

  WalletShellNav _dashboardWalletShellNav() {
    return WalletShellNav(
      onHome: () => Navigator.of(context).pop(),
      onLeads: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          smoothPushRoute(
            LeadsScreen(userName: widget.userName),
          ),
        );
      },
      onReferral: () {
        final nav = Navigator.of(context);
        final name = widget.userName;
        nav.pop();
        Future.microtask(() {
          if (!mounted) return;
          nav.push(
            smoothPushRoute(
              ReferralScreen(
                userName: name,
                shellNav: _dashboardReferralShellNav(),
              ),
            ),
          );
        });
      },
      onCenterPlus: () {
        final nav = Navigator.of(context);
        nav.pop();
        Future.microtask(() {
          if (!mounted) return;
          nav.push(
            smoothPushRoute(
              AddLeadScreen(
                userName: widget.userName,
                shellNav: _dashboardAddLeadShellNav(),
              ),
            ),
          );
        });
      },
      onWallet: () {},
    );
  }

  WalletShellNav _dashboardAddLeadShellNav() {
    return WalletShellNav(
      onHome: () => Navigator.of(context).pop(),
      onLeads: () {
        final nav = Navigator.of(context);
        nav.pop();
        Future.microtask(() {
          if (!mounted) return;
          nav.push(
            smoothPushRoute(LeadsScreen(userName: widget.userName)),
          );
        });
      },
      onReferral: () {
        final nav = Navigator.of(context);
        final name = widget.userName;
        nav.pop();
        Future.microtask(() {
          if (!mounted) return;
          nav.push(
            smoothPushRoute(
              ReferralScreen(
                userName: name,
                shellNav: _dashboardReferralShellNav(),
              ),
            ),
          );
        });
      },
      onCenterPlus: () {},
      onWallet: () {
        final nav = Navigator.of(context);
        nav.pop();
        Future.microtask(() {
          if (!mounted) return;
          nav.push(
            smoothPushRoute(
              WalletScreen(
                userName: widget.userName,
                shellNav: _dashboardWalletShellNav(),
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildProfileDrawer() {
    final size = MediaQuery.of(context).size;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: size.width * 0.9,
        height: size.height,
        decoration: const BoxDecoration(
          color: AppTheme.white,
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
                      context.t('labelProfile'),
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkBlue,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.borderColor.withOpacity(0.2),
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
                      title: context.t('labelPersonalDetails'),
                      subtitle: context.t('subtitlePersonalDetails'),
                      color: AppTheme.accentOrange,
                      onTap: () => _openPersonalDetails(context),
                    ),
                    const SizedBox(height: 16),
                    DrawerMenuItem(
                      icon: Icons.people_outline_rounded,
                      title: context.t('labelMyLead'),
                      subtitle: context.t('subtitleMyLead'),
                      color: AppTheme.primaryBlue,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => LeadsScreen(userName: widget.userName),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    DrawerMenuItem(
                      icon: Icons.privacy_tip_outlined,
                      title: context.t('labelPrivacyPolicy'),
                      subtitle: context.t('subtitlePrivacyPolicy'),
                      color: AppTheme.primaryBlue,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          smoothPushRoute(
                            PrivacyPolicyScreen(userName: widget.userName),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    DrawerMenuItem(
                      icon: Icons.account_balance_wallet_rounded,
                      title: context.t('labelWallet'),
                      subtitle: context.t('subtitleWallet'),
                      color: AppTheme.accentOrange,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          smoothPushRoute(
                            WalletScreen(
                              userName: widget.userName,
                              shellNav: _dashboardWalletShellNav(),
                            ),
                          ),
                        );
                      },
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
      resizeToAvoidBottomInset: false,
      backgroundColor: AppTheme.white,
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
              onAddLeadTap: () => Navigator.of(context).push(
                    smoothPushRoute(
                      AddLeadScreen(
                        userName: widget.userName,
                        shellNav: _dashboardAddLeadShellNav(),
                      ),
                    ),
                  ),
              onWalletTap: () => Navigator.of(context).push(
                    smoothPushRoute(
                      WalletScreen(
                        userName: widget.userName,
                        shellNav: _dashboardWalletShellNav(),
                      ),
                    ),
                  ),
              onKycTap: () => _pushPersonalDetailsScreen(context),
              carouselPaths: AppConfig.carousel,
              kycBannerPath: AppConfig.kycBanner,
              categoryPromoPaths: _categoryPromoUrls,
              balanceStr: _balanceStr,
              earningStr: _earningStr,
            ),
          ),
        ],
      ),
      bottomNavigationBar: CommonBottomNav(
        currentIndex: 0,
        onLeadsTap: () {},
        onMyLeadsTap: () => Navigator.of(context).push(
              smoothPushRoute(
                WalletScreen(
                  userName: widget.userName,
                  shellNav: _dashboardWalletShellNav(),
                ),
              ),
            ),
      ),
    );
  }
}

/// Body-only for shell (no nav/footer). Uses same content as dashboard.
class DashboardBody extends StatefulWidget {
  final VoidCallback onSharePersonalLoan;
  final VoidCallback? onAddLeadTap;
  final VoidCallback? onWalletTap;
  final VoidCallback? onKycTap;

  const DashboardBody({
    super.key,
    required this.onSharePersonalLoan,
    this.onAddLeadTap,
    this.onWalletTap,
    this.onKycTap,
  });

  @override
  State<DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<DashboardBody> {
  static Map<String, String> get _categoryPromoPaths => {
    'personal_loan': AppConfig.personalLoanPromo,
    'credit_card': AppConfig.creditCardPromo,
    'insurance': AppConfig.insurancePromo,
  };

  String _balanceStr = '0.00';
  String _earningStr = '0.00';

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    final mobile = await UserPrefsHelper.getMobileNumber();
    if (mobile.isEmpty || mobile == AppConstants.defaultMaskedMobile) return;
    final user = await ApiService.instance.getUserByMobile(mobile);
    final userId = user?['id']?.toString();
    if (userId == null || userId.isEmpty) return;
    final wallet = await ApiService.instance.getWallet(userId);
    if (!mounted) return;
    if (wallet != null) {
      setState(() {
        _balanceStr = walletNumToDisplay(wallet['balance']);
        _earningStr = walletNumToDisplay(wallet['earning']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _DashboardBodyBuilder(
      onShare: widget.onSharePersonalLoan,
      onAddLeadTap: widget.onAddLeadTap,
      onWalletTap: widget.onWalletTap,
      onKycTap: widget.onKycTap,
      carouselPaths: AppConfig.carousel,
      kycBannerPath: AppConfig.kycBanner,
      categoryPromoPaths: _categoryPromoPaths,
      balanceStr: _balanceStr,
      earningStr: _earningStr,
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
  final VoidCallback? onAddLeadTap;
  final VoidCallback? onWalletTap;
  final VoidCallback? onKycTap;
  final List<String> carouselPaths;
  final String kycBannerPath;
  final Map<String, String> categoryPromoPaths;
  final String balanceStr;
  final String earningStr;

  const _DashboardBodyBuilder({
    required this.onShare,
    this.onAddLeadTap,
    this.onWalletTap,
    this.onKycTap,
    this.carouselPaths = const [],
    required this.kycBannerPath,
    this.categoryPromoPaths = const {},
    this.balanceStr = '0.00',
    this.earningStr = '0.00',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.white,
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
            _buildBalanceCard(AppTheme.primaryBlueDark, AppTheme.primaryBlue, AppTheme.accentOrange, AppTheme.yellow, onWalletTap, balanceStr: balanceStr, earningStr: earningStr),
            const SizedBox(height: 32),
            _buildSellAndEarnSection(context, AppTheme.primaryBlue, AppTheme.accentOrange, AppTheme.primaryBlueDark),
            const SizedBox(height: 24),
            _buildCarouselBanner(),
            const SizedBox(height: 24),
            _buildKYCBanner(AppTheme.primaryBlue, AppTheme.accentOrange, onKycTap),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(Color primaryDark, Color primary, Color accentOrange, Color yellow, VoidCallback? onWalletTap, {String balanceStr = '0.00', String earningStr = '0.00'}) {
    return _copyOfBuildBalanceCard(primaryDark, primary, accentOrange, yellow, onAddLeadTap, onBalanceCardTap: onWalletTap, balanceStr: balanceStr, earningStr: earningStr);
  }

  Widget _buildSellAndEarnSection(BuildContext context, Color primary, Color accentOrange, Color primaryDark) {
    return _copyOfBuildSellAndEarnSection(context, primary, accentOrange, primaryDark, categoryPromoPaths);
  }

  Widget _buildKYCBanner(Color darkBlue, Color accentOrange, VoidCallback? onKycTap) {
    return _copyOfBuildKYCBanner(darkBlue, accentOrange, kycBannerPath, onKycTap);
  }

  Widget _buildCarouselBanner() {
    if (carouselPaths.isNotEmpty) {
      return CarouselBanner(
        assetPaths: carouselPaths,
        autoScrollDuration: const Duration(seconds: 4),
      );
    }
    return AspectRatio(
      aspectRatio: 3 / 1,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.borderColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No banners',
            style: TextStyle(color: AppTheme.secondaryText, fontSize: 14),
          ),
        ),
      ),
    );
  }

  static Widget _copyOfBuildBalanceCard(Color primaryDark, Color primary, Color accentOrange, Color yellow, VoidCallback? onAddLeadTap, {VoidCallback? onBalanceCardTap, String balanceStr = '0.00', String earningStr = '0.00'}) {
    final content = Container(
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
                child: const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.white, size: 24),
              ),
              const SizedBox(width: 10),
              Text('Balance', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.white.withOpacity(0.9), fontWeight: FontWeight.w500)),
              const Spacer(),
              GestureDetector(
                onTap: onAddLeadTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: accentOrange.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Text('ADD LEAD', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.white, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text('₹$balanceStr', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w500, color: AppTheme.white, letterSpacing: 0.8)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.only(top: 14),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: AppTheme.white.withOpacity(0.2), width: 1))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Earning', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.white.withOpacity(0.9), fontWeight: FontWeight.w500)),
                Text('₹$earningStr', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.white)),
              ],
            ),
          ),
        ],
      ),
    );
    if (onBalanceCardTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onBalanceCardTap,
          borderRadius: BorderRadius.circular(20),
          child: content,
        ),
      );
    }
    return content;
  }

  Widget _copyOfBuildSellAndEarnSection(BuildContext context, Color primary, Color accentOrange, Color primaryDark, Map<String, String> categoryPromoPaths) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, accentOrange.withOpacity(0.3), Colors.transparent])))),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('SELL & EARN', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: accentOrange, letterSpacing: 1))),
            Expanded(child: Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, accentOrange.withOpacity(0.3), Colors.transparent])))),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Padding(padding: const EdgeInsets.only(right: 3), child: _buildServiceCard(icon: Icons.account_balance_wallet_rounded, title: 'Personal Loan', subtitle: 'Earn upto 4.00%', iconColor: accentOrange, bottomColor: accentOrange.withOpacity(0.2), onTap: () => DashboardScreen.showShareForProduct(context, 'Personal Loan')))),
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: _buildServiceCard(icon: Icons.home_rounded, title: 'Home Loan', subtitle: 'Earn upto 3.50%', iconColor: primary, bottomColor: accentOrange.withOpacity(0.2), onTap: () => DashboardScreen.showShareForProduct(context, 'Home Loan')))),
            Expanded(child: Padding(padding: const EdgeInsets.only(left: 3), child: _buildServiceCard(icon: Icons.business_rounded, title: 'Business Loan', subtitle: 'Earn upto 2.50%', iconColor: const Color(0xFF7C3AED), bottomColor: accentOrange.withOpacity(0.2), onTap: () => DashboardScreen.showShareForProduct(context, 'Business Loan')))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Padding(padding: const EdgeInsets.only(right: 3), child: _buildServiceCard(icon: Icons.credit_card_rounded, title: 'Credit Card', subtitle: 'Earn upto ₹3000', iconColor: AppTheme.socialMail, bottomColor: accentOrange.withOpacity(0.2), onTap: () => DashboardScreen.showShareForProduct(context, 'Credit Card')))),
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: _buildServiceCard(icon: Icons.shield_rounded, title: 'Insurance', subtitle: 'Earn upto ₹2000', iconColor: AppTheme.success, bottomColor: accentOrange.withOpacity(0.2), onTap: () => DashboardScreen.showShareForProduct(context, 'Insurance')))),
            Expanded(child: Padding(padding: const EdgeInsets.only(left: 3), child: _buildServiceCard(icon: Icons.directions_car_rounded, title: 'Vehicle Loan', subtitle: 'Earn upto 2.00%', iconColor: AppTheme.primaryBlue, bottomColor: accentOrange.withOpacity(0.2), onTap: () => DashboardScreen.showShareForProduct(context, 'Vehicle Loan')))),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceCard({required IconData icon, required String title, required String subtitle, required Color iconColor, required Color bottomColor, VoidCallback? onTap}) {
    const double circleRadius = 28.0;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: circleRadius),
            padding: const EdgeInsets.fromLTRB(10, circleRadius + 8, 10, 14),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.overlayDark(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryText),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: AppTheme.accentOrange),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              width: circleRadius * 2,
              height: circleRadius * 2,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: iconColor.withOpacity(0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.overlayDark(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _copyOfBuildKYCBanner(
    Color darkBlue,
    Color accentOrange,
    String kycBannerPath,
    VoidCallback? onKycTap,
  ) {
    final radius = BorderRadius.circular(20);
    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: radius,
        border: Border.all(color: AppTheme.borderColor, width: 1),
        boxShadow: [BoxShadow(color: AppTheme.primaryText.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: darkBlue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: darkBlue.withOpacity(0.25)),
            ),
            child: Icon(Icons.verified_user_rounded, color: darkBlue, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Complete Your KYC', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: darkBlue)),
                const SizedBox(height: 4),
                Text('check leads Now!', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.secondaryText, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.surfaceWhite, shape: BoxShape.circle, border: Border.all(color: AppTheme.borderColor)),
            child: Icon(Icons.arrow_forward_ios_rounded, color: darkBlue, size: 18),
          ),
        ],
      ),
    );

    if (onKycTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onKycTap,
        borderRadius: radius,
        child: card,
      ),
    );
  }
}
