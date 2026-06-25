import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/service_display.dart';
import '../../../models/active_service.dart';
import '../../home/dashboard_screen.dart';
import '../../home/services_controller.dart';

class ActiveServicesList extends StatelessWidget {
  const ActiveServicesList({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ServicesController>();

    if (ctrl.loading && ctrl.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (ctrl.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'No services available right now.',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.secondaryText,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < ctrl.items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ActiveServiceRow(
              service: ctrl.items[i],
              colorIndex: i,
              onShare: () => DashboardScreen.showShareForProduct(
                context,
                ctrl.items[i].title,
              ),
            ),
          ),
      ],
    );
  }
}

class _ActiveServiceRow extends StatelessWidget {
  const _ActiveServiceRow({
    required this.service,
    required this.colorIndex,
    required this.onShare,
  });

  final ActiveService service;
  final int colorIndex;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final iconColor = iconColorForServiceIndex(
      colorIndex,
      AppTheme.primaryBlue,
      AppTheme.accentOrange,
    );
    final subtitle = service.description.isNotEmpty
        ? service.description
        : 'Earn more';
    final hasImage = isServiceNetworkImageUrl(service.imageUrl);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.overlayDark(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: iconColor.withValues(alpha: 0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: hasImage
                  ? Image.network(
                      service.imageUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        iconForServiceSlug(service.slug),
                        color: iconColor,
                        size: 26,
                      ),
                    )
                  : Icon(
                      iconForServiceSlug(service.slug),
                      color: iconColor,
                      size: 26,
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.accentOrange,
                  ),
                ),
              ],
            ),
          ),
          _SellNowChipButton(onTap: onShare),
        ],
      ),
    );
  }
}

class _SellNowChipButton extends StatelessWidget {
  const _SellNowChipButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.accentOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(2),
      child: Material(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_offer_outlined,
                  size: 16,
                  color: AppTheme.primaryText,
                ),
                const SizedBox(width: 6),
                Text(
                  AppConstants.buttonSellNow,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
