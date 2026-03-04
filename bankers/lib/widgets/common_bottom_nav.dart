import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_locale.dart';
import '../theme/app_theme.dart';

/// Index: 0=Home, 1=Leads, 2=Referral, 3=My Leads. Center button is separate.
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

class _CommonBottomNavState extends State<CommonBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _gradientController;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _gradientController.dispose();
    super.dispose();
  }

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
              AnimatedBuilder(
                animation: _gradientAnimation,
                builder: (context, child) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onCenterTap,
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                            AppTheme.accentOrange,
                            AppTheme.accentOrange.withOpacity(0.8),
                            Color.lerp(
                              AppTheme.accentOrange,
                              AppTheme.yellow,
                              _gradientAnimation.value,
                            )!,
                          ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentOrange.withOpacity(0.5),
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
                  );
                },
              ),
              _buildNavItem(
                Icons.people_rounded,
                context.t('labelReferral'),
                widget.currentIndex == 2,
                AppTheme.primaryBlue,
                onTap: widget.onReferralTap,
              ),
              _buildNavItem(
                Icons.folder_outlined,
                context.t('labelMyLeads'),
                widget.currentIndex == 3,
                AppTheme.primaryBlue,
                onTap: widget.onMyLeadsTap,
              ),
            ],
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
