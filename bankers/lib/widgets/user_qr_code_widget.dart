import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../utils/constants.dart';

/// Unique QR code per user. Same user = same QR every time (constant).
/// Encodes user identifier so one generation per user.
class UserQrCodeWidget extends StatelessWidget {
  final String userName;
  final String mobileNumber;

  const UserQrCodeWidget({
    super.key,
    required this.userName,
    required this.mobileNumber,
  });

  /// Payload that uniquely identifies this user. Constant for same mobile.
  String get _qrPayload => 'AZ:${mobileNumber.trim()}';

  @override
  Widget build(BuildContext context) {
    const accentOrange = Color(AppConstants.accentColor);
    const darkBlue = Color(AppConstants.primaryColor);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentOrange.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentOrange.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppConstants.msgMyQrCode,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          QrImageView(
            data: _qrPayload,
            version: QrVersions.auto,
            size: 100,
            backgroundColor: Colors.white,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: darkBlue,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: darkBlue,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            userName,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(AppConstants.primaryText),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            mobileNumber,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(AppConstants.secondaryText),
            ),
          ),
        ],
      ),
    );
  }
}
