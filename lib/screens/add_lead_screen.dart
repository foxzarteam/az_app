import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/page_routes.dart';
import '../widgets/common_bottom_nav.dart';
import '../widgets/common_nav_bar.dart';
import '../widgets/wallet_shell_nav.dart';
import 'dashboard_screen.dart';
import 'lead_form_screen.dart';
import 'leads_screen.dart';
import 'referral_screen.dart';
import 'wallet_screen.dart';

class AddLeadScreen extends StatelessWidget {
  const AddLeadScreen({super.key, this.userName, this.shellNav});

  /// Shown in the app bar; falls back to [AppConstants.defaultUserName].
  final String? userName;

  /// When set (e.g. from [MainShellScreen]), bottom bar pops/switches like other shell pages.
  final WalletShellNav? shellNav;

  String get _name => userName ?? AppConstants.defaultUserName;

  static void _openLeadForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LeadFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ignore transient window insets when the system share sheet opens so layout does not jump.
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(viewInsets: EdgeInsets.zero),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppTheme.mainBackground,
        body: Column(
          children: [
            CommonNavBar(
              userName: userName ?? AppConstants.defaultUserName,
              showBackButton: true,
              onBackPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShareHeader(),
                    const SizedBox(height: 24),
                    _buildActionButtons(context),
                    const SizedBox(height: 24),
                    _buildProductList(context),
                  ],
                ),
              ),
            ),
            CommonBottomNav(
              // No tab uses index 4 — center "+" is this screen; avoid wrong highlight.
              currentIndex: 4,
              onHomeTap: () {
                if (shellNav != null) {
                  shellNav!.onHome();
                  return;
                }
                Navigator.of(context).pop();
              },
              onLeadsTap: () {
                if (shellNav != null) {
                  shellNav!.onLeads();
                  return;
                }
                final nav = Navigator.of(context);
                nav.pop();
                Future.microtask(() {
                  nav.push(smoothPushRoute(LeadsScreen(userName: _name)));
                });
              },
              onCenterTap: () {
                if (shellNav != null) {
                  shellNav!.onCenterPlus();
                }
              },
              onReferralTap: () {
                if (shellNav != null) {
                  shellNav!.onReferral();
                  return;
                }
                Navigator.of(context).push(
                  smoothPushRoute(ReferralScreen(userName: _name)),
                );
              },
              onMyLeadsTap: () {
                if (shellNav != null) {
                  shellNav!.onWallet();
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
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.primaryText),
            children: [
              const TextSpan(text: 'Sell product '),
              TextSpan(
                text: '& earn money',
                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.accentOrange),
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

  Widget _buildProductList(BuildContext context) {
    final products = [
      _ProductItem(title: 'Personal Loan', subtitle: 'Earn upto 4.00%', icon: Icons.account_balance_wallet_rounded, iconColor: AppTheme.accentOrange, showShareLink: true),
      _ProductItem(title: 'Home Loan', subtitle: 'Earn upto 3.50%', icon: Icons.home_rounded, iconColor: AppTheme.primaryBlue, showShareLink: true),
      _ProductItem(title: 'Business Loan', subtitle: 'Earn upto 2.50%', icon: Icons.business_rounded, iconColor: const Color(0xFF7C3AED), showShareLink: true),
      _ProductItem(title: 'Credit Card', subtitle: 'Earn upto ₹3000', icon: Icons.credit_card_rounded, iconColor: AppTheme.socialMail, showShareLink: true),
      _ProductItem(title: 'Insurance', subtitle: 'Earn upto ₹2000', icon: Icons.shield_rounded, iconColor: AppTheme.success, showShareLink: true),
      _ProductItem(title: 'Vehicle Loan', subtitle: 'Earn upto 2.00%', icon: Icons.directions_car_rounded, iconColor: AppTheme.primaryBlue, showShareLink: true),
    ];
    return Column(
      children: products
          .map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ProductRow(
                title: p.title,
                subtitle: p.subtitle,
                icon: p.icon,
                iconColor: p.iconColor,
                showShareLink: p.showShareLink,
                onAdd: () => _openLeadForm(context),
                onShareLink: () =>
                    DashboardScreen.showShareForProduct(context, p.title),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

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

class _ProductItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool showShareLink;

  _ProductItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.showShareLink = false,
  });
}

/// Gradient-bordered chip; kept static (no pulsing scale) so the list stays visually stable.
class _SellNowChipButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _SellNowChipButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.accentOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(2),
      child: Material(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_offer_outlined, size: 16, color: AppTheme.primaryText),
                const SizedBox(width: 6),
                Text(
                  AppConstants.buttonSellNow,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool showShareLink;
  final VoidCallback? onAdd;
  final VoidCallback? onShareLink;

  const _ProductRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.showShareLink = false,
    this.onAdd,
    this.onShareLink,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.overlayDark(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: iconColor.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.accentOrange,
                  ),
                ),
              ],
            ),
          ),
          showShareLink
              ? _SellNowChipButton(onTap: onShareLink)
              : Material(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: onAdd,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Text(
                        'ADD',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryText,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
