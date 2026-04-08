import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_locale.dart';
import '../utils/constants.dart';
import '../utils/page_routes.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/common_nav_bar.dart';
import '../widgets/common_bottom_nav.dart';
import '../widgets/wallet_shell_nav.dart';
import 'add_lead_screen.dart';
import 'leads_screen.dart';
import 'referral_screen.dart';
import 'wallet_screen.dart';

class PersonalDetailsScreen extends StatefulWidget {
  final String userName;
  final String mobileNumber;

  const PersonalDetailsScreen({
    super.key,
    required this.userName,
    required this.mobileNumber,
  });

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _pincodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(AppConstants.keyEmail) ?? '';
    final pincode = prefs.getString(AppConstants.keyPincode) ?? '';
    if (mounted) {
      _emailController.text = email;
      _pincodeController.text = pincode;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final pincode = _pincodeController.text.trim();

    final success = await ApiService.instance.updateUserProfile(
      widget.mobileNumber,
      email: email.isEmpty ? null : email,
    );

    if (success && mounted) {
      final prefs = await SharedPreferences.getInstance();
      if (pincode.isNotEmpty) {
        await prefs.setString(AppConstants.keyPincode, pincode);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppConstants.msgProfileUpdated,
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  WalletShellNav _pdAddLeadNav(NavigatorState nav) {
    return WalletShellNav(
      onHome: () {
        nav.pop();
        nav.pop();
      },
      onLeads: () {
        nav.pop();
        nav.push(
          smoothPushRoute(
            LeadsScreen(userName: widget.userName),
          ),
        );
      },
      onReferral: () {
        nav.pop();
        Future.microtask(() {
          if (!mounted) return;
          nav.push(
            smoothPushRoute(
              ReferralScreen(
                userName: widget.userName,
                shellNav: _pdReferralNav(nav),
              ),
            ),
          );
        });
      },
      onCenterPlus: () {},
      onWallet: () {
        nav.pop();
        Future.microtask(() {
          if (!mounted) return;
          nav.push(
            smoothPushRoute(
              WalletScreen(
                userName: widget.userName,
                shellNav: _pdWalletNav(nav),
              ),
            ),
          );
        });
      },
    );
  }

  WalletShellNav _pdWalletNav(NavigatorState nav) {
    return WalletShellNav(
      onHome: () {
        nav.pop();
        nav.pop();
      },
      onLeads: () {
        nav.pop();
        nav.push(
          smoothPushRoute(
            LeadsScreen(userName: widget.userName),
          ),
        );
      },
      onReferral: () {
        nav.pop();
        Future.microtask(() {
          if (!mounted) return;
          nav.push(
            smoothPushRoute(
              ReferralScreen(
                userName: widget.userName,
                shellNav: _pdReferralNav(nav),
              ),
            ),
          );
        });
      },
      onCenterPlus: () {
        nav.pop();
        Future.microtask(() {
          if (!mounted) return;
          nav.push(
            smoothPushRoute(
              AddLeadScreen(
                userName: widget.userName,
                shellNav: _pdAddLeadNav(nav),
              ),
            ),
          );
        });
      },
      onWallet: () {},
    );
  }

  WalletShellNav _pdReferralNav(NavigatorState nav) {
    return WalletShellNav(
      onHome: () {
        nav.pop();
        nav.pop();
      },
      onLeads: () {
        nav.pop();
        nav.push(
          smoothPushRoute(
            LeadsScreen(userName: widget.userName),
          ),
        );
      },
      onReferral: () {},
      onCenterPlus: () {
        nav.pop();
        Future.microtask(() {
          if (!mounted) return;
          nav.push(
            smoothPushRoute(
              AddLeadScreen(
                userName: widget.userName,
                shellNav: _pdAddLeadNav(nav),
              ),
            ),
          );
        });
      },
      onWallet: () {
        nav.pop();
        Future.microtask(() {
          if (!mounted) return;
          nav.push(
            smoothPushRoute(
              WalletScreen(
                userName: widget.userName,
                shellNav: _pdWalletNav(nav),
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBackground,
      body: Column(
        children: [
          CommonNavBar(
            userName: widget.userName,
            showBackButton: true,
            onBackPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: Form(
                  key: _formKey,
                  child: _buildFormCard(),
                ),
              ),
            ),
          ),
          CommonBottomNav(
            currentIndex: 0,
            onHomeTap: () => Navigator.of(context).pop(),
            onMyLeadsTap: () {
              final nav = Navigator.of(context);
              nav.push(
                smoothPushRoute(
                  WalletScreen(
                    userName: widget.userName,
                    shellNav: _pdWalletNav(nav),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return PersonalDetailsFormCard(
      userName: widget.userName,
      mobileNumber: widget.mobileNumber,
      emailController: _emailController,
      pincodeController: _pincodeController,
      isLoading: _isLoading,
      onSubmit: _submit,
    );
  }

}

/// Content-only for shell (no nav/footer). Form with optional onSaved when used in shell.
class PersonalDetailsContent extends StatefulWidget {
  final String userName;
  final String mobileNumber;
  final VoidCallback? onSaved;

  const PersonalDetailsContent({
    super.key,
    required this.userName,
    required this.mobileNumber,
    this.onSaved,
  });

  @override
  State<PersonalDetailsContent> createState() => _PersonalDetailsContentState();
}

class _PersonalDetailsContentState extends State<PersonalDetailsContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _pincodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(AppConstants.keyEmail) ?? '';
    final pincode = prefs.getString(AppConstants.keyPincode) ?? '';
    if (mounted) {
      _emailController.text = email;
      _pincodeController.text = pincode;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final pincode = _pincodeController.text.trim();
    final success = await ApiService.instance.updateUserProfile(
      widget.mobileNumber,
      email: email.isEmpty ? null : email,
    );
    if (success && mounted) {
      final prefs = await SharedPreferences.getInstance();
      if (pincode.isNotEmpty) await prefs.setString(AppConstants.keyPincode, pincode);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.t('msgProfileUpdated'), style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onSaved?.call();
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final kb = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: kb),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Form(
            key: _formKey,
            child: PersonalDetailsFormCard(
              userName: widget.userName,
              mobileNumber: widget.mobileNumber,
              emailController: _emailController,
              pincodeController: _pincodeController,
              isLoading: _isLoading,
              onSubmit: _submit,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared form card for PersonalDetailsScreen and PersonalDetailsContent.
class PersonalDetailsFormCard extends StatelessWidget {
  final String userName;
  final String mobileNumber;
  final TextEditingController emailController;
  final TextEditingController pincodeController;
  final bool isLoading;
  final VoidCallback onSubmit;

  const PersonalDetailsFormCard({
    super.key,
    required this.userName,
    required this.mobileNumber,
    required this.emailController,
    required this.pincodeController,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppTheme.accentOrange.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 8)),
          BoxShadow(color: AppTheme.darkBlue.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: AppTheme.accentOrange.withValues(alpha: 0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReadOnlyField(label: context.t('labelFullName'), value: userName, icon: Icons.person_outline_rounded),
          const SizedBox(height: 20),
          _buildReadOnlyField(label: context.t('labelMobileNumber'), value: mobileNumber, icon: Icons.phone_android_rounded),
          const SizedBox(height: 20),
          _buildEditableField(controller: emailController, label: context.t('labelEmail'), hint: context.t('hintEmail'), icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 20),
          _buildEditableField(controller: pincodeController, label: context.t('labelPinCode'), hint: context.t('hintPinCode'), icon: Icons.location_on_outlined, keyboardType: TextInputType.number),
          const SizedBox(height: 32),
          _buildSubmitButton(context),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.secondaryText)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.mainBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderColor, width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.accentOrange),
              const SizedBox(width: 12),
              Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.primaryText))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField({required TextEditingController controller, required String label, required String hint, required IconData icon, required TextInputType keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.secondaryText)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.primaryText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: AppTheme.lightText, fontWeight: FontWeight.w500),
            prefixIcon: Icon(icon, size: 20, color: AppTheme.accentOrange),
            filled: true,
            fillColor: AppTheme.mainBackground,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppTheme.accentOrange, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onSubmit,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isLoading ? AppTheme.accentOrange.withValues(alpha: 0.6) : AppTheme.accentOrange,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppTheme.accentOrange.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                  : Text(context.t('labelSubmit'), style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white, letterSpacing: 0.5)),
            ),
          ),
        ),
      ),
    );
  }
}
