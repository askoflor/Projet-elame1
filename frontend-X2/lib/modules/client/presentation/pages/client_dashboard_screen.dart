import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/translation_provider.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../../home/presentation/widgets/header/nav_bar.dart';
import '../../../../core/widgets/app_back_button.dart';
import 'package:provider/provider.dart';
import '../../../historique/state/reservation_history_provider.dart';
import '../../../historique/domain/reservation.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const NavBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: AppBackButton(),
                      ),
                      const SizedBox(height: 24),
                      _buildHeader(context),
                      const SizedBox(height: 36),
                      _buildStatsGrid(context),
                      const SizedBox(height: 36),
                      _buildQuickActions(context),
                      const SizedBox(height: 36),
                      _buildRecentBookings(context),
                      const SizedBox(height: 36),
                      _buildNotifications(context),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return StaggeredFadeIn(
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('client.welcome'),
                  style: GoogleFonts.sora(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('client.subtitle'),
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return StaggeredFadeIn(
      staggerDelay: const Duration(milliseconds: 100),
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard(
              context,
              icon: Icons.calendar_today_rounded,
              value: '14',
              label: context.tr('client.interventionsTotales'),
              color: const Color(0xFF2563EB),
              bgColor: const Color(0xFFEFF4FF),
              badge: context.tr('client.plusCeMois'),
              badgeUp: true,
              chartWidth: 0.7,
            )),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard(
              context,
              icon: Icons.check_circle_rounded,
              value: '2',
              label: context.tr('client.enCours'),
              color: const Color(0xFFF97316),
              bgColor: const Color(0xFFFFF7ED),
              badge: context.tr('client.activesBadge'),
              badgeUp: true,
              chartWidth: 0.2,
            )),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard(
              context,
              icon: Icons.people_rounded,
              value: '87 500',
              label: context.tr('client.fcfaDepenses'),
              color: const Color(0xFF059669),
              bgColor: const Color(0xFFECFDF5),
              badge: context.tr('client.ceMois'),
              badgeUp: true,
              chartWidth: 0.55,
            )),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard(
              context,
              icon: Icons.star_rounded,
              value: '4.8',
              label: context.tr('client.noteMoyenne'),
              color: const Color(0xFF7C3AED),
              bgColor: const Color(0xFFF3F0FF),
              chartWidth: 0.96,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color bgColor,
    String? badge,
    bool badgeUp = false,
    double? chartWidth,
  }) {
    return SlideOnHover(
      offset: const Offset(0, -0.04),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8ECF2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeUp
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: badgeUp
                            ? const Color(0xFF059669)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: GoogleFonts.sora(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
            if (chartWidth != null) ...[
              const SizedBox(height: 12),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8ECF2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: chartWidth.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.6)],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return StaggeredFadeIn(
      staggerDelay: const Duration(milliseconds: 120),
      children: [
        Row(
          children: [
            Expanded(child: _buildActionCard(
              context,
              icon: Icons.search_rounded,
              title: context.tr('client.trouverPrestataire'),
              color: const Color(0xFF2563EB),
              onTap: () => context.go(AppConstants.searchRoute),
            )),
            const SizedBox(width: 16),
            Expanded(child: _buildActionCard(
              context,
              icon: Icons.book_online_rounded,
              title: context.tr('client.mesReservations'),
              color: const Color(0xFF059669),
              onTap: () => context.go(AppConstants.bookingRoute),
            )),
            const SizedBox(width: 16),
            Expanded(child: _buildActionCard(
              context,
              icon: Icons.favorite_rounded,
              title: context.tr('client.mesFavoris'),
              color: const Color(0xFFF97316),
              onTap: () => context.go(AppConstants.searchRoute),
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SlideOnHover(
      offset: const Offset(0, -0.04),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8ECF2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: const Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentBookings(BuildContext context) {
    final provider = context.watch<ReservationHistoryProvider>();
    final recent = provider.all.take(3).toList();

    return StaggeredFadeIn(
      staggerDelay: const Duration(milliseconds: 140),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    context.tr('client.reservationRecent'),
                    style: GoogleFonts.sora(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  HoverWrap(
                    scale: 1.05,
                    child: PointerCursor(
                      child: TextButton(
                        onPressed: () => context.push('/historique'),
                        child: Text(
                          context.tr('historique.voirHistorique'),
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (recent.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    context.tr('historique.pasEncore'),
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              )
            else
              ...recent.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildBookingItem(context, r),
              )),
          ],
        ),
      ],
    );
  }

  Widget _buildBookingItem(BuildContext context, Reservation r) {
    final statusData = _reservationStatusData(r.statut);
    return SlideOnHover(
      offset: const Offset(0, -0.02),
      child: GestureDetector(
        onTap: () => context.push('/historique'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8ECF2), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    r.providerInitials,
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.providerName,
                      style: GoogleFonts.sora(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${r.serviceName} · ${r.formattedDate}',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  '${r.montant.toStringAsFixed(0)} FCFA',
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusData.$3,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusData.$1,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusData.$2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (String, Color, Color) _reservationStatusData(ReservationStatus status) {
    return switch (status) {
      ReservationStatus.pending => (context.tr('client.enCours'), const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
      ReservationStatus.confirmed => ('Confirmée', const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
      ReservationStatus.completed => (context.tr('client.termine'), const Color(0xFF16A34A), const Color(0xFFDCFCE7)),
      ReservationStatus.cancelled => (context.tr('client.annule'), const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
    };
  }

  Widget _buildNotifications(BuildContext context) {
    return StaggeredFadeIn(
      staggerDelay: const Duration(milliseconds: 160),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      context.tr('client.notifications'),
                      style: GoogleFonts.sora(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '5',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                HoverWrap(
                  scale: 1.05,
                  child: PointerCursor(
                    child: TextButton(
                      onPressed: () => context.go('/espace-client'),
                      child: Text(
                        context.tr('client.voirDetails'),
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildNotifItem(
              icon: Icons.check_circle_rounded,
              iconBg: const Color(0xFFECFDF5),
              iconColor: const Color(0xFF059669),
              title: context.tr('client.notifEnRoute'),
              subtitle: context.tr('client.notifAujourdhui'),
            ),
            const SizedBox(height: 8),
            _buildNotifItem(
              icon: Icons.message_rounded,
              iconBg: const Color(0xFFEFF4FF),
              iconColor: const Color(0xFF2563EB),
              title: context.tr('client.notifMessage'),
              subtitle: context.tr('client.notifMessageSub'),
            ),
            const SizedBox(height: 8),
            _buildNotifItem(
              icon: Icons.receipt_rounded,
              iconBg: const Color(0xFFFFF7ED),
              iconColor: const Color(0xFFF97316),
              title: context.tr('client.notifFacture'),
              subtitle: context.tr('client.notifFactureSub'),
            ),
            const SizedBox(height: 8),
            _buildNotifItem(
              icon: Icons.star_rounded,
              iconBg: const Color(0xFFF3F0FF),
              iconColor: const Color(0xFF7C3AED),
              title: context.tr('client.notifNote'),
              subtitle: context.tr('client.notifNoteSub'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotifItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return GestureDetector(
      onTap: () => context.go('/espace-client'),
      child: SlideOnHover(
        offset: const Offset(0, -0.02),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8ECF2), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.sora(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
