import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_locale.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/user_prefs_helper.dart';
import '../utils/validators.dart';
import '../widgets/common_nav_bar.dart';

class PaymentSettingsScreen extends StatefulWidget {
  final String? userName;

  const PaymentSettingsScreen({super.key, this.userName});

  @override
  State<PaymentSettingsScreen> createState() => _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends State<PaymentSettingsScreen> {
  /// 0 = UPI (default), 1 = Bank
  int _selectedTab = 0;

  final _upiController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _ifscController = TextEditingController();

  String? _userId;
  bool _isLoading = true;
  String? _savedUpi;
  String? _savedBankName;
  String? _savedIfscCode;

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _upiFormKey = GlobalKey();
  final GlobalKey _bankFormKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadPaymentDetails();
  }

  Future<void> _loadPaymentDetails() async {
    setState(() => _isLoading = true);
    final mobile = await UserPrefsHelper.getMobileNumber();
    if (mobile.isEmpty || mobile == AppConstants.defaultMaskedMobile) {
      if (mounted) setState(() { _userId = null; _isLoading = false; });
      return;
    }
    final user = await ApiService.instance.getUserByMobile(mobile);
    final userId = user?['id']?.toString();
    if (userId == null || userId.isEmpty) {
      if (mounted) setState(() { _userId = null; _isLoading = false; });
      return;
    }
    final list = await ApiService.instance.getPaymentAccounts(userId);
    String? upi;
    String? bankName;
    String? ifsc;
    for (final row in list) {
      final type = row['payment_type'] as String?;
      if (type == 'upi') {
        upi = row['upi_id'] as String?;
        if (upi != null && upi.isNotEmpty) {
          _upiController.text = upi;
        }
      } else if (type == 'bank') {
        bankName = row['bank_name'] as String?;
        ifsc = row['ifsc_code'] as String?;
        if (bankName != null && bankName.isNotEmpty) _bankNameController.text = bankName;
        if (ifsc != null && ifsc.isNotEmpty) _ifscController.text = ifsc;
      }
    }
    if (mounted) {
      setState(() {
        _userId = userId;
        _savedUpi = upi;
        _savedBankName = bankName;
        _savedIfscCode = ifsc;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _upiController.dispose();
    _bankNameController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  void _scrollToForm(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = key.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBackground,
      body: Column(
        children: [
          CommonNavBar(
            userName: widget.userName ?? AppConstants.defaultUserName,
            showBackButton: true,
            onBackPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppConstants.labelPaymentSettings,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryText,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
                    )
                  else ...[
                  _buildPaymentOptionCard(
                    isSelected: _selectedTab == 0,
                    icon: Icons.phone_android_rounded,
                    title: 'Enter UPI ID / Mobile Number',
                    subtitle: 'Send money to Gpay, Phonepe, Bhim or any UPI app',
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentOptionCard(
                    isSelected: _selectedTab == 1,
                    icon: Icons.account_balance_rounded,
                    title: 'Enter Bank A/c no & IFSC',
                    subtitle: 'Send money to any Bank instantly',
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                  const SizedBox(height: 24),
                  if (_selectedTab == 0) _buildUpiForm() else _buildBankForm(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptionCard({
    required bool isSelected,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryBlue
                  : AppTheme.borderColor.withOpacity(0.8),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryText.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              if (isSelected)
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primaryBlue, size: 26),
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
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppTheme.primaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpiForm() {
    return Container(
      key: _upiFormKey,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryText.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppTheme.accentOrange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'UPI ID or Mobile Number',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryText,
                ),
              ),
            ],
          ),
          if (_savedUpi != null && _savedUpi!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Added: $_savedUpi',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.primaryText),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _scrollToForm(_upiFormKey),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(context.t('labelEdit'), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          TextFormField(
            controller: _upiController,
            decoration: InputDecoration(
              hintText: 'e.g. name@upi or 9876543210',
              hintStyle: GoogleFonts.inter(
                color: AppTheme.lightText,
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppTheme.mainBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.accentOrange.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.accentOrange,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: GoogleFonts.inter(fontSize: 15, color: AppTheme.primaryText),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _userId == null
                  ? null
                  : () async {
                      final upiId = _upiController.text.trim();
                      final err = upiValidationError(upiId.isEmpty ? null : upiId);
                      if (err != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(err, style: GoogleFonts.inter()), backgroundColor: AppTheme.error),
                        );
                        return;
                      }
                      final ok = await ApiService.instance.savePaymentAccount(_userId!, paymentType: 'upi', upiId: upiId);
                      if (!mounted) return;
                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.t('msgUpiSaved'), style: GoogleFonts.inter()), backgroundColor: AppTheme.success),
                        );
                        _loadPaymentDetails();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.t('msgErrorTryAgain'), style: GoogleFonts.inter()), backgroundColor: AppTheme.error),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentOrange,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Save UPI ID',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankForm() {
    return Container(
      key: _bankFormKey,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryText.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: AppTheme.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Bank Account Details',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryText,
                ),
              ),
            ],
          ),
          if (_savedBankName != null && _savedBankName!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Added: $_savedBankName${_savedIfscCode != null && _savedIfscCode!.isNotEmpty ? ' • $_savedIfscCode' : ''}',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.primaryText),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _scrollToForm(_bankFormKey),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(context.t('labelEdit'), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          _buildLabel('Bank name'),
          const SizedBox(height: 6),
          _buildTextField(_bankNameController, 'e.g. State Bank of India'),
          const SizedBox(height: 14),
          _buildLabel('IFSC code'),
          const SizedBox(height: 6),
          _buildTextField(
            _ifscController,
            'e.g. SBIN0001234',
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _userId == null
                  ? null
                  : () async {
                      final bankName = _bankNameController.text.trim();
                      final ifscCode = _ifscController.text.trim();
                      if (bankName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.t('msgEnterBankName'), style: GoogleFonts.inter()), backgroundColor: AppTheme.error),
                        );
                        return;
                      }
                      final ifscErr = ifscValidationError(ifscCode.isEmpty ? null : ifscCode);
                      if (ifscErr != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.t(ifscErr), style: GoogleFonts.inter()), backgroundColor: AppTheme.error),
                        );
                        return;
                      }
                      final ok = await ApiService.instance.savePaymentAccount(
                        _userId!,
                        paymentType: 'bank',
                        bankName: bankName,
                        ifscCode: ifscCode,
                      );
                      if (!mounted) return;
                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.t('msgBankSaved'), style: GoogleFonts.inter()), backgroundColor: AppTheme.success),
                        );
                        _loadPaymentDetails();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.t('msgErrorTryAgain'), style: GoogleFonts.inter()), backgroundColor: AppTheme.error),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                context.t('buttonSaveBankDetails'),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppTheme.primaryText,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          color: AppTheme.lightText,
          fontSize: 14,
        ),
        filled: true,
        fillColor: AppTheme.mainBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.primaryBlue.withOpacity(0.25),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.primaryBlue,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: GoogleFonts.inter(fontSize: 15, color: AppTheme.primaryText),
    );
  }
}
