import 'package:flutter/material.dart';

/// Bottom-bar actions when [WalletScreen] or [ReferralScreen] sits on top of
/// another navigator so tabs pop/switch correctly.
class WalletShellNav {
  const WalletShellNav({
    required this.onHome,
    required this.onLeads,
    required this.onReferral,
    required this.onCenterPlus,
    required this.onWallet,
  });

  final VoidCallback onHome;
  final VoidCallback onLeads;
  final VoidCallback onReferral;
  final VoidCallback onCenterPlus;
  /// Wallet tab (already on wallet screen).
  final VoidCallback onWallet;
}
