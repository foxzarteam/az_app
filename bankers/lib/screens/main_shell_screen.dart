import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/user_prefs_helper.dart';
import '../widgets/common_nav_bar.dart';
import '../widgets/common_bottom_nav.dart';
import '../widgets/drawer_menu_item.dart';
import '../widgets/user_qr_code_widget.dart';
import 'dashboard_screen.dart';
import 'leads_screen.dart';
import 'personal_details_screen.dart';

/// Single shell: one header, one footer. Only the middle content changes with animation.
class MainShellScreen extends StatefulWidget {
  final String userName;
  final int initialIndex;

  const MainShellScreen({
    super.key,
    required this.userName,
    this.initialIndex = 0,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late List<int> _contentStack;
  String _mobileNumber = '';
  bool _mobileLoaded = false;

  @override
  void initState() {
    super.initState();
    _contentStack = [widget.initialIndex];
  }

  int get _currentIndex => _contentStack.last;

  void _goTo(int index) {
    setState(() {
      if (index == 0) {
        _contentStack = [0];
      } else {
        if (_contentStack.last != index) {
          _contentStack = [..._contentStack, index];
        }
      }
    });
  }

  void _goBack() {
    if (_contentStack.length <= 1) return;
    setState(() => _contentStack = _contentStack.sublist(0, _contentStack.length - 1));
  }

  Future<void> _loadMobileIfNeeded() async {
    if (_mobileLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      _mobileNumber = prefs.getString(AppConstants.keyMobileNumber) ?? '';
      _mobileLoaded = true;
    }
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

  Widget _buildProfileDrawer() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height,
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
                      onTap: () async {
                        Navigator.of(context).pop();
                        await _loadMobileIfNeeded();
                        if (mounted) _goTo(2);
                      },
                    ),
                    const SizedBox(height: 16),
                    DrawerMenuItem(
                      icon: Icons.people_outline_rounded,
                      title: AppConstants.labelMyLead,
                      subtitle: AppConstants.subtitleMyLead,
                      color: AppTheme.darkBlue,
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

  Widget _buildContent(int index) {
    switch (index) {
      case 0:
        return DashboardBody(
          onSharePersonalLoan: () => _showShareOptionsFromDashboard(),
        );
      case 1:
        return const LeadsContent();
      case 2:
        return PersonalDetailsContent(
          userName: widget.userName,
          mobileNumber: _mobileNumber.isEmpty ? AppConstants.defaultMaskedMobile : _mobileNumber,
          onSaved: () => _goTo(0),
        );
      default:
        return DashboardBody(
          onSharePersonalLoan: () => _showShareOptionsFromDashboard(),
        );
    }
  }

  void _showShareOptionsFromDashboard() {
    DashboardScreen.showShareOptions(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentIndex == 0 ? Colors.white : const Color(AppConstants.mainBackground),
      body: Column(
        children: [
          CommonNavBar(
            userName: widget.userName,
            showBackButton: _contentStack.length > 1,
            onBackPressed: _contentStack.length > 1 ? _goBack : null,
            onAvatarTap: _showProfileDrawer,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                const begin = Offset(0.15, 0.0);
                const end = Offset.zero;
                final tween = Tween(begin: begin, end: end).chain(
                  CurveTween(curve: Curves.easeOutCubic),
                );
                final fade = Tween<double>(begin: 0.0, end: 1.0).animate(animation);
                return SlideTransition(
                  position: animation.drive(tween),
                  child: FadeTransition(
                    opacity: fade,
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(_currentIndex),
                child: _buildContent(_currentIndex),
              ),
            ),
          ),
          CommonBottomNav(
            currentIndex: _currentIndex.clamp(0, 3),
            onHomeTap: () => _goTo(0),
            onLeadsTap: () => _goTo(1),
            onCenterTap: () {},
            onReferralTap: null,
            onMyLeadsTap: null,
          ),
        ],
      ),
    );
  }
}
