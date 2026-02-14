import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/common_nav_bar.dart';
import '../widgets/common_bottom_nav.dart';

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
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.mainBackground),
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
            content: Text(AppConstants.msgProfileUpdated, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
    return SafeArea(
      top: false,
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
          BoxShadow(color: AppTheme.accentOrange.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 8)),
          BoxShadow(color: AppTheme.darkBlue.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: AppTheme.accentOrange.withOpacity(0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReadOnlyField(label: AppConstants.labelFullName, value: userName, icon: Icons.person_outline_rounded),
          const SizedBox(height: 20),
          _buildReadOnlyField(label: AppConstants.labelMobileNumber, value: mobileNumber, icon: Icons.phone_android_rounded),
          const SizedBox(height: 20),
          _buildEditableField(controller: emailController, label: AppConstants.labelEmail, hint: AppConstants.hintEmail, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 20),
          _buildEditableField(controller: pincodeController, label: AppConstants.labelPinCode, hint: AppConstants.hintPinCode, icon: Icons.location_on_outlined, keyboardType: TextInputType.number),
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
        Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(AppConstants.secondaryText))),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(AppConstants.mainBackground),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(AppConstants.borderColor), width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.accentOrange),
              const SizedBox(width: 12),
              Expanded(child: Text(value, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(AppConstants.primaryText)))),
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
        Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(AppConstants.secondaryText))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(AppConstants.primaryText)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: const Color(AppConstants.lightText), fontWeight: FontWeight.w500),
            prefixIcon: Icon(icon, size: 20, color: AppTheme.accentOrange),
            filled: true,
            fillColor: const Color(AppConstants.mainBackground),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(AppConstants.borderColor))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(AppConstants.borderColor))),
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
              gradient: isLoading ? LinearGradient(colors: [AppTheme.accentOrange.withOpacity(0.6), AppTheme.accentOrange.withOpacity(0.5)]) : AppTheme.orangeGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppTheme.accentOrange.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                  : Text(AppConstants.labelSubmit, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)),
            ),
          ),
        ),
      ),
    );
  }
}
