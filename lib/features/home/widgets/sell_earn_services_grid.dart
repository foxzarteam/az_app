import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/service_display.dart';
import '../../../models/active_service.dart';
import '../dashboard_screen.dart';
import '../services_controller.dart';

/// Splits active services into rows (max 3). Row width follows item count: 2 → 50/50, 3 → thirds.
List<List<ActiveService>> _chunkServices(List<ActiveService> services) {
  const maxPerRow = 3;
  final rows = <List<ActiveService>>[];
  for (var i = 0; i < services.length; i += maxPerRow) {
    final end = i + maxPerRow > services.length ? services.length : i + maxPerRow;
    rows.add(services.sublist(i, end));
  }
  return rows;
}

class SellEarnServicesGrid extends StatelessWidget {
  const SellEarnServicesGrid({
    super.key,
    required this.primary,
    required this.accentOrange,
  });

  final Color primary;
  final Color accentOrange;

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ServicesController>();

    if (ctrl.loading && ctrl.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (ctrl.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final rows = _chunkServices(ctrl.items);
    final children = <Widget>[];
    var itemIndex = 0;

    for (var r = 0; r < rows.length; r++) {
      if (r > 0) children.add(const SizedBox(height: 12));
      final row = rows[r];
      children.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < row.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: _SellEarnServiceCard(
                  service: row[i],
                  colorIndex: itemIndex + i,
                  primary: primary,
                  accentOrange: accentOrange,
                  onTap: () => DashboardScreen.showShareForProduct(
                    context,
                    row[i].title,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
      itemIndex += row.length;
    }

    return Column(children: children);
  }
}

class _SellEarnServiceCard extends StatelessWidget {
  const _SellEarnServiceCard({
    required this.service,
    required this.colorIndex,
    required this.primary,
    required this.accentOrange,
    required this.onTap,
  });

  final ActiveService service;
  final int colorIndex;
  final Color primary;
  final Color accentOrange;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = iconColorForServiceIndex(colorIndex, primary, accentOrange);
    final subtitle = service.description.isNotEmpty
        ? service.description
        : 'Earn more';
    final hasNetworkImage = isServiceNetworkImageUrl(service.imageUrl);

    const double circleRadius = 28.0;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: circleRadius),
            padding: const EdgeInsets.fromLTRB(10, circleRadius + 8, 10, 14),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.overlayDark(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  service.title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.accentOrange,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              width: circleRadius * 2,
              height: circleRadius * 2,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.overlayDark(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: hasNetworkImage
                    ? Image.network(
                        service.imageUrl,
                        width: circleRadius * 2,
                        height: circleRadius * 2,
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
          ),
        ],
      ),
    );
  }
}
