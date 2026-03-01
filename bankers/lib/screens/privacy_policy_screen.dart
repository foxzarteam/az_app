import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_locale.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/common_nav_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final String? userName;

  const PrivacyPolicyScreen({super.key, this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    icon: Icons.info_outline_rounded,
                    title: 'Introduction',
                    body:
                        'Apni Zaroorat ("we", "our", or "us") is committed to protecting your privacy. '
                        'This Privacy Policy explains how we collect, use, store, and safeguard your information '
                        'when you use our mobile application and referral services. By using the app, you consent to the practices described here.',
                  ),
                  _buildSection(
                    context,
                    icon: Icons.collections_bookmark_outlined,
                    title: 'Information We Collect',
                    body:
                        'We collect information that you provide directly, including:\n\n'
                        '• Mobile number and name for account creation and verification\n'
                        '• Email address and pin code (optional) for profile and communications\n'
                        '• MPIN for secure login and account access\n'
                        '• Payment details (UPI ID, bank name, IFSC code) for processing your earnings and payouts\n'
                        '• Lead information (as per referral) when you submit or share leads through the app\n\n'
                        'We also collect device and usage data (e.g. app version, login times) to improve services and security.',
                  ),
                  _buildSection(
                    context,
                    icon: Icons.how_to_reg_outlined,
                    title: 'How We Use Your Information',
                    body:
                        'Your information is used to:\n\n'
                        '• Provide, operate, and maintain the app and referral services\n'
                        '• Verify your identity and secure your account\n'
                        '• Process leads, track referrals, and calculate and disburse rewards\n'
                        '• Send you service-related updates, OTPs, and important notices\n'
                        '• Improve our products, prevent fraud, and comply with applicable laws',
                  ),
                  _buildSection(
                    context,
                    icon: Icons.security_rounded,
                    title: 'Data Security',
                    body:
                        'We implement industry-standard technical and organisational measures to protect your personal and payment data. '
                        'Sensitive data is stored securely and access is restricted. '
                        'We do not store your full payment credentials beyond what is necessary for payouts. '
                        'You are responsible for keeping your MPIN and device access secure.',
                  ),
                  _buildSection(
                    context,
                    icon: Icons.share_outlined,
                    title: 'Sharing of Information',
                    body:
                        'We may share your information only:\n\n'
                        '• With banking and payment partners to process payouts (UPI/bank details)\n'
                        '• With verification and fraud-prevention service providers\n'
                        '• When required by law or to protect our rights and users\n\n'
                        'We do not sell your personal data to third parties for marketing.',
                  ),
                  _buildSection(
                    context,
                    icon: Icons.gavel_rounded,
                    title: 'Your Rights',
                    body:
                        'You have the right to:\n\n'
                        '• Access and correct your profile and payment details within the app\n'
                        '• Request deletion of your account and associated data, subject to legal and operational requirements\n'
                        '• Withdraw consent where processing is consent-based\n\n'
                        'To exercise these rights or for any privacy concern, contact us using the details below.',
                  ),
                  _buildSection(
                    context,
                    icon: Icons.update_rounded,
                    title: 'Changes to This Policy',
                    body:
                        'We may update this Privacy Policy from time to time. '
                        'We will notify you of material changes via the app or your registered contact details. '
                        'Continued use of the app after changes constitutes acceptance of the updated policy.',
                  ),
                  _buildSection(
                    context,
                    icon: Icons.contact_support_outlined,
                    title: 'Contact Us',
                    body:
                        'For any questions about this Privacy Policy or our data practices, please contact us through the in-app support or at the contact details provided within the app.',
                  ),
                  const SizedBox(height: 24),
                  _buildFooter(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlueDark.withOpacity(0.95),
            AppTheme.primaryBlue,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.privacy_tip_rounded,
                  color: AppTheme.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  context.t('labelPrivacyPolicy'),
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Last updated: February 2025',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryText.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.primaryBlue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.55,
              color: AppTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Text(
        '${AppConstants.appName} • Your privacy matters',
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppTheme.lightText,
        ),
      ),
    );
  }
}
