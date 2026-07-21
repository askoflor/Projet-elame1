import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/translation_provider.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/hour_slot_grid.dart';
import '../../../../core/constants/referentials.dart';
import '../../../home/presentation/widgets/header/nav_bar.dart';
import '../../../auth/domain/auth_provider.dart';
import '../../../provider/state/provider_dashboard_state.dart';
import '../../../provider/domain/certification.dart';
import '../../../intervention/state/intervention_provider.dart';
import '../../../search/domain/entities/provider_model.dart';
import '../../../search/data/models/mock_providers.dart';
import '../../../booking/domain/booking_entry_args.dart';
import '../../domain/profile_view_data.dart';

class ProfileScreen extends StatefulWidget {
  final ProviderModel? provider;

  const ProfileScreen({super.key, this.provider});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late bool _ownerMode;
  late ProviderModel _visitorProvider;
  bool _editing = false;

  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDay;
  List<int> _pickedHours = [];

  final _nameController = TextEditingController();
  final _aboutController = TextEditingController();
  final _skillInputController = TextEditingController();
  final _certTitleController = TextEditingController();
  final _certOrgController = TextEditingController();
  bool _editingAbout = false;
  bool _addingCert = false;
  late String _selectedMetier;
  late String _selectedVille;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _ownerMode = widget.provider == null && auth.user?.role == 'PRESTATAIRE';
    _visitorProvider = widget.provider ?? mockProviders[0];
    if (_ownerMode) {
      final profile = context.read<ProviderDashboardProvider>().profile;
      _selectedMetier = Referentials.metiers.contains(profile.specialite)
          ? profile.specialite
          : Referentials.metiers.first;
      _selectedVille = Referentials.villes.contains(profile.ville)
          ? profile.ville
          : Referentials.villes.first;
    } else {
      _selectedMetier = Referentials.metiers.first;
      _selectedVille = Referentials.villes.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _skillInputController.dispose();
    _certTitleController.dispose();
    _certOrgController.dispose();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _enterEditMode(ProviderDashboardProvider providerDash) {
    setState(() {
      _editing = true;
      _nameController.text = providerDash.profile.nomComplet;
      _selectedMetier = providerDash.profile.specialite;
      _selectedVille = providerDash.profile.ville;
    });
  }

  void _saveEditMode(ProviderDashboardProvider providerDash) {
    final parts = _nameController.text.trim().split(RegExp(r'\s+'));
    final prenom = parts.isNotEmpty ? parts.first : '';
    final nom = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    providerDash.updateProfile(
      nom: nom.isEmpty ? null : nom,
      prenom: prenom.isEmpty ? null : prenom,
      specialite: _selectedMetier,
      ville: _selectedVille,
    );
    setState(() {
      _editing = false;
      _editingAbout = false;
      _addingCert = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final providerDash = _ownerMode ? context.watch<ProviderDashboardProvider>() : null;
    final data = _ownerMode
        ? ProfileViewData.fromProviderProfile(providerDash!.profile)
        : ProfileViewData.fromProviderModel(_visitorProvider);
    final providerName = _ownerMode ? providerDash!.profile.nomComplet : _visitorProvider.name;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      bottomNavigationBar: (_ownerMode && providerDash!.hasPendingAvailabilityChanges)
          ? _buildSaveBar(providerDash)
          : null,
      body: SafeArea(
        child: Column(
          children: [
            const NavBar(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isStacked = constraints.maxWidth < 900;
                  final sections = <Widget>[
                    _buildProfileCard(data, providerDash),
                    const SizedBox(height: 16),
                    _buildAboutSection(data, providerDash),
                    const SizedBox(height: 16),
                    _buildSkillsSection(data, providerDash),
                    const SizedBox(height: 16),
                    _buildCertificationsSection(data, providerDash),
                    const SizedBox(height: 16),
                    _buildCalendarSection(providerName),
                    const SizedBox(height: 16),
                    _buildReviewsSection(data),
                  ];
                  if (isStacked) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        child: Column(
                          children: [
                            const Align(alignment: Alignment.centerLeft, child: AppBackButton()),
                            ...sections,
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
                                const Align(alignment: Alignment.centerLeft, child: AppBackButton()),
                                _buildProfileCard(data, providerDash),
                                const SizedBox(height: 16),
                                _buildSkillsSection(data, providerDash),
                                const SizedBox(height: 16),
                                _buildCertificationsSection(data, providerDash),
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
                                _buildAboutSection(data, providerDash),
                                const SizedBox(height: 16),
                                _buildCalendarSection(providerName),
                                const SizedBox(height: 16),
                                _buildReviewsSection(data),
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

  // ---------------- Carte profil ----------------

  Widget _buildProfileCard(ProfileViewData p, ProviderDashboardProvider? providerDash) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF2)),
      ),
      child: Column(
        children: [
          _buildAvatar(p),
          const SizedBox(height: 16),
          if (_ownerMode && _editing)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: TextField(
                controller: _nameController,
                textAlign: TextAlign.center,
                style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700),
                decoration: const InputDecoration(isDense: true),
              ),
            )
          else
            Text(p.name, style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
          const SizedBox(height: 4),
          if (_ownerMode && _editing)
            Column(
              children: [
                const SizedBox(height: 8),
                _buildDropdown('Métier', _selectedMetier, Referentials.metiers, (v) => setState(() => _selectedMetier = v)),
                const SizedBox(height: 8),
                _buildDropdown('Ville', _selectedVille, Referentials.villes, (v) => setState(() => _selectedVille = v)),
              ],
            )
          else
            Text('${p.specialty} · ${p.ville}', style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF64748B))),
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
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFE8ECF2)))),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildStat(context.tr('profile.missions'), p.formattedInterventions)),
                    Expanded(child: _buildStat(context.tr('profile.note'), p.formattedRating)),
                    Expanded(child: _buildStat(context.tr('profile.succes'), p.successRate)),
                  ],
                ),
                if (_ownerMode && _editing)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'Calculées automatiquement · non modifiables',
                      style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ScaleOnHover(
            scale: 1.03,
            child: PointerCursor(
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _toast('Message envoyé'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    side: const BorderSide(color: Color(0xFFE8ECF2)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.message_outlined, size: 16),
                  label: Text(context.tr('profile.envoyerMessage'), style: const TextStyle(fontSize: 12)),
                ),
              ),
            ),
          ),
          if (_ownerMode) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: _editing
                  ? ElevatedButton.icon(
                      onPressed: () => _saveEditMode(providerDash!),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316), foregroundColor: Colors.white),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Terminer l\'édition'),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => _enterEditMode(providerDash!),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Modifier mon profil'),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(ProfileViewData p) {
    return MouseRegion(
      cursor: (_ownerMode && _editing) ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: (_ownerMode && _editing) ? () => _toast('Sélection d\'une nouvelle photo de profil') : null,
        child: Stack(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1E40AF)]),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(p.initials, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
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
            if (_ownerMode && _editing)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x991E293B)),
                  child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String> onChanged) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label, isDense: true),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }

  Widget _buildBadge(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: textColor, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w700, color: const Color(0xFF2563EB))),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.dmSans(fontSize: 10, color: const Color(0xFF94A3B8))),
      ],
    );
  }

  // ---------------- À propos ----------------

  Widget _buildAboutSection(ProfileViewData p, ProviderDashboardProvider? providerDash) {
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
              Text(context.tr('profile.aPropos'), style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
              if (_ownerMode && _editing) ...[
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() {
                    _editingAbout = !_editingAbout;
                    if (_editingAbout) _aboutController.text = p.about;
                  }),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          if (_ownerMode && _editing && _editingAbout) ...[
            TextField(
              controller: _aboutController,
              maxLines: 5,
              maxLength: 600,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => setState(() => _editingAbout = false), child: const Text('Annuler')),
                ElevatedButton(
                  onPressed: () {
                    providerDash!.updateProfile(description: _aboutController.text.trim());
                    setState(() => _editingAbout = false);
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            ),
          ] else
            Text(p.about, style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF64748B), height: 1.7)),
        ],
      ),
    );
  }

  // ---------------- Compétences ----------------

  Widget _buildSkillsSection(ProfileViewData p, ProviderDashboardProvider? providerDash) {
    final editable = _ownerMode && _editing;
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
              Text(context.tr('profile.competences'), style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < p.skills.length; i++) _buildSkillChip(p.skills[i], editable, () {
                final next = List.of(providerDash!.profile.competences)..removeAt(i);
                providerDash.updateCompetences(next);
              }),
            ],
          ),
          if (editable) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _skillInputController,
              enabled: p.skills.length < 12,
              decoration: InputDecoration(
                isDense: true,
                hintText: p.skills.length >= 12 ? 'Limite atteinte' : '+ Ajouter une compétence',
              ),
              onSubmitted: (_) {
                final v = _skillInputController.text.trim();
                if (v.isEmpty) return;
                if (p.skills.length >= 12) {
                  _toast('Maximum 12 compétences');
                  return;
                }
                providerDash!.updateCompetences([...providerDash.profile.competences, v]);
                _skillInputController.clear();
              },
            ),
            const SizedBox(height: 4),
            Text('Appuyez sur Entrée pour valider · ${p.skills.length}/12 compétences',
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ],
        ],
      ),
    );
  }

  Widget _buildSkillChip(String label, bool editable, VoidCallback onRemove) {
    return ScaleOnHover(
      scale: 1.05,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFFEFF4FF), borderRadius: BorderRadius.circular(6)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF2563EB))),
            if (editable) ...[
              const SizedBox(width: 5),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(Icons.close, size: 12, color: Color(0xFF2563EB)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------- Certifications ----------------

  Widget _buildCertificationsSection(ProfileViewData p, ProviderDashboardProvider? providerDash) {
    final editable = _ownerMode && _editing;
    if (p.certifications.isEmpty && !editable) return const SizedBox();
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
              Text(context.tr('profile.certifications'), style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
              if (editable) ...[
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() => _addingCert = !_addingCert),
                  icon: const Icon(Icons.add, size: 18),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < p.certifications.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFE8ECF2)),
            _buildCertItem(p.certifications[i], editable, () {
              providerDash!.removeCertification(i);
            }),
          ],
          if (editable && _addingCert) ...[
            const Divider(height: 20, color: Color(0xFFE8ECF2)),
            TextField(controller: _certTitleController, decoration: const InputDecoration(labelText: 'Intitulé', isDense: true)),
            const SizedBox(height: 8),
            TextField(controller: _certOrgController, decoration: const InputDecoration(labelText: 'Organisme délivrant', isDense: true)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => setState(() => _addingCert = false), child: const Text('Annuler')),
                ElevatedButton(
                  onPressed: () {
                    final titre = _certTitleController.text.trim();
                    if (titre.isEmpty) return;
                    providerDash!.addCertification(Certification(
                      titre: titre,
                      organisme: _certOrgController.text.trim(),
                      enAttenteVerification: true,
                    ));
                    _certTitleController.clear();
                    _certOrgController.clear();
                    setState(() => _addingCert = false);
                    _toast('Certification soumise à vérification');
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCertItem(CertificationDisplay cert, bool editable, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: const Color(0xFFEFF4FF), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.workspace_premium_outlined, size: 16, color: Color(0xFF2563EB)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cert.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text(cert.subtitle, style: GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFF94A3B8))),
                if (cert.pending) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(10)),
                    child: const Text('En attente de vérification', style: TextStyle(fontSize: 10, color: Color(0xFFB45309))),
                  ),
                ],
              ],
            ),
          ),
          if (editable)
            IconButton(onPressed: onRemove, icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444))),
        ],
      ),
    );
  }

  // ---------------- Calendrier ----------------

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildCalendarSection(String providerName) {
    final interventions = context.watch<InterventionProvider>();
    final ownerProvider = _ownerMode ? context.watch<ProviderDashboardProvider>() : null;
    final today = DateTime.now();

    bool isPast(DateTime day) => DateTime(day.year, day.month, day.day).isBefore(DateTime(today.year, today.month, today.day));
    bool isToday(DateTime day) => _sameDay(day, today);
    bool isAvailable(DateTime day) => _ownerMode ? ownerProvider!.isAvailableOn(day) : true;
    bool isLocked(DateTime day) => interventions.isDateLocked(providerName, day);

    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_visibleMonth.year, _visibleMonth.month, 1).weekday; // 1=lundi
    final leadingBlanks = firstWeekday - 1;
    final monthNames = const [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];

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
              Text(context.tr('profile.disponibilites'), style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
            ],
          ),
          if (_ownerMode)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Cliquez sur une date pour basculer entre disponible et indisponible. Les journées avec une intervention déjà réservée sont verrouillées.',
                style: GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFF64748B)),
              ),
            ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final monthNav = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => setState(() {
                      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
                      _selectedDay = null;
                    }),
                    icon: const Icon(Icons.chevron_left, size: 18),
                  ),
                  SizedBox(
                    width: 110,
                    child: Text('${monthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
                      _selectedDay = null;
                    }),
                    icon: const Icon(Icons.chevron_right, size: 18),
                  ),
                ],
              );

              if (!_ownerMode) return monthNav;

              final bulkButtons = Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  OutlinedButton(
                    onPressed: () => ownerProvider!.bulkSetAvailability(_visibleMonth, true),
                    child: const Text('Tout disponible', style: TextStyle(fontSize: 11)),
                  ),
                  OutlinedButton(
                    onPressed: () => ownerProvider!.bulkSetAvailability(_visibleMonth, false),
                    child: const Text('Tout indisponible', style: TextStyle(fontSize: 11)),
                  ),
                ],
              );

              if (constraints.maxWidth < 480) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [monthNav, const SizedBox(height: 8), bulkButtons],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  monthNav,
                  Flexible(child: Align(alignment: Alignment.centerRight, child: bulkButtons)),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _buildLegend(const Color(0xFFECFDF5), const Color(0xFF059669), 'Disponible'),
              _buildLegend(const Color(0xFFFEF2F2), const Color(0xFFEF4444), 'Indisponible'),
              _buildLegend(const Color(0xFF2563EB), const Color(0xFF2563EB), 'Aujourd\'hui / sélectionné'),
              if (_ownerMode) _buildLegend(const Color(0xFFF5F7FA), const Color(0xFF94A3B8), 'Verrouillé (réservé)'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemCount: leadingBlanks + daysInMonth,
            itemBuilder: (context, index) {
              if (index < leadingBlanks) return const SizedBox();
              final day = DateTime(_visibleMonth.year, _visibleMonth.month, index - leadingBlanks + 1);
              return _buildDayCell(
                day: day,
                today: isToday(day),
                selected: _selectedDay != null && _sameDay(_selectedDay!, day),
                available: isAvailable(day),
                locked: isLocked(day),
                past: isPast(day),
                ownerProvider: ownerProvider,
              );
            },
          ),
          if (!_ownerMode && _selectedDay != null) ...[
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE8ECF2)),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Créneaux du ${_selectedDay!.day} ${monthNames[_selectedDay!.month - 1].toLowerCase()}',
                    style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(20)),
                  child: const Text('24h/24', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF059669))),
                ),
              ],
            ),
            const SizedBox(height: 10),
            HourSlotGrid(
              selectedHours: _pickedHours,
              bookedHours: interventions.hoursBookedFor(providerName, _selectedDay!),
              onChanged: (hours) => setState(() => _pickedHours = hours),
            ),
            if (_pickedHours.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.push(
                      '/reservation',
                      extra: BookingEntryArgs(provider: _visitorProvider, date: _selectedDay!, hours: _pickedHours),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: Text('Continuer la réservation (${_pickedHours.length}h)'),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildLegend(Color bg, Color dot, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(3), border: Border.all(color: dot, width: 1))),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildDayCell({
    required DateTime day,
    required bool today,
    required bool selected,
    required bool available,
    required bool locked,
    required bool past,
    required ProviderDashboardProvider? ownerProvider,
  }) {
    Color bg;
    Color fg;
    if (today || selected) {
      bg = const Color(0xFF2563EB);
      fg = Colors.white;
    } else if (locked) {
      bg = const Color(0xFFF5F7FA);
      fg = const Color(0xFF94A3B8);
    } else if (past) {
      bg = Colors.transparent;
      fg = const Color(0xFF94A3B8);
    } else if (available) {
      bg = const Color(0xFFECFDF5);
      fg = const Color(0xFF059669);
    } else {
      bg = const Color(0xFFFEF2F2);
      fg = const Color(0xFFEF4444);
    }

    VoidCallback? onTap;
    if (_ownerMode) {
      onTap = () {
        if (locked) {
          _toast('Journée verrouillée : une intervention est déjà réservée');
          return;
        }
        ownerProvider!.toggleAvailabilityDay(day);
      };
    } else if (!past) {
      onTap = () => setState(() {
            _selectedDay = day;
            _pickedHours = [];
          });
    }

    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(2),
          height: 32,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text('${day.day}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: fg)),
              if (locked)
                Positioned(top: 2, right: 3, child: Icon(Icons.lock, size: 8, color: fg)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveBar(ProviderDashboardProvider providerDash) {
    final buttons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: providerDash.cancelAvailabilityChanges,
          child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
        ),
        const SizedBox(width: 4),
        ElevatedButton(
          onPressed: providerDash.saveAvailabilityChanges,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
          child: const Text('Enregistrer'),
        ),
      ],
    );
    const message = Text(
      'Vous avez des modifications de disponibilité non enregistrées.',
      style: TextStyle(color: Colors.white, fontSize: 12),
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
    );

    return Material(
      color: const Color(0xFF1E293B),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 420) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [message, const SizedBox(height: 8), buttons],
                );
              }
              return Row(
                children: [
                  const Expanded(child: message),
                  buttons,
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------- Avis ----------------

  Widget _buildReviewsSection(ProfileViewData p) {
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
              Text('${context.tr('profile.avis')} (${p.reviewCount})',
                  style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
            ],
          ),
          if (_ownerMode && _editing)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Les avis sont publiés par vos clients et ne peuvent pas être modifiés.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic)),
            ),
          const SizedBox(height: 14),
          if (p.reviews.isEmpty)
            const Text('Aucun avis pour le moment', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)))
          else
            for (var i = 0; i < p.reviews.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: Color(0xFFE8ECF2)),
              _buildReviewItem(p.reviews[i]),
            ],
        ],
      ),
    );
  }

  Widget _buildReviewItem(ReviewDisplay review) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: Color(0xFFDBEAFE), shape: BoxShape.circle),
            child: Center(
              child: Text(review.initials, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
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
                    Text(review.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                    Text(review.date, style: GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFF94A3B8))),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: List.generate(5, (i) => Icon(i < review.rating ? Icons.star : Icons.star_border, size: 12, color: const Color(0xFFF59E0B))),
                ),
                const SizedBox(height: 6),
                Text(review.text, style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
