import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/constants.dart';

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
    const primaryBlue = Color(AppConstants.primaryColor);
    const accentOrange = Color(AppConstants.accentColor);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                Icons.home_rounded,
                AppConstants.labelHome,
                widget.currentIndex == 0,
                primaryBlue,
                onTap: widget.onHomeTap,
              ),
              _buildNavItem(
                Icons.description_rounded,
                AppConstants.labelLeads,
                widget.currentIndex == 1,
                primaryBlue,
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
                              accentOrange,
                              accentOrange.withOpacity(0.8),
                              Color.lerp(
                                accentOrange,
                                const Color(AppConstants.yellowAccent),
                                _gradientAnimation.value,
                              )!,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accentOrange.withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  );
                },
              ),
              _buildNavItem(
                Icons.people_rounded,
                AppConstants.labelReferral,
                widget.currentIndex == 2,
                primaryBlue,
                onTap: widget.onReferralTap,
              ),
              _buildNavItem(
                Icons.folder_outlined,
                AppConstants.labelMyLeads,
                widget.currentIndex == 3,
                primaryBlue,
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
    final color = isActive ? activeColor : const Color(AppConstants.secondaryText);
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
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
