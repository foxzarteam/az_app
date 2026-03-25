import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_locale.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/page_routes.dart';
import '../utils/user_prefs_helper.dart';
import '../utils/validators.dart';
import '../widgets/common_bottom_nav.dart';
import '../widgets/common_nav_bar.dart';
import '../widgets/wallet_shell_nav.dart';
import 'add_lead_screen.dart';
import 'leads_screen.dart';
import 'referral_screen.dart';

class WalletScreen extends StatefulWidget {
  final String? userName;
  final WalletShellNav? shellNav;

  const WalletScreen({super.key, this.userName, this.shellNav});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _amountController = TextEditingController();
  final _upiController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _ifscController = TextEditingController();

  String? _userId;
  String? _savedUpi;
  String? _savedBankName;
  String? _savedIfscCode;

  /// 'upi' | 'bank' — which withdraw method is selected. UPI default.
  String _selectedWithdrawMethod = 'upi';

  String _balanceDisplay = '0';

  @override
  void initState() {
    super.initState();
    _loadPaymentDetails();
  }

  Future<void> _loadWallet(String userId) async {
    final wallet = await ApiService.instance.getWallet(userId);
    if (!mounted) return;
    if (wallet != null) {
      final balance = _numToDisplay(wallet['balance']);
      setState(() {
        _balanceDisplay = balance;
      });
    }
  }

  static String _numToDisplay(dynamic v) {
    if (v == null) return '0.00';
    if (v is int) return v.toString();
    if (v is double) return v.toStringAsFixed(2);
    final s = v.toString().trim();
    return s.isEmpty ? '0.00' : s;
  }

  double _balanceNumeric() {
    final s = _balanceDisplay.replaceAll(',', '').trim();
    return double.tryParse(s) ?? 0.0;
  }

  void _showInsufficientBalanceDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppConstants.titleInsufficientBalance,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryText,
          ),
        ),
        content: Text(
          AppConstants.msgInsufficientBalanceWithdraw,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: AppTheme.secondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              AppConstants.labelOk,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadPaymentDetails() async {
    final mobile = await UserPrefsHelper.getMobileNumber();
    if (mobile.isEmpty || mobile == AppConstants.defaultMaskedMobile) {
      if (mounted) setState(() { _userId = null; });
      return;
    }
    final user = await ApiService.instance.getUserByMobile(mobile);
    final userId = user?['id']?.toString();
    if (userId == null || userId.isEmpty) {
      if (mounted) setState(() { _userId = null; });
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
        if (upi != null && upi.isNotEmpty) _upiController.text = upi;
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
      });
      await _loadWallet(userId);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _upiController.dispose();
    _bankNameController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  WalletShellNav _walletStandaloneAddLeadNav() {
    final name = widget.userName ?? AppConstants.defaultUserName;
    return WalletShellNav(
      onHome: () => Navigator.of(context).pop(),
      onLeads: () {
        final nav = Navigator.of(context);
        nav.pop();
        Future.microtask(() {
          if (!mounted) return;
          nav.push(smoothPushRoute(LeadsScreen(userName: name)));
        });
      },
      onReferral: () {
        final nav = Navigator.of(context);
        nav.pop();
        Future.microtask(() {
          if (!mounted) return;
          nav.push(smoothPushRoute(ReferralScreen(userName: name)));
        });
      },
      onCenterPlus: () {},
      onWallet: () {
        final nav = Navigator.of(context);
        nav.pop();
        Future.microtask(() {
          if (!mounted) return;
          nav.push(smoothPushRoute(WalletScreen(userName: name)));
        });
      },
    );
  }

  void _bottomNavHome() {
    if (widget.shellNav != null) {
      widget.shellNav!.onHome();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _bottomNavLeads() {
    if (widget.shellNav != null) {
      widget.shellNav!.onLeads();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _bottomNavReferral() {
    if (widget.shellNav != null) {
      widget.shellNav!.onReferral();
    } else {
      Navigator.of(context).push(
        smoothPushRoute(
          ReferralScreen(userName: widget.userName),
        ),
      );
    }
  }

  void _bottomNavCenter() {
    if (widget.shellNav != null) {
      widget.shellNav!.onCenterPlus();
    } else {
      final nav = Navigator.of(context);
      final name = widget.userName;
      nav.pop();
      Future.microtask(() {
        if (!mounted) return;
        nav.push(
          smoothPushRoute(
            AddLeadScreen(
              userName: name,
              shellNav: _walletStandaloneAddLeadNav(),
            ),
          ),
        );
      });
    }
  }

  void _bottomNavWallet() {
    if (widget.shellNav != null) {
      widget.shellNav!.onWallet();
    }
  }

  void _onWithdrawTap() {
    final balance = _balanceNumeric();
    if (balance <= 0) {
      _showInsufficientBalanceDialog();
      return;
    }

    final amount = _amountController.text.trim();
    if (amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.t('hintEnterAmount'), style: GoogleFonts.inter()),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }
    final parsed = int.tryParse(amount.replaceAll(',', ''));
    if (parsed == null || parsed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.t('hintEnterAmount'), style: GoogleFonts.inter()),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }
    if (parsed > balance) {
      _showInsufficientBalanceDialog();
      return;
    }
    if (_savedUpi == null && _savedBankName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Add UPI or Bank A/C to withdraw', style: GoogleFonts.inter()),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Withdrawal request of ₹${amount.replaceAll(',', '')} will be processed.', style: GoogleFonts.inter()),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBackground,
      // Keep bottom bar inside the same [Column] as the scroll area (like [MainShellScreen]
      // and [LeadsScreen]). Using [bottomNavigationBar] with [Column]+[Expanded] body
      // can leave the body with no height on some devices.
      body: Column(
        children: [
          CommonNavBar(
            userName: widget.userName ?? AppConstants.defaultUserName,
            showBackButton: true,
            onBackPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBalanceCard(),
                  const SizedBox(height: 24),
                  _buildWithdrawAmountSection(),
                  const SizedBox(height: 20),
                  _buildMethodCard(
                    icon: Icons.account_balance_wallet_rounded,
                    title: context.t('labelUpi'),
                    subtitle: context.t('labelUpiSubtitle'),
                    hasAdded: _savedUpi != null && _savedUpi!.isNotEmpty,
                    isSelected: _selectedWithdrawMethod == 'upi',
                    onTap: () {
                      setState(() => _selectedWithdrawMethod = 'upi');
                      _showUpiSheet();
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMethodCard(
                    icon: Icons.account_balance_rounded,
                    title: context.t('labelBankTransfer'),
                    subtitle: context.t('labelBankAc'),
                    hasAdded:
                        _savedBankName != null && _savedBankName!.isNotEmpty,
                    isSelected: _selectedWithdrawMethod == 'bank',
                    onTap: () {
                      setState(() => _selectedWithdrawMethod = 'bank');
                      _showBankSheet();
                    },
                  ),
                ],
              ),
            ),
          ),
          CommonBottomNav(
            currentIndex: 3,
            onHomeTap: _bottomNavHome,
            onLeadsTap: _bottomNavLeads,
            onCenterTap: _bottomNavCenter,
            onReferralTap: _bottomNavReferral,
            onMyLeadsTap: _bottomNavWallet,
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppTheme.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                context.t('labelWallet'),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.white.withOpacity(0.95),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  '₹ $_balanceDisplay',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Material(
                color: AppTheme.accentOrange,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _onWithdrawTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: Text(
                      context.t('labelWithdraw'),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t('labelWithdrawAmount'),
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryText,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor.withOpacity(0.6)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryText.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '₹ ',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryText,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: context.t('hintEnterAmount'),
                    hintStyle: GoogleFonts.inter(color: AppTheme.lightText, fontSize: 15),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 0),
                    isDense: true,
                  ),
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.primaryText),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMethodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool hasAdded,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppTheme.accentOrange : AppTheme.borderColor,
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
                  color: AppTheme.accentOrange.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTheme.primaryBlue, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    if (hasAdded) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.check_circle_rounded, size: 16, color: AppTheme.success),
                          const SizedBox(width: 6),
                          Text(
                            'Added',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.success),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.secondaryText),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpiSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _UpiSheetContent(
        userId: _userId,
        controller: _upiController,
        savedUpi: _savedUpi,
        onSaved: () {
          Navigator.of(ctx).pop();
          _loadPaymentDetails();
        },
      ),
    );
  }

  void _showBankSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BankSheetContent(
        userId: _userId,
        bankNameController: _bankNameController,
        ifscController: _ifscController,
        savedBankName: _savedBankName,
        savedIfscCode: _savedIfscCode,
        onSaved: () {
          Navigator.of(ctx).pop();
          _loadPaymentDetails();
        },
      ),
    );
  }
}

class _UpiSheetContent extends StatelessWidget {
  final String? userId;
  final TextEditingController controller;
  final String? savedUpi;
  final VoidCallback onSaved;

  const _UpiSheetContent({
    required this.userId,
    required this.controller,
    this.savedUpi,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.t('labelUpi'),
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.primaryText),
            ),
            const SizedBox(height: 4),
            Text(
              'GPay, PhonePe, BHIM or any UPI app',
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.secondaryText),
            ),
            if (savedUpi != null && savedUpi!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.success.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        savedUpi!,
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.primaryText),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'e.g. name@upi or 9876543210',
                hintStyle: GoogleFonts.inter(color: AppTheme.lightText, fontSize: 14),
                filled: true,
                fillColor: AppTheme.mainBackground,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.borderColor)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppTheme.accentOrange.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.accentOrange, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: GoogleFonts.inter(fontSize: 15, color: AppTheme.primaryText),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: userId == null
                    ? null
                    : () async {
                        final upiId = controller.text.trim();
                        final err = upiValidationError(upiId.isEmpty ? null : upiId);
                        if (err != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.t(err), style: GoogleFonts.inter()), backgroundColor: AppTheme.error),
                          );
                          return;
                        }
                        final ok = await ApiService.instance.savePaymentAccount(userId!, paymentType: 'upi', upiId: upiId);
                        if (!context.mounted) return;
                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.t('msgUpiSaved'), style: GoogleFonts.inter()), backgroundColor: AppTheme.success),
                          );
                          onSaved();
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text('Save UPI ID', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BankSheetContent extends StatelessWidget {
  final String? userId;
  final TextEditingController bankNameController;
  final TextEditingController ifscController;
  final String? savedBankName;
  final String? savedIfscCode;
  final VoidCallback onSaved;

  const _BankSheetContent({
    required this.userId,
    required this.bankNameController,
    required this.ifscController,
    this.savedBankName,
    this.savedIfscCode,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.t('labelBankTransfer'),
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.primaryText),
            ),
            const SizedBox(height: 4),
            Text(
              context.t('labelBankAc'),
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.secondaryText),
            ),
            if (savedBankName != null && savedBankName!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.success.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$savedBankName${savedIfscCode != null && savedIfscCode!.isNotEmpty ? ' • $savedIfscCode' : ''}',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.primaryText),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Bank name',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.primaryText),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: bankNameController,
              decoration: _inputDecoration(),
              style: GoogleFonts.inter(fontSize: 15, color: AppTheme.primaryText),
            ),
            const SizedBox(height: 14),
            Text(
              'IFSC code',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.primaryText),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: ifscController,
              textCapitalization: TextCapitalization.characters,
              decoration: _inputDecoration(hint: 'e.g. SBIN0001234'),
              style: GoogleFonts.inter(fontSize: 15, color: AppTheme.primaryText),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: userId == null
                    ? null
                    : () async {
                        final bankName = bankNameController.text.trim();
                        final ifscCode = ifscController.text.trim();
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
                          userId!,
                          paymentType: 'bank',
                          bankName: bankName,
                          ifscCode: ifscCode,
                        );
                        if (!context.mounted) return;
                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.t('msgBankSaved'), style: GoogleFonts.inter()), backgroundColor: AppTheme.success),
                          );
                          onSaved();
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(context.t('buttonSaveBankDetails'), style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({String hint = 'e.g. State Bank of India'}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: AppTheme.lightText, fontSize: 14),
      filled: true,
      fillColor: AppTheme.mainBackground,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.borderColor)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.primaryBlue.withOpacity(0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
