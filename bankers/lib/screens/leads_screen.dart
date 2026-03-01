import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_config.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/user_prefs_helper.dart';
import '../widgets/common_nav_bar.dart';
import '../widgets/common_bottom_nav.dart';
import '../widgets/app_image.dart';
import 'add_lead_screen.dart';
import 'lead_list_screen.dart';

/// Content-only widget for Leads (no nav/footer). Used by MainShellScreen.
class LeadsContent extends StatefulWidget {
  const LeadsContent({super.key});

  @override
  State<LeadsContent> createState() => _LeadsContentState();
}

class _LeadsContentState extends State<LeadsContent> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _leads = const [];

  int get _successCount =>
      _leads.where((l) => (l['status'] as String?) == 'approved').length;
  int get _inProcessCount => _leads
      .where(
        (l) =>
            (l['status'] as String?) == 'pending' ||
            (l['status'] as String?) == 'in_process',
      )
      .length;
  int get _rejectedCount =>
      _leads.where((l) => (l['status'] as String?) == 'rejected').length;
  int get _actionRequiredCount =>
      _leads.where((l) => (l['status'] as String?) == 'action_required').length;

  @override
  void initState() {
    super.initState();
    _loadLeads();
  }

  Future<void> _loadLeads() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final details = await UserPrefsHelper.getUserDetails();
      final mobile = details['mobile'] ?? '';
      if (mobile.isEmpty || mobile == AppConstants.defaultMaskedMobile) {
        setState(() {
          _leads = const [];
          _isLoading = false;
        });
        return;
      }
      final user = await ApiService.instance.getUserByMobile(mobile);
      final userId = user?['id']?.toString();
      if (userId == null || userId.isEmpty) {
        setState(() {
          _leads = const [];
          _isLoading = false;
        });
        return;
      }
      final leads = await ApiService.instance.getLeadsByUserId(userId);
      if (!mounted) return;
      setState(() {
        _leads = leads;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _leads = const [];
        _isLoading = false;
      });
    }
  }

  void _openLeadList(
    BuildContext context, {
    required String title,
    String? statusFilter,
  }) {
    List<Map<String, dynamic>> filtered;
    if (statusFilter == null) {
      filtered = _leads;
    } else if (statusFilter == 'in_process') {
      filtered = _leads
          .where(
            (l) =>
                (l['status'] as String?) == 'in_process' ||
                (l['status'] as String?) == 'pending',
          )
          .toList();
    } else {
      filtered = _leads
          .where((l) => (l['status'] as String?) == statusFilter)
          .toList();
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LeadListScreen(
          title: title,
          leads: filtered,
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
            AppTheme.primaryBlueDark.withOpacity(0.85),
            AppTheme.primaryBlue.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.35),
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
                      color: AppTheme.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              Material(
                color: AppTheme.white.withOpacity(0.25),
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
                    statusFilter: 'pending',
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
              const SizedBox(width: 10),
              Expanded(
                child: _buildLeadStatusChip(
                  AppConstants.labelActionRequired,
                  _actionRequiredCount,
                  AppTheme.warning,
                  Icons.warning_amber_rounded,
                  () => _openLeadList(
                    context,
                    title: AppConstants.labelActionRequired,
                    statusFilter: 'action_required',
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
        onTap: _isLoading || count == 0 ? null : onTap,
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
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                _isLoading ? '-' : '$count',
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
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryBlue.withOpacity(0.1),
                      AppTheme.primaryBlue.withOpacity(0.06),
                      AppTheme.accentOrange.withOpacity(0.06),
                    ],
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events_rounded, size: 72, color: AppTheme.accentOrange.withOpacity(0.9)),
                      const SizedBox(width: 16),
                      Icon(Icons.currency_rupee_rounded, size: 48, color: AppTheme.primaryBlue.withOpacity(0.8)),
                      Icon(Icons.monetization_on_rounded, size: 40, color: AppTheme.warning.withOpacity(0.9)),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 44,
                    width: double.infinity,
                    child: AppImage(
                      assetPath: AppConfig.leadsPromo,
                      fit: BoxFit.cover,
                    ),
                  ),
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
      shadowColor: AppTheme.accentOrange.withOpacity(0.5),
      elevation: 8,
      child: InkWell(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddLeadScreen()),
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
          const Expanded(child: LeadsContent()),
          CommonBottomNav(
            currentIndex: 1,
            onHomeTap: () => Navigator.of(context).pop(),
            onLeadsTap: () {},
            onCenterTap: () {},
          ),
        ],
      ),
    );
  }
}
