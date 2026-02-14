import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../widgets/common_nav_bar.dart';
import '../widgets/common_bottom_nav.dart';
import 'lead_form_screen.dart';

/// Content-only widget for Leads (no nav/footer). Used by MainShellScreen.
class LeadsContent extends StatelessWidget {
  const LeadsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: _buildTotalLeadsCard(context),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildAddLeadButton(context),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: _buildEarnRewardsCard(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalLeadsCard(BuildContext context) {
    const primaryBlue = Color(AppConstants.primaryColor);
    const primaryBlueDark = Color(AppConstants.primaryColorDark);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryBlueDark,
            primaryBlueDark.withOpacity(0.85),
            primaryBlue.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.labelTotalAddedLeads,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppConstants.subtitleSeeAllLeads,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
              Material(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppConstants.labelViewDetails,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildLeadStatusChip(
                  AppConstants.labelSuccess,
                  0,
                  const Color(AppConstants.successColor),
                  Icons.check_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildLeadStatusChip(
                  AppConstants.labelInProcess,
                  0,
                  const Color(0xFF2563EB),
                  Icons.refresh_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildLeadStatusChip(
                  AppConstants.labelRejected,
                  0,
                  const Color(AppConstants.errorColor),
                  Icons.close_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildLeadStatusChip(
                  AppConstants.labelActionRequired,
                  null,
                  const Color(AppConstants.warningColor),
                  Icons.warning_amber_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeadStatusChip(String label, int? count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(AppConstants.cardBackground),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          if (count != null)
            Text(
              '$count',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(AppConstants.primaryText),
              ),
            )
          else
            const SizedBox(height: 22),
          if (count != null) const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(AppConstants.secondaryText),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEarnRewardsCard(BuildContext context) {
    const primaryBlue = Color(AppConstants.primaryColor);
    const accentOrange = Color(AppConstants.accentColor);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(AppConstants.cardBackground),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppConstants.titleAddLeadsEarnRewards,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(AppConstants.primaryText),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppConstants.subtitleGetPaidPerLead,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(AppConstants.secondaryText),
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryBlue.withOpacity(0.1),
                      primaryBlue.withOpacity(0.06),
                      accentOrange.withOpacity(0.06),
                    ],
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events_rounded, size: 72, color: accentOrange.withOpacity(0.9)),
                      const SizedBox(width: 16),
                      Icon(Icons.currency_rupee_rounded, size: 48, color: primaryBlue.withOpacity(0.8)),
                      Icon(Icons.monetization_on_rounded, size: 40, color: const Color(AppConstants.warningColor).withOpacity(0.9)),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentOrange, accentOrange.withOpacity(0.85)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: accentOrange.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    AppConstants.bannerEarnPerLead,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddLeadButton(BuildContext context) {
    const accentOrange = Color(AppConstants.accentColor);
    return Material(
      color: accentOrange,
      borderRadius: BorderRadius.circular(28),
      shadowColor: accentOrange.withOpacity(0.5),
      elevation: 8,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const LeadFormScreen()),
          );
        },
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Text(
                AppConstants.buttonAddLeadNow,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LeadsScreen extends StatelessWidget {
  final String userName;

  const LeadsScreen({super.key, this.userName = AppConstants.defaultUserName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.mainBackground),
      body: Column(
        children: [
          CommonNavBar(
            userName: userName,
            showBackButton: true,
            onBackPressed: () => Navigator.of(context).pop(),
          ),
          const Expanded(child: LeadsContent()),
          CommonBottomNav(
            currentIndex: 1,
            onHomeTap: () => Navigator.of(context).pop(),
            onLeadsTap: () {},
            onCenterTap: () {},
          ),
        ],
      ),
    );
  }
}
