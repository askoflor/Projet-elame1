import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/localization/translation_provider.dart';
import '../../../../../core/widgets/micro_interactions.dart';
import '../../../state/provider_dashboard_state.dart';

const Color _primary = Color(0xFF2563EB);
const Color _textPrimary = Color(0xFF1E293B);
const Color _textSecondary = Color(0xFF64748B);
const Color _textMuted = Color(0xFF94A3B8);
const Color _border = Color(0xFFE8ECF2);

class ParametresContent extends StatefulWidget {
  const ParametresContent({super.key});

  @override
  State<ParametresContent> createState() => _ParametresContentState();
}

class _ParametresContentState extends State<ParametresContent> {
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _specialiteController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final p = context.read<ProviderDashboardProvider>().profile;
    _nomController = TextEditingController(text: p.nom);
    _prenomController = TextEditingController(text: p.prenom);
    _emailController = TextEditingController(text: p.email);
    _phoneController = TextEditingController(text: p.phone);
    _specialiteController = TextEditingController(text: p.specialite);
    _descriptionController = TextEditingController(text: p.description);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialiteController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProviderDashboardProvider>();
    final tr = context.tr;
    final p = provider.profile;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(tr),
          const SizedBox(height: 20),
          _buildProfileSection(tr),
          const SizedBox(height: 20),
          _buildCompetencesSection(tr, p),
          const SizedBox(height: 20),
          _buildPreferencesSection(tr),
          const SizedBox(height: 20),
          _buildSecuritySection(tr),
        ],
      ),
    );
  }

  Widget _buildHeader(String Function(String) tr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr('provider.parametres'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _textPrimary, fontFamily: 'Sora')),
        const SizedBox(height: 4),
        Text(tr('provider.parametresSub'), style: const TextStyle(fontSize: 13, color: _textSecondary, fontFamily: 'DM Sans')),
      ],
    );
  }

  Widget _buildProfileSection(String Function(String) tr) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 20, color: _primary),
              const SizedBox(width: 8),
              Text(tr('provider.infosPersonnelles'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textPrimary, fontFamily: 'Sora')),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(tr('provider.prenom'), _prenomController),
          const SizedBox(height: 14),
          _buildTextField(tr('provider.nom'), _nomController),
          const SizedBox(height: 14),
          _buildTextField(tr('provider.email'), _emailController),
          const SizedBox(height: 14),
          _buildTextField(tr('provider.telephone'), _phoneController),
          const SizedBox(height: 14),
          _buildTextField(tr('provider.specialite'), _specialiteController),
          const SizedBox(height: 14),
          _buildTextField(tr('provider.description'), _descriptionController, maxLines: 3),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: _buildSaveButton(tr('provider.enregistrer')),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _textSecondary, fontFamily: 'DM Sans')),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _primary)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 13, color: _textPrimary, fontFamily: 'DM Sans'),
        ),
      ],
    );
  }

  void _saveProfile() {
    context.read<ProviderDashboardProvider>().updateProfile(
      nom: _nomController.text,
      prenom: _prenomController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      specialite: _specialiteController.text,
      description: _descriptionController.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('Profil mis à jour', style: const TextStyle(fontFamily: 'DM Sans')),
          ],
        ),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildSaveButton(String label) {
    return PointerCursor(
      child: GestureDetector(
        onTap: _saveProfile,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: _primary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))]),
          child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white, fontFamily: 'DM Sans')),
        ),
      ),
    );
  }

  Widget _buildCompetencesSection(String Function(String) tr, dynamic p) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_outlined, size: 20, color: _primary),
              const SizedBox(width: 8),
              Text(tr('provider.competences'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textPrimary, fontFamily: 'Sora')),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (p.competences as List<String>).map((c) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8), border: Border.all(color: _primary.withOpacity(0.2))),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(c, style: const TextStyle(fontSize: 12, color: _primary, fontFamily: 'DM Sans', fontWeight: FontWeight.w500)),
                    const SizedBox(width: 6),
                    const Icon(Icons.close_rounded, size: 14, color: _primary),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _buildAddCompetenceField(tr),
        ],
      ),
    );
  }

  Widget _buildAddCompetenceField(String Function(String) tr) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: tr('provider.ajouterCompetence'),
              hintStyle: const TextStyle(fontSize: 13, color: _textMuted, fontFamily: 'DM Sans'),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              isDense: true,
            ),
            style: const TextStyle(fontSize: 13, fontFamily: 'DM Sans', color: _textPrimary),
          ),
        ),
        const SizedBox(width: 8),
        PointerCursor(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(String Function(String) tr) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_outlined, size: 20, color: _primary),
              const SizedBox(width: 8),
              Text(tr('provider.preferences'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textPrimary, fontFamily: 'Sora')),
            ],
          ),
          const SizedBox(height: 16),
          _preferenceToggle(tr('provider.notifNouvellesMissions'), tr('provider.notifNouvellesMissionsDesc'), true),
          const Divider(height: 24),
          _preferenceToggle(tr('provider.notifRappels'), tr('provider.notifRappelsDesc'), true),
          const Divider(height: 24),
          _preferenceToggle(tr('provider.notifPaiements'), tr('provider.notifPaiementsDesc'), false),
          const Divider(height: 24),
          _preferenceToggle(tr('provider.notifEvaluations'), tr('provider.notifEvaluationsDesc'), true),
        ],
      ),
    );
  }

  Widget _preferenceToggle(String title, String description, bool value) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _textPrimary, fontFamily: 'DM Sans')),
              const SizedBox(height: 2),
              Text(description, style: const TextStyle(fontSize: 11, color: _textMuted, fontFamily: 'DM Sans')),
            ],
          ),
        ),
        Switch(value: value, onChanged: (_) {}, activeColor: _primary),
      ],
    );
  }

  Widget _buildSecuritySection(String Function(String) tr) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security_rounded, size: 20, color: _primary),
              const SizedBox(width: 8),
              Text(tr('provider.securite'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textPrimary, fontFamily: 'Sora')),
            ],
          ),
          const SizedBox(height: 16),
          _buildPasswordField(tr('provider.motDePasseActuel')),
          const SizedBox(height: 12),
          _buildPasswordField(tr('provider.nouveauMotDePasse')),
          const SizedBox(height: 12),
          _buildPasswordField(tr('provider.confirmerMotDePasse')),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: _buildSaveButton(tr('provider.changerMotDePasse')),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _textSecondary, fontFamily: 'DM Sans')),
        const SizedBox(height: 6),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _primary)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 13, color: _textPrimary, fontFamily: 'DM Sans'),
        ),
      ],
    );
  }
}
