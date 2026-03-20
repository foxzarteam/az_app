import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

class DigitCodeInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  final bool hasError;
  final bool enabled;

  final double width;
  final double height;
  final double fontSize;
  final double letterSpacing;
  final bool obscureText;

  const DigitCodeInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.hasError = false,
    this.enabled = true,
    this.width = 52,
    this.height = 52,
    this.fontSize = 22,
    this.letterSpacing = 1.5,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        enabled: enabled,
        obscureText: obscureText,
        style: GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: AppTheme.accentOrange,
          letterSpacing: letterSpacing,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor:
              hasError ? AppTheme.error.withOpacity(0.05) : AppTheme.mainBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: hasError ? AppTheme.error : AppTheme.accentOrange.withOpacity(0.3),
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: hasError ? AppTheme.error : AppTheme.accentOrange.withOpacity(0.3),
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

