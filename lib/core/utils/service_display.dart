import 'package:flutter/material.dart';

import '../../models/active_service.dart';
import '../theme/app_theme.dart';

/// API service `slug` (hyphen) → lead `category` (underscore) for POST /leads.
String leadCategoryFromServiceSlug(String slug) {
  return slug.trim().toLowerCase().replaceAll('-', '_');
}

List<({String value, String label})> serviceCategoryOptions(
  List<ActiveService> services,
) {
  return services
      .map(
        (s) => (
          value: leadCategoryFromServiceSlug(s.slug),
          label: s.title.isNotEmpty ? s.title : s.slug,
        ),
      )
      .toList(growable: false);
}

bool isServiceNetworkImageUrl(String url) {
  final t = url.trim().toLowerCase();
  return t.startsWith('http://') || t.startsWith('https://');
}

IconData iconForServiceSlug(String slug) {
  switch (slug) {
    case 'personal-loan':
      return Icons.account_balance_wallet_rounded;
    case 'home-loan':
      return Icons.home_rounded;
    case 'business-loan':
      return Icons.business_rounded;
    case 'credit-card':
      return Icons.credit_card_rounded;
    case 'insurance':
      return Icons.shield_rounded;
    case 'vehicle-loan':
      return Icons.directions_car_rounded;
    default:
      return Icons.savings_rounded;
  }
}

Color iconColorForServiceIndex(int index, Color primary, Color accentOrange) {
  const extras = [
    Color(0xFF7C3AED),
    AppTheme.socialMail,
    AppTheme.success,
    AppTheme.primaryBlue,
  ];
  if (index == 0) return accentOrange;
  if (index == 1) return primary;
  return extras[(index - 2) % extras.length];
}
