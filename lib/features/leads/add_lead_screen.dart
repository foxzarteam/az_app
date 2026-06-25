import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/constants.dart';
import '../../core/utils/page_routes.dart';
import '../../core/widgets/common_bottom_nav.dart';
import '../../core/widgets/services_refresh_scroll.dart';
import '../../core/widgets/common_nav_bar.dart';
import '../../core/widgets/wallet_shell_nav.dart';
import '../home/services_controller.dart';
import '../referral/referral_screen.dart';
import '../wallet/wallet_screen.dart';
import 'lead_form_screen.dart';
import 'leads_screen.dart';
import 'widgets/active_services_list.dart';

class AddLeadScreen extends StatefulWidget {
  const AddLeadScreen({super.key, this.userName, this.shellNav});

  /// Shown in the app bar; falls back to [AppConstants.defaultUserName].
  final String? userName;

  /// When set (e.g. from [MainShellScreen]), bottom bar pops/switches like other shell pages.
  final WalletShellNav? shellNav;

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  String get _name => widget.userName ?? AppConstants.defaultUserName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServicesController>().onScreenVisible();
    });
  }

  static void _openLeadForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LeadFormScreen()),
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
              child: ServicesRefreshScroll(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShareHeader(),
                    const SizedBox(height: 24),
                    _buildActionButtons(context),
                    const SizedBox(height: 24),
                    const ActiveServicesList(),
                  ],
                ),
              ),
            ),
            CommonBottomNav(
              currentIndex: 4,
              onHomeTap: () {
                if (widget.shellNav != null) {
                  widget.shellNav!.onHome();
                  return;
                }
                Navigator.of(context).pop();
              },
              onLeadsTap: () {
                if (widget.shellNav != null) {
                  widget.shellNav!.onLeads();
                  return;
                }
                final nav = Navigator.of(context);
                nav.pop();
                Future.microtask(() {
                  nav.push(smoothPushRoute(LeadsScreen(userName: _name)));
                });
              },
              onCenterTap: () {
                widget.shellNav?.onCenterPlus();
              },
              onReferralTap: () {
                if (widget.shellNav != null) {
                  widget.shellNav!.onReferral();
                  return;
                }
                Navigator.of(context).push(
                  smoothPushRoute(ReferralScreen(userName: _name)),
                );
              },
              onMyLeadsTap: () {
                if (widget.shellNav != null) {
                  widget.shellNav!.onWallet();
                  return;
                }
                Navigator.of(context).push(
                  smoothPushRoute(WalletScreen(userName: _name)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryText,
            ),
            children: [
              const TextSpan(text: 'Sell product '),
              TextSpan(
                text: '& earn money',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accentOrange,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Share financial product links or add new leads directly to earn money.',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: _ActionButton(
        icon: Icons.add_rounded,
        label: 'ADD LEAD',
        color: AppTheme.accentOrange,
        onTap: () => _openLeadForm(context),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.white, size: 24),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
