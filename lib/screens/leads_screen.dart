import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../config/app_config.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/page_routes.dart';
import '../utils/user_prefs_helper.dart';
import '../widgets/common_nav_bar.dart';
import '../widgets/common_bottom_nav.dart';
import '../widgets/wallet_shell_nav.dart';
import 'add_lead_screen.dart';
import 'lead_list_screen.dart';
import 'wallet_screen.dart';
import 'referral_screen.dart';

/// Content-only widget for Leads (no nav/footer). Used by MainShellScreen.
class LeadsContent extends StatefulWidget {
  const LeadsContent({
    super.key,
    this.userName = AppConstants.defaultUserName,
    this.addLeadShellNav,
    this.api,
  });

  final String userName;
  final WalletShellNav? addLeadShellNav;
  final ApiServiceBase? api;

  @override
  State<LeadsContent> createState() => _LeadsContentState();
}

class _LeadsContentState extends State<LeadsContent> {
  ApiServiceBase get _api => widget.api ?? ApiService.instance;

  static List<Map<String, dynamic>>? _cachedLeads;

  List<Map<String, dynamic>> _leads = _cachedLeads ?? const [];

  static String _statusOf(Map<String, dynamic> lead) =>
      lead['status']?.toString().trim().toLowerCase() ?? '';

  static Map<String, dynamic> _normalizeLead(Map<String, dynamic> lead) {
    return {
      ...lead,
      'status': _statusOf(lead),
      'full_name': lead['full_name']?.toString() ?? '',
      'mobile_number': lead['mobile_number']?.toString() ?? '',
    };
  }

  int get _successCount =>
      _leads.where((l) => _statusOf(l) == 'approved').length;
  int get _inProcessCount => _leads
      .where(
        (l) =>
            _statusOf(l) == 'pending' ||
            _statusOf(l) == 'in_process',
      )
      .length;
  int get _rejectedCount =>
      _leads.where((l) => _statusOf(l) == 'rejected').length;

  @override
  void initState() {
    super.initState();
    _loadLeads();
  }

  Future<void> _loadLeads() async {
    try {
      final details = await UserPrefsHelper.getUserDetails();
      final mobile = details['mobile'] ?? '';
      if (mobile.isEmpty || mobile == AppConstants.defaultMaskedMobile) {
        if (mounted) setState(() => _leads = const []);
        return;
      }
      final user = await _api.getUserByMobile(mobile);
      final userId = user?['id']?.toString();
      if (userId == null || userId.isEmpty) {
        if (mounted) setState(() => _leads = const []);
        return;
      }
      final leads = await _api.getLeadsByUserId(userId);
      final normalized = leads.map(_normalizeLead).toList(growable: false);
      if (!mounted) return;
      _cachedLeads = normalized;
      setState(() => _leads = normalized);
    } catch (_) {
      if (!mounted) return;
      setState(() => _leads = _cachedLeads ?? const []);
    }
  }

  List<Map<String, dynamic>> _filterLeads(String? statusFilter) {
    if (statusFilter == null) return _leads;
    if (statusFilter == 'in_process') {
      return _leads.where((l) {
        final s = _statusOf(l);
        return s == 'in_process' || s == 'pending';
      }).toList();
    }
    return _leads.where((l) => _statusOf(l) == statusFilter).toList();
  }

  void _openLeadList(
    BuildContext context, {
    required String title,
    String? statusFilter,
  }) {
    Navigator.of(context).push(
      smoothPushRoute(
        LeadListScreen(
          title: title,
          leads: _filterLeads(statusFilter),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: _buildTotalLeadsCard(context),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildAddLeadButton(context),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: _buildEarnRewardsCard(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalLeadsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlueDark,
            AppTheme.primaryBlueDark.withValues(alpha: 0.85),
            AppTheme.primaryBlue.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.labelTotalAddedLeads,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppConstants.subtitleSeeAllLeads,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              Material(
                color: AppTheme.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () =>
                      _openLeadList(context, title: AppConstants.labelTotalAddedLeads),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppConstants.labelViewDetails,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded, color: AppTheme.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildLeadStatusChip(
                  AppConstants.labelSuccess,
                  _successCount,
                  AppTheme.success,
                  Icons.check_rounded,
                  () => _openLeadList(
                    context,
                    title: AppConstants.labelSuccess,
                    statusFilter: 'approved',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildLeadStatusChip(
                  AppConstants.labelInProcess,
                  _inProcessCount,
                  AppTheme.statusPendingFg,
                  Icons.refresh_rounded,
                  () => _openLeadList(
                    context,
                    title: AppConstants.labelInProcess,
                    statusFilter: 'in_process',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildLeadStatusChip(
                  AppConstants.labelRejected,
                  _rejectedCount,
                  AppTheme.error,
                  Icons.close_rounded,
                  () => _openLeadList(
                    context,
                    title: AppConstants.labelRejected,
                    statusFilter: 'rejected',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeadStatusChip(
    String label,
    int count,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.overlayDark(0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                '$count',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.secondaryText,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEarnRewardsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.overlayDark(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppConstants.titleAddLeadsEarnRewards,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppConstants.subtitleGetPaidPerLead,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.secondaryText,
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryBlue.withValues(alpha: 0.1),
                      AppTheme.primaryBlue.withValues(alpha: 0.06),
                      AppTheme.accentOrange.withValues(alpha: 0.06),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 220,
                      child: Lottie.asset(
                        AppConfig.moneyLottie,
                        fit: BoxFit.contain,
                        repeat: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: Material(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () async {
                              await Navigator.of(context).push(
                                smoothPushRoute(
                                  AddLeadScreen(
                                    userName: widget.userName,
                                    shellNav: widget.addLeadShellNav,
                                  ),
                                ),
                              );
                              if (context.mounted) _loadLeads();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Center(
                                child: Text(
                                  'Get Started',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddLeadButton(BuildContext context) {
    return Material(
      color: AppTheme.accentOrange,
      borderRadius: BorderRadius.circular(28),
      shadowColor: AppTheme.accentOrange.withValues(alpha: 0.5),
      elevation: 8,
      child: InkWell(
        onTap: () async {
          await Navigator.of(context).push(
            smoothPushRoute(
              AddLeadScreen(
                userName: widget.userName,
                shellNav: widget.addLeadShellNav,
              ),
            ),
          );
          if (mounted) {
            _loadLeads();
          }
        },
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, color: AppTheme.white, size: 24),
              const SizedBox(width: 10),
              Text(
                AppConstants.buttonAddLeadNow,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

WalletShellNav _leadsAddLeadShellNav(NavigatorState nav, String userName) {
  return WalletShellNav(
    onHome: () {
      nav.pop();
      nav.pop();
    },
    onLeads: () => nav.pop(),
    onReferral: () {
      nav.pop();
      Future.microtask(() {
        nav.push(
          smoothPushRoute(
            ReferralScreen(
              userName: userName,
              shellNav: _leadsReferralShellNav(nav, userName),
            ),
          ),
        );
      });
    },
    onCenterPlus: () {},
    onWallet: () {
      nav.pop();
      Future.microtask(() {
        nav.push(
          smoothPushRoute(
            WalletScreen(
              userName: userName,
              shellNav: _leadsWalletShellNav(nav, userName),
            ),
          ),
        );
      });
    },
  );
}

WalletShellNav _leadsWalletShellNav(NavigatorState nav, String userName) {
  return WalletShellNav(
    onHome: () {
      nav.pop();
      nav.pop();
    },
    onLeads: () => nav.pop(),
    onReferral: () {
      nav.pop();
      Future.microtask(() {
        nav.push(
          smoothPushRoute(
            ReferralScreen(
              userName: userName,
              shellNav: _leadsReferralShellNav(nav, userName),
            ),
          ),
        );
      });
    },
    onCenterPlus: () {
      nav.pop();
      Future.microtask(() {
        nav.push(
          smoothPushRoute(
            AddLeadScreen(
              userName: userName,
              shellNav: _leadsAddLeadShellNav(nav, userName),
            ),
          ),
        );
      });
    },
    onWallet: () {},
  );
}

WalletShellNav _leadsReferralShellNav(NavigatorState nav, String userName) {
  return WalletShellNav(
    onHome: () {
      nav.pop();
      nav.pop();
    },
    onLeads: () => nav.pop(),
    onReferral: () {},
    onCenterPlus: () {
      nav.pop();
      Future.microtask(() {
        nav.push(
          smoothPushRoute(
            AddLeadScreen(
              userName: userName,
              shellNav: _leadsAddLeadShellNav(nav, userName),
            ),
          ),
        );
      });
    },
    onWallet: () {
      nav.pop();
      Future.microtask(() {
        nav.push(
          smoothPushRoute(
            WalletScreen(
              userName: userName,
              shellNav: _leadsWalletShellNav(nav, userName),
            ),
          ),
        );
      });
    },
  );
}

class LeadsScreen extends StatelessWidget {
  final String userName;

  const LeadsScreen({super.key, this.userName = AppConstants.defaultUserName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBackground,
      body: Column(
        children: [
          CommonNavBar(
            userName: userName,
            showBackButton: true,
            onBackPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: LeadsContent(userName: userName),
          ),
          CommonBottomNav(
            currentIndex: 1,
            onHomeTap: () => Navigator.of(context).pop(),
            onLeadsTap: () {},
            onCenterTap: () {},
            onMyLeadsTap: () {
              final nav = Navigator.of(context);
              nav.push(
                smoothPushRoute(
                  WalletScreen(
                    userName: userName,
                    shellNav: _leadsWalletShellNav(nav, userName),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
