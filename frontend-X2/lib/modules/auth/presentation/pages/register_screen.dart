import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/auth_provider.dart';
import '../../../../core/localization/translation_provider.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../../../core/widgets/app_back_button.dart';

enum UserRole { client, prestataire }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nomFocus = FocusNode();
  final _prenomFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  UserRole _role = UserRole.client;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  final _specialiteController = TextEditingController();
  final _specialiteFocus = FocusNode();
  final _dateNaissanceController = TextEditingController();
  DateTime? _dateNaissance;

  Color get _primaryColor =>
      _role == UserRole.prestataire ? const Color(0xFFF97316) : const Color(0xFF2563EB);

  Color get _primaryDark =>
      _role == UserRole.prestataire ? const Color(0xFFEA580C) : const Color(0xFF1D4ED8);

  Color get _primaryDarker =>
      _role == UserRole.prestataire ? const Color(0xFFC2410C) : const Color(0xFF1E40AF);

  Color get _lightBg =>
      _role == UserRole.prestataire ? const Color(0xFFFFF7ED) : const Color(0xFFEFF6FF);

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nomFocus.dispose();
    _prenomFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _specialiteController.dispose();
    _specialiteFocus.dispose();
    _dateNaissanceController.dispose();
    super.dispose();
  }

  double get _passwordStrength {
    final pwd = _passwordController.text;
    if (pwd.isEmpty) return 0;
    double score = 0;
    if (pwd.length >= 6) score += 0.2;
    if (pwd.length >= 10) score += 0.2;
    if (RegExp(r'[A-Z]').hasMatch(pwd)) score += 0.2;
    if (RegExp(r'[0-9]').hasMatch(pwd)) score += 0.2;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(pwd)) score += 0.2;
    return score;
  }

  Color get _strengthColor {
    final s = _passwordStrength;
    if (s == 0) return Colors.transparent;
    if (s < 0.3) return const Color(0xFFEF4444);
    if (s < 0.6) return const Color(0xFFF97316);
    if (s < 0.8) return const Color(0xFFEAB308);
    return const Color(0xFF22C55E);
  }

  String get _strengthKey {
    final s = _passwordStrength;
    if (s == 0) return '';
    if (s < 0.3) return 'auth.strengthFaible';
    if (s < 0.6) return 'auth.strengthMoyen';
    if (s < 0.8) return 'auth.strengthBon';
    return 'auth.strengthFort';
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      _nomController.text.trim(),
      _prenomController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      _role == UserRole.prestataire ? 'PRESTATAIRE' : 'CLIENT',
      specialite: _role == UserRole.prestataire ? _specialiteController.text.trim() : null,
      dateNaissance: _role == UserRole.prestataire ? _dateNaissance : null,
    );

    if (success && mounted) {
      final route = _role == UserRole.prestataire
          ? AppConstants.providerLoginRoute
          : AppConstants.clientLoginRoute;
      context.go(route);
    }
  }

  void _handleDemoMode(AuthProvider auth) {
    final route = _role == UserRole.prestataire
        ? AppConstants.providerLoginRoute
        : AppConstants.clientLoginRoute;
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _lightBg,
              const Color(0xFFF8F9FA),
              const Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80, right: -60,
              child: Container(
                width: 260, height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _primaryColor.withOpacity(0.08),
                      _primaryColor.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -40, left: -40,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _primaryColor.withOpacity(0.06),
                      _primaryColor.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AppBackButton(),
                        ),
                        _buildHeader(),
                        const SizedBox(height: 28),
                        _buildForm(),
                        const SizedBox(height: 24),
                        _buildFooter(),
                        const SizedBox(height: 32),
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

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_primaryColor, _primaryDarker],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: _primaryColor.withOpacity(0.12),
                blurRadius: 50,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 38),
        ),
        const SizedBox(height: 28),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [_primaryColor, _primaryDarker],
          ).createShader(bounds),
          child: Text(
            context.tr('auth.registerTitle'),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.tr('auth.registerSubtitle'),
          style: TextStyle(fontSize: 15, color: Colors.grey[500], letterSpacing: 0.2),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Container(
        padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.04),
            blurRadius: 60,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildRoleSelector(),
            const SizedBox(height: 24),
            if (_role == UserRole.prestataire) ...[
              _buildSpecialiteField(),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nomController,
                    focusNode: _nomFocus,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: context.tr('auth.nomLabel'),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    onFieldSubmitted: (_) => _prenomFocus.requestFocus(),
                    validator: (v) => (v == null || v.isEmpty) ? context.tr('auth.required') : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _prenomController,
                    focusNode: _prenomFocus,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: context.tr('auth.prenomLabel'),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                    validator: (v) => (v == null || v.isEmpty) ? context.tr('auth.required') : null,
                  ),
                ),
              ],
            ),
            if (_role == UserRole.prestataire) ...[
              const SizedBox(height: 16),
              _buildDateNaissanceField(),
            ],
            const SizedBox(height: 18),
            TextFormField(
              controller: _emailController,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: context.tr('auth.emailLabel'),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
              validator: (value) {
                if (value == null || value.isEmpty) return context.tr('auth.emailEmptyError');
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return context.tr('auth.emailInvalid');
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.tr('auth.passwordLabel'),
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: PointerCursor(child: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                )),
              ),
              onChanged: (_) => setState(() {}),
              onFieldSubmitted: (_) => _confirmFocus.requestFocus(),
              validator: (value) {
                if (value == null || value.isEmpty) return context.tr('auth.passwordEmptyError');
                if (value.length < 6) return context.tr('auth.passwordMinError');
                return null;
              },
            ),
            if (_passwordController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _passwordStrength,
                      backgroundColor: const Color(0xFFE5E7EB),
                      color: _strengthColor,
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _strengthKey.isEmpty ? '' : '${context.tr('auth.passwordStrength')}${context.tr(_strengthKey)}',
                    style: TextStyle(fontSize: 12, color: _strengthColor, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            TextFormField(
              controller: _confirmPasswordController,
              focusNode: _confirmFocus,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: context.tr('auth.confirmLabel'),
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: PointerCursor(child: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                )),
              ),
              onFieldSubmitted: (_) => _handleRegister(),
              validator: (value) {
                if (value == null || value.isEmpty) return context.tr('auth.confirmEmptyError');
                if (value != _passwordController.text) return context.tr('auth.confirmMismatchError');
                return null;
              },
            ),
            const SizedBox(height: 24),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final isLoading = auth.status == AuthStatus.loading;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (auth.status == AuthStatus.error && auth.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFECACA)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.error_outline, color: AppTheme.error, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      auth.errorMessage!,
                                      style: const TextStyle(color: Color(0xFF991B1B), fontSize: 13, height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (auth.isConnectionError) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ScaleOnHover(
                                  scale: 1.03,
                                  child: PointerCursor(child: OutlinedButton.icon(
                                    onPressed: () => _handleDemoMode(auth),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: _primaryColor,
                                      side: BorderSide(color: _primaryColor),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(Icons.rocket_launch_outlined, size: 18),
                                    label: Text(context.tr('auth.modeDemo')),
                                  )),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    Container(
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: isLoading
                            ? null
                            : LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [_primaryColor, _primaryDark],
                              ),
                        boxShadow: isLoading
                            ? null
                            : [
                                BoxShadow(
                                  color: _primaryColor.withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                      ),
                      child: ScaleOnHover(
                        scale: 1.03,
                        child: PointerCursor(child: ElevatedButton(
                          onPressed: isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                )
                              : Text(
                                  context.tr(_role == UserRole.prestataire
                                      ? 'auth.registerPrestataireButton'
                                      : 'auth.registerClientButton'),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                        )),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(child: _buildRoleOption(context.tr('auth.roleClient'), UserRole.client, Icons.person)),
          const SizedBox(width: 5),
          Expanded(child: _buildRoleOption(context.tr('auth.rolePrestataire'), UserRole.prestataire, Icons.work)),
        ],
      ),
    );
  }

  Widget _buildRoleOption(String title, UserRole role, IconData icon) {
    final isSelected = _role == role;
    final color = isSelected
        ? (role == UserRole.prestataire ? const Color(0xFFF97316) : const Color(0xFF2563EB))
        : const Color(0xFF94A3B8);
    return ScaleOnHover(
      scale: 1.03,
      child: PointerCursor(
        child: GestureDetector(
          onTap: () => setState(() => _role = role),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected
                  ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final List<String> _specialites = [
    'Électricité',
    'Plomberie',
    'Carrelage',
    'Climatisation',
    'Maintenance',
    'Jardinage',
    'Peinture',
    'Menuiserie',
  ];

  String _specialiteKey(String value) {
    const map = {
      'Électricité': 'auth.specialiteElectricite',
      'Plomberie': 'auth.specialitePlomberie',
      'Carrelage': 'auth.specialiteCarrelage',
      'Climatisation': 'auth.specialiteClimatisation',
      'Maintenance': 'auth.specialiteMaintenance',
      'Jardinage': 'auth.specialiteJardinage',
      'Peinture': 'auth.specialitePeinture',
      'Menuiserie': 'auth.specialiteMenuiserie',
    };
    return map[value] ?? value;
  }

  Widget _buildSpecialiteField() {
    return DropdownButtonFormField<String>(
      value: _specialiteController.text.isNotEmpty ? _specialiteController.text : null,
      hint: Text(context.tr('auth.specialiteHint')),
      icon: const Icon(Icons.arrow_drop_down),
      decoration: InputDecoration(
        labelText: context.tr('auth.specialiteLabel'),
        prefixIcon: const Icon(Icons.work_outline),
      ),
      items: _specialites.map((s) {
        return DropdownMenuItem(value: s, child: Text(context.tr(_specialiteKey(s))));
      }).toList(),
      onChanged: (v) {
        setState(() => _specialiteController.text = v ?? '');
      },
      validator: (v) {
        if (_role == UserRole.prestataire && (v == null || v.isEmpty)) {
          return context.tr('auth.required');
        }
        return null;
      },
    );
  }

  Widget _buildDateNaissanceField() {
    return PointerCursor(child: GestureDetector(
      onTap: _pickDate,
      child: AbsorbPointer(
        child: TextFormField(
          controller: _dateNaissanceController,
          decoration: InputDecoration(
            labelText: context.tr('auth.dateNaissanceLabel'),
            prefixIcon: const Icon(Icons.calendar_today_outlined),
            hintText: context.tr('auth.dateNaissanceHint'),
          ),
          validator: (v) {
            if (_role == UserRole.prestataire && _dateNaissance == null) {
              return context.tr('auth.required');
            }
            return null;
          },
        ),
      ),
    ));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateNaissance ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _dateNaissance = picked;
        _dateNaissanceController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.tr('auth.alreadyHaveAccount'), style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          HoverWrap(
            scale: 1.05,
            child: PointerCursor(child: TextButton(
              onPressed: () => context.go(AppConstants.loginRoute),
              style: TextButton.styleFrom(foregroundColor: _primaryColor),
              child: Text(context.tr('auth.loginButton'), style: const TextStyle(fontWeight: FontWeight.w600)),
            )),
          ),
        ],
      ),
    );
  }
}
