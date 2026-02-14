import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

/// Common navbar used on all pages: gradient bar with avatar, "Hi, User", To Gold, notification.
/// Uses app global color theme.
class CommonNavBar extends StatelessWidget {
  final String userName;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onToGoldTap;
  final VoidCallback? onNotificationTap;

  const CommonNavBar({
    super.key,
    this.userName = AppConstants.defaultUserName,
    this.showBackButton = false,
    this.onBackPressed,
    this.onAvatarTap,
    this.onToGoldTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(AppConstants.primaryColor);
    const primaryBlueDark = Color(AppConstants.primaryColorDark);
    const accentOrange = Color(AppConstants.accentColor);
    const yellow = Color(AppConstants.yellowAccent);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryBlueDark, primaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 20, 12),
          child: Row(
            children: [
              if (showBackButton)
                GestureDetector(
                  onTap: onBackPressed ?? () => Navigator.of(context).pop(),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: onAvatarTap,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentOrange, accentOrange.withOpacity(0.8)],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentOrange.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Hi, $userName',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onToGoldTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [yellow, accentOrange],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: accentOrange.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      AppConstants.labelToGold,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onNotificationTap,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(AppConstants.accentColor),
                          shape: BoxShape.circle,
                        ),
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
