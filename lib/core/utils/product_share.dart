import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/app_assets.dart';
import '../l10n/app_locale.dart';
import 'constants.dart';

/// Shares product text with matching banner (`w1.png`–`w6.png` in `assets/images/`) when available.
class ProductShare {
  ProductShare._();

  static Future<void> shareProduct(BuildContext context, String productTitle) async {
    final subject = AppConstants.shareSubjectForProduct(productTitle);
    final text = AppConstants.shareMessageForProduct(productTitle);
    try {
      FocusManager.instance.primaryFocus?.unfocus();
      final assetPath = AppAssets.shareBannerForProduct(productTitle);
      if (assetPath != null) {
        final file = await _materializeAssetToTempPng(assetPath);
        if (file != null) {
          await SharePlus.instance.share(
            ShareParams(
              files: [XFile(file.path)],
              text: text,
              subject: subject,
            ),
          );
          return;
        }
      }
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: subject,
        ),
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t('msgErrorTryAgain'))),
        );
      }
    }
  }

  static Future<File?> _materializeAssetToTempPng(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/share_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } catch (_) {
      return null;
    }
  }
}
