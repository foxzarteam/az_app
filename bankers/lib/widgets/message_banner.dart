import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

enum MessageBannerType { error, success }

class MessageBanner extends StatelessWidget {
  final String message;
  final MessageBannerType type;

  const MessageBanner({
    super.key,
    required this.message,
    this.type = MessageBannerType.error,
  });

  Color get _backgroundColor =>
      type == MessageBannerType.error
          ? AppTheme.error.withOpacity(0.1)
          : AppTheme.success.withOpacity(0.1);

  Color get _borderColor =>
      type == MessageBannerType.error
          ? AppTheme.error.withOpacity(0.3)
          : AppTheme.success.withOpacity(0.3);

  Color get _textAndIconColor =>
      type == MessageBannerType.error ? AppTheme.error : AppTheme.success;

  IconData get _icon =>
      type == MessageBannerType.error
          ? Icons.error_outline_rounded
          : Icons.check_circle_outline_rounded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: _textAndIconColor, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: _textAndIconColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
