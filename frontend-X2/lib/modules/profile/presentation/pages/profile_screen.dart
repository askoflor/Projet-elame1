import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/localization/translation_provider.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../../home/presentation/widgets/header/nav_bar.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../search/domain/entities/provider_model.dart';
import '../../../search/data/models/mock_providers.dart';

class ProfileScreen extends StatefulWidget {
  final ProviderModel? provider;

  const ProfileScreen({super.key, this.provider});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProviderModel _provider;

  @override
  void initState() {
    super.initState();
    _provider = widget.provider ?? mockProviders[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const NavBar(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isStacked = constraints.maxWidth < 900;
                  if (isStacked) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        child: Column(
                          children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: AppBackButton(),
                            ),
                            _buildProfileCard(),
                            const SizedBox(height: 16),
                            _buildAboutSection(),
                            const SizedBox(height: 16),
                            _buildSkillsSection(),
                            const SizedBox(height: 16),
                            _buildCertificationsSection(),
                            const SizedBox(height: 16),
                            _buildCalendarSection(),
                            const SizedBox(height: 16),
                            _buildReviewsSection(),
                          ],
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 340,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: AppBackButton(),
                                ),
                                _buildProfileCard(),
                                const SizedBox(height: 16),
                                _buildSkillsSection(),
                                const SizedBox(height: 16),
                                _buildCertificationsSection(),
                              ],
                            ),
                          ),
                        ),
                        const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE8ECF2)),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                _buildAboutSection(),
                                const SizedBox(height: 16),
                                _buildCalendarSection(),
                                const SizedBox(height: 16),
                                _buildReviewsSection(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final p = _provider;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF2)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    p.initials,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: p.isAvailable ? const Color(0xFF10B981) : const Color(0xFFF97316),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            p.name,
            style: GoogleFonts.sora(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            p.specialty,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              if (p.isAvailable)
                _buildBadge(context.tr('profile.disponible'), const Color(0xFF10B981), const Color(0xFFECFDF5))
              else
                _buildBadge(context.tr('profile.enMission'), const Color(0xFFF97316), const Color(0xFFFFF7ED)),
              if (p.isCertified)
                _buildBadge(context.tr('profile.certifie'), const Color(0xFF2563EB), const Color(0xFFEFF4FF)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE8ECF2))),
            ),
            child: Row(
              children: [
                Expanded(child: _buildStat(context.tr('profile.missions'), p.formattedInterventions)),
                Expanded(child: _buildStat(context.tr('profile.note'), p.formattedRating)),
                Expanded(child: _buildStat(context.tr('profile.succes'), p.successRate)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ScaleOnHover(
            scale: 1.03,
            child: PointerCursor(
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF97316), Color(0xFFEA6C0A)],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () => context.push('/reservation', extra: _provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    context.tr('profile.reserver'),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ScaleOnHover(
            scale: 1.03,
            child: PointerCursor(
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/reservation', extra: _provider),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    side: const BorderSide(color: Color(0xFFE8ECF2)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.message_outlined, size: 16),
                  label: Text(context.tr('profile.envoyerMessage'), style: const TextStyle(fontSize: 12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.sora(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 10,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.build_outlined, size: 16, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Text(
                context.tr('profile.competences'),
                style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _provider.skills.map((s) => _buildSkillChip(s)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String label) {
    return ScaleOnHover(
      scale: 1.05,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF4FF),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF2563EB)),
        ),
      ),
    );
  }

  Widget _buildCertificationsSection() {
    final certs = _provider.certifications;
    if (certs.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_outlined, size: 16, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Text(
                context.tr('profile.certifications'),
                style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < certs.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFE8ECF2)),
            _buildCertItem(certs[i]['title'] ?? '', certs[i]['date'] ?? ''),
          ],
        ],
      ),
    );
  }

  Widget _buildCertItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.workspace_premium_outlined, size: 16, color: Color(0xFF2563EB)),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
              const SizedBox(height: 2),
              Text(subtitle, style: GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFF94A3B8))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Text(
                context.tr('profile.aPropos'),
                style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _provider.about,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF64748B),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    final dayHeaders = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined, size: 16, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Text(
                context.tr('profile.disponibilites'),
                style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildLegend(const Color(0xFF10B981), const Color(0xFFECFDF5), context.tr('profile.disponible')),
              const SizedBox(width: 12),
              _buildLegend(const Color(0xFFEF4444), const Color(0xFFFEF2F2), context.tr('profile.occupe')),
              const SizedBox(width: 12),
              _buildLegend(const Color(0xFF2563EB), const Color(0xFF2563EB), context.tr('profile.aujourdhui')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: dayHeaders.map((d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 4),
          _buildCalendarRow(['28', '29', '30', '1', '2', '3', '4'],
              [CalDayType.other, CalDayType.other, CalDayType.other, CalDayType.available, CalDayType.available, CalDayType.busy, CalDayType.busy]),
          _buildCalendarRow(['5', '6', '7', '8', '9', '10', '11'],
              [CalDayType.available, CalDayType.today, CalDayType.available, CalDayType.available, CalDayType.busy, CalDayType.available, CalDayType.available]),
          _buildCalendarRow(['12', '13', '14', '15', '16', '17', '18'],
              [CalDayType.busy, CalDayType.busy, CalDayType.available, CalDayType.available, CalDayType.available, CalDayType.busy, CalDayType.available]),
          _buildCalendarRow(['19', '20', '21', '22', '23', '24', '25'],
              [CalDayType.available, CalDayType.available, CalDayType.busy, CalDayType.busy, CalDayType.available, CalDayType.available, CalDayType.available]),
        ],
      ),
    );
  }

  Widget _buildLegend(Color dotColor, Color bgColor, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: dotColor == bgColor ? dotColor : bgColor,
            borderRadius: BorderRadius.circular(3),
            border: dotColor != bgColor ? Border.all(color: dotColor, width: 1) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildCalendarRow(List<String> days, List<CalDayType> types) {
    return Row(
      children: List.generate(7, (i) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.all(2),
            height: 32,
            decoration: BoxDecoration(
              color: _calDayColor(types[i]),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                days[i],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _calDayTextColor(types[i]),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Color _calDayColor(CalDayType type) {
    switch (type) {
      case CalDayType.available:
        return const Color(0xFFECFDF5);
      case CalDayType.busy:
        return const Color(0xFFFEF2F2);
      case CalDayType.today:
        return const Color(0xFF2563EB);
      case CalDayType.other:
        return Colors.transparent;
    }
  }

  Color _calDayTextColor(CalDayType type) {
    switch (type) {
      case CalDayType.available:
        return const Color(0xFF059669);
      case CalDayType.busy:
        return const Color(0xFFEF4444);
      case CalDayType.today:
        return Colors.white;
      case CalDayType.other:
        return const Color(0xFF94A3B8);
    }
  }

  Widget _buildReviewsSection() {
    final reviews = _provider.reviews;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_outline, size: 16, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Text(
                '${context.tr('profile.avis')} (${_provider.reviewCount})',
                style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < reviews.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFE8ECF2)),
            _buildReviewItem(reviews[i].initials, reviews[i].name, reviews[i].date, reviews[i].rating, reviews[i].text),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewItem(String initials, String name, String date, int rating, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(initials, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                    Text(date, style: GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFF94A3B8))),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: List.generate(5, (i) => Icon(
                    i < rating ? Icons.star : Icons.star_border,
                    size: 12,
                    color: const Color(0xFFF59E0B),
                  )),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum CalDayType { available, busy, today, other }
