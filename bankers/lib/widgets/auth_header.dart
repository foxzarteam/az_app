import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class AuthHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget>? stars;
  /// When true, header does not expand; content stays in upper half (e.g. MPIN screen).
  final bool compact;

  const AuthHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.stars,
    this.compact = false,
  });

  Widget _buildContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentOrange.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(icon, color: AppTheme.darkBlue, size: 50),
            ),
          ),
          const SizedBox(height: 24),
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 200),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppTheme.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 12),
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 400),
              child: Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.white.withOpacity(0.9),
                ),
              ),
            ),
          ],
          if (stars != null) ...[
            const SizedBox(height: 12),
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 400),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: stars!,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent();
    if (compact) {
      return content;
    }
    return Expanded(flex: 2, child: content);
  }
}
