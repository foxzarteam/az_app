import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/constants.dart';
import '../../core/widgets/common_nav_bar.dart';

class LeadListScreen extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> leads;

  const LeadListScreen({
    super.key,
    required this.title,
    required this.leads,
  });

  static String _str(Map<String, dynamic> lead, String key) {
    final value = lead[key];
    if (value == null) return '';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBackground,
      body: Column(
        children: [
          CommonNavBar(
            userName: AppConstants.defaultUserName,
            showBackButton: true,
            onBackPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: leads.isEmpty
                ? Center(
                    child: Text(
                      'No lead record found',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final maxH = (constraints.maxHeight.isFinite && constraints.maxHeight > 0)
                              ? constraints.maxHeight
                              : 400.0;
                          return Scrollbar(
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: 380,
                                height: maxH,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.primaryBlue.withValues(alpha: 0.08),
                                        AppTheme.primaryBlue.withValues(alpha: 0.04),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: AppTheme.borderColor.withValues(alpha: 0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 126,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.person_outline_rounded,
                                              size: 18,
                                              color: AppTheme.primaryBlue,
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                'Name',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.primaryText,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 116,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.phone_outlined,
                                              size: 18,
                                              color: AppTheme.primaryBlue,
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                'Number',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.primaryText,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 96,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Icon(
                                              Icons.pending_actions_rounded,
                                              size: 18,
                                              color: AppTheme.primaryBlue,
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                'Status',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.primaryText,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.separated(
                                    itemBuilder: (context, index) {
                                    final lead = leads[index];
                                    final name = _str(lead, 'full_name');
                                    final mobile = _str(lead, 'mobile_number');
                                    final status = _str(lead, 'status').toLowerCase();
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      color: index.isEven
                                          ? Colors.transparent
                                          : AppTheme.borderColor.withValues(alpha: 0.06),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 126,
                                            child: Text(
                                              name.isEmpty ? 'Unnamed Lead' : name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: AppTheme.primaryText,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 116,
                                            child: Text(
                                              mobile,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                color: AppTheme.secondaryText,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 96,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: _StatusChip(status: status),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  separatorBuilder: (context, index) => Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: AppTheme.borderColor.withValues(alpha: 0.2),
                                  ),
                                    itemCount: leads.length,
                                  ),
                                ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ),
          ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  Color get _background {
    switch (status) {
      case 'approved':
        return AppTheme.statusSuccessBg;
      case 'in_process':
      case 'pending':
        return AppTheme.statusPendingBg;
      case 'rejected':
        return AppTheme.statusRejectedBg;
      case 'action_required':
        return AppTheme.statusActionRequiredBg;
      default:
        return AppTheme.statusOtherBg;
    }
  }

  Color get _textColor {
    switch (status) {
      case 'approved':
        return AppTheme.success;
      case 'in_process':
      case 'pending':
        return AppTheme.statusPendingFg;
      case 'rejected':
        return AppTheme.error;
      case 'action_required':
        return AppTheme.warning;
      default:
        return AppTheme.secondaryText;
    }
  }

  String get _label {
    switch (status) {
      case 'approved':
        return AppConstants.labelSuccess;
      case 'in_process':
      case 'pending':
        return AppConstants.labelInProcess;
      case 'rejected':
        return AppConstants.labelRejected;
      case 'action_required':
        return AppConstants.labelActionRequired;
      default:
        return status.isEmpty ? 'Unknown' : status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _textColor,
        ),
      ),
    );
  }
}

