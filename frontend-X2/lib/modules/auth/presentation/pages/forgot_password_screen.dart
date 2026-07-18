import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/auth_provider.dart';
import '../../../../core/localization/translation_provider.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../../../core/widgets/app_back_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();
  bool _isSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final error = await authProvider.forgotPassword(
      _emailController.text.trim(),
    );

    if (!mounted) return;

    if (error == null) {
      setState(() => _isSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEFF6FF),
              Color(0xFFF8F9FA),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80, right: -80,
              child: Container(
                width: 280, height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF2563EB).withOpacity(0.08),
                      const Color(0xFF2563EB).withOpacity(0),
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
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AppBackButton(),
                        ),
                        const SizedBox(height: 20),
                        _buildHeader(),
                        const SizedBox(height: 36),
                        if (_isSent) _buildSuccess() else _buildForm(),
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
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: const Color(0xFF2563EB).withOpacity(0.12),
                blurRadius: 50,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: const Icon(Icons.lock_reset_rounded, color: Colors.white, size: 38),
        ),
        const SizedBox(height: 28),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
          ).createShader(bounds),
          child: Text(
            context.tr('auth.forgotTitle'),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.tr('auth.forgotSubtitle'),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey[500], letterSpacing: 0.2),
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
            color: const Color(0xFF2563EB).withOpacity(0.04),
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
            TextFormField(
              controller: _emailController,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: context.tr('auth.emailLabel'),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              onFieldSubmitted: (_) => _handleSubmit(),
              validator: (value) {
                if (value == null || value.isEmpty) return context.tr('auth.emailEmptyError');
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return context.tr('auth.emailInvalidError');
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                if (auth.status == AuthStatus.error && auth.errorMessage != null) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
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
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final isLoading = auth.status == AuthStatus.loading;
                return Container(
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: isLoading
                        ? null
                        : const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                          ),
                    boxShadow: isLoading
                        ? null
                        : [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                  ),
                  child: ScaleOnHover(
                    scale: 1.03,
                    child: PointerCursor(child: ElevatedButton(
                      onPressed: isLoading ? null : _handleSubmit,
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
                          : Text(context.tr('auth.forgotButton'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    )),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildSuccess() {
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
            color: const Color(0xFF2563EB).withOpacity(0.04),
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
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 36),
          ),
          const SizedBox(height: 20),
          Text(
            context.tr('auth.forgotSuccess'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            context.tr('auth.forgotSuccessMsg'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500], height: 1.5),
          ),
          const SizedBox(height: 24),
          Container(
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ScaleOnHover(
              scale: 1.03,
              child: PointerCursor(child: ElevatedButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppConstants.loginRoute);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(context.tr('auth.forgotReturn'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              )),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
