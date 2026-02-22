import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class AppTheme {
  AppTheme._();

  static TextStyle inter({
    double? fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Premium blue — primary brand color
  static const Color primaryBlue = Color(AppConstants.primaryColor);
  /// Darker blue for gradients
  static const Color primaryBlueDark = Color(AppConstants.primaryColorDark);
  static const Color darkBlue = primaryBlue;
  static const Color accentOrange = Color(AppConstants.accentColor);
  static const Color yellow = Color(AppConstants.yellowAccent);
  static const Color primaryText = Color(AppConstants.primaryText);
  static const Color secondaryText = Color(AppConstants.secondaryText);
  static const Color lightText = Color(AppConstants.lightText);
  static const Color error = Color(AppConstants.errorColor);
  static const Color success = Color(AppConstants.successColor);
  static const Color white = Colors.white;

  static LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryBlueDark, primaryBlue],
      );

  static LinearGradient get orangeGradient => LinearGradient(
        colors: [accentOrange, accentOrange.withOpacity(0.8)],
      );
}
