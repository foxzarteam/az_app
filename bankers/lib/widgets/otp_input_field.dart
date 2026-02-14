import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onChanged;
  final bool hasError;
  final bool enabled;

  const OtpInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.hasError = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 65,
      height: 65,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        enabled: enabled,
        style: GoogleFonts.poppins(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AppTheme.accentOrange,
          letterSpacing: 2,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: hasError
              ? AppTheme.error.withOpacity(0.05)
              : const Color(AppConstants.mainBackground),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: hasError
                  ? AppTheme.error
                  : AppTheme.accentOrange.withOpacity(0.3),
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: hasError
                  ? AppTheme.error
                  : AppTheme.accentOrange.withOpacity(0.3),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: hasError ? AppTheme.error : AppTheme.accentOrange,
              width: 3,
            ),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
