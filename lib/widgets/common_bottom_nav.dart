import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_locale.dart';
import '../theme/app_theme.dart';

/// Index: 0=Home, 1=Leads, 2=Referral, 3=Earning. Center button is separate.
class CommonBottomNav extends StatefulWidget {
  final int currentIndex;
  final VoidCallback? onHomeTap;
  final VoidCallback? onLeadsTap;
  final VoidCallback? onReferralTap;
  final VoidCallback? onMyLeadsTap;
  final VoidCallback? onCenterTap;

  const CommonBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onHomeTap,
    this.onLeadsTap,
    this.onReferralTap,
    this.onMyLeadsTap,
    this.onCenterTap,
  });

  @override
  State<CommonBottomNav> createState() => _CommonBottomNavState();
}

class _CommonBottomNavState extends State<CommonBottomNav> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: AppTheme.overlayDark(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Center(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              _buildNavItem(
                Icons.home_rounded,
                context.t('labelHome'),
                widget.currentIndex == 0,
                AppTheme.primaryBlue,
                onTap: widget.onHomeTap,
              ),
              _buildNavItem(
                Icons.description_rounded,
                context.t('labelLeads'),
                widget.currentIndex == 1,
                AppTheme.primaryBlue,
                onTap: widget.onLeadsTap,
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onCenterTap,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentOrange.withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppTheme.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
              _buildNavItem(
                Icons.people_rounded,
                context.t('labelReferral'),
                widget.currentIndex == 2,
                AppTheme.primaryBlue,
                onTap: widget.onReferralTap,
              ),
              _buildNavItem(
                Icons.account_balance_wallet_rounded,
                context.t('labelMyLeads'),
                widget.currentIndex == 3,
                AppTheme.primaryBlue,
                onTap: widget.onMyLeadsTap,
              ),
                ],
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    Color activeColor, {
    VoidCallback? onTap,
  }) {
    final color = isActive ? activeColor : AppTheme.secondaryText;
    return GestureDetector(
      onTap: onTap ?? () {},
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
