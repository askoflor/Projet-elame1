import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../../../core/utils/hour_range_formatter.dart';
import '../../../../modules/home/presentation/widgets/header/nav_bar.dart';
import '../../domain/payment_method.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../intervention/domain/intervention.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage>
    with SingleTickerProviderStateMixin {
  PaymentMethod? _selectedMethod;
  final _phoneController = TextEditingController();
  final _promoController = TextEditingController();
  bool _isProcessing = false;
  bool _isSuccess = false;
  late AnimationController _successAnimController;
  late Animation<double> _successScale;

  Intervention? get _data {
    try {
      return GoRouterState.of(context).extra as Intervention?;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _successAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successScale = CurvedAnimation(
      parent: _successAnimController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _promoController.dispose();
    _successAnimController.dispose();
    super.dispose();
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
                      const SizedBox(height: 8),
                      _isSuccess ? _buildSuccessView() : _buildPaymentView(),
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

  Widget _buildSuccessView() {
    final data = _data;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _successScale,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF10B981).withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 10)),
                ],
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 50),
            ),
          ),
          const SizedBox(height: 32),
          Text('Paiement réussi !', style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Text('Votre paiement a bien été enregistré', style: GoogleFonts.dmSans(fontSize: 15, color: const Color(0xFF64748B))),
          const SizedBox(height: 32),
          if (data != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Column(
                children: [
                  Text('Référence', style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF059669))),
                  const SizedBox(height: 4),
                  Text(data.reference, style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF065F46))),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE8ECF2))),
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  _buildSuccessRow('Prestataire', data.providerName),
                  const SizedBox(height: 8),
                  _buildSuccessRow('Service', data.service),
                  const SizedBox(height: 8),
                  _buildSuccessRow('Date', '${data.date.day}/${data.date.month}/${data.date.year} · ${formatHourRanges(data.heures)}'),
                  const SizedBox(height: 8),
                  _buildSuccessRow('Adresse', data.adresse),
                  const SizedBox(height: 8),
                  _buildSuccessRow('Montant', '${data.montant?.toStringAsFixed(0) ?? '—'} FCFA'),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text('Un SMS de confirmation vous sera envoyé', style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF94A3B8))),
          const SizedBox(height: 32),
          _buildActionButton('Retour à l\'accueil', onTap: () => context.go('/')),
          const SizedBox(height: 12),
          _buildActionButton('Voir mes réservations', onTap: () => context.go('/espace-client'), isSecondary: true),
        ],
      ),
    );
  }

  Widget _buildSuccessRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF64748B))),
        Text(value, style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildPaymentView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isStacked = constraints.maxWidth < 768;
          if (isStacked) {
            return Column(children: [_buildPaymentForm(), const SizedBox(height: 16), _buildOrderSummaryCard()]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: _buildPaymentForm()),
              const SizedBox(width: 20),
              SizedBox(width: 360, child: _buildOrderSummaryCard()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaymentForm() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE8ECF2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.lock, color: Color(0xFF10B981), size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Paiement sécurisé', style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
                  Text('Choisissez votre méthode de paiement', style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF64748B))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPaymentMethods(),
          const SizedBox(height: 20),
          if (_selectedMethod != null && _selectedMethod != PaymentMethod.cash) _buildPaymentFormFields(),
          if (_selectedMethod == PaymentMethod.cash) _buildCashInfo(),
        ],
      ),
    );
  }

  int _gridColumnCount(double width) {
    if (width < 400) return 2;
    if (width < 600) return 3;
    return 4;
  }

  Widget _buildPaymentMethods() {
    final methods = [
      {'method': PaymentMethod.orangeMoney, 'label': 'OM', 'name': 'Orange Money', 'color': const Color(0xFFFF6600), 'lightBg': const Color(0xFFFFF4ED), 'icon': Icons.phone_android},
      {'method': PaymentMethod.mtnMoMo, 'label': 'MTN', 'name': 'MTN MoMo', 'color': const Color(0xFFFFCC00), 'lightBg': const Color(0xFFFFFBEB), 'icon': Icons.phone_iphone},
      {'method': PaymentMethod.wave, 'label': 'Wave', 'name': 'Wave', 'color': const Color(0xFF1A56DB), 'lightBg': const Color(0xFFEFF6FF), 'icon': Icons.waves},
      {'method': PaymentMethod.cash, 'label': 'Cash', 'name': 'Paiement sur place', 'color': const Color(0xFF10B981), 'lightBg': const Color(0xFFF0FDF4), 'icon': Icons.money},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('MÉTHODE DE PAIEMENT', style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF64748B), letterSpacing: 0.5)),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _gridColumnCount(constraints.maxWidth);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.0),
              itemCount: methods.length,
              itemBuilder: (context, index) {
                final m = methods[index];
                final method = m['method'] as PaymentMethod;
                final isSelected = _selectedMethod == method;
                final color = m['color'] as Color;
                final lightBg = m['lightBg'] as Color;

                return PointerCursor(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMethod = method),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? lightBg : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSelected ? color : const Color(0xFFE8ECF2), width: 2),
                        boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))] : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                            child: Center(
                              child: Text(m['label'] as String,
                                  style: GoogleFonts.sora(color: m['method'] == PaymentMethod.mtnMoMo ? const Color(0xFF1A1A1A) : Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(m['name'] as String, textAlign: TextAlign.center, style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? color : const Color(0xFF1E293B))),
                          if (isSelected) Padding(padding: const EdgeInsets.only(top: 4), child: Icon(Icons.check_circle, color: color, size: 14)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentFormFields() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _selectedMethod == PaymentMethod.orangeMoney ? const Color(0xFFFFF4ED) : _selectedMethod == PaymentMethod.mtnMoMo ? const Color(0xFFFFFBEB) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _selectedMethod == PaymentMethod.orangeMoney ? const Color(0xFFFED7AA) : _selectedMethod == PaymentMethod.mtnMoMo ? const Color(0xFFFDE68A) : const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _selectedMethod == PaymentMethod.orangeMoney ? const Color(0xFFFF6600) : _selectedMethod == PaymentMethod.mtnMoMo ? const Color(0xFFFFCC00) : const Color(0xFF1A56DB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _selectedMethod == PaymentMethod.orangeMoney ? 'OM' : _selectedMethod == PaymentMethod.mtnMoMo ? 'MTN' : 'Wave',
                    style: GoogleFonts.sora(color: _selectedMethod == PaymentMethod.mtnMoMo ? const Color(0xFF1A1A1A) : Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _selectedMethod == PaymentMethod.orangeMoney ? 'Orange Money' : _selectedMethod == PaymentMethod.mtnMoMo ? 'MTN MoMo' : 'Wave',
                style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('NUMÉRO DE TÉLÉPHONE', style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF64748B), letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE8ECF2))),
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.sora(fontSize: 14, color: const Color(0xFF1E293B), fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: '6XX XXX XXX',
                hintStyle: GoogleFonts.sora(fontSize: 14, color: const Color(0xFF94A3B8)),
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('+237', style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (context) {
              final intervention = _data;
              if (intervention == null || intervention.montant == null) return const SizedBox();
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Color(0xFFF97316)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFFF97316)),
                          children: [
                            const TextSpan(text: 'Vous recevrez un SMS pour valider le paiement de '),
                            TextSpan(text: '${intervention.montant!.toStringAsFixed(0)} FCFA', style: GoogleFonts.sora(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCashInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBBF7D0))),
      child: Row(
        children: [
          const Icon(Icons.money_off, color: Color(0xFF10B981), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Paiement à l\'intervention', style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF065F46))),
                const SizedBox(height: 4),
                Text('Vous réglerez le prestataire directement après l\'intervention.', style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF059669))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    final data = _data;
    if (data == null || data.montant == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE8ECF2))),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFFFF4ED), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.shopping_cart_outlined, size: 48, color: Color(0xFFF97316)),
            ),
            const SizedBox(height: 16),
            Text('Aucun paiement à effectuer', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
            const SizedBox(height: 6),
            Text(
              'Cette page n\'est accessible que depuis une intervention déjà chiffrée par un prestataire.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: 13, color: const Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 24),
            _buildActionButton('Retour à l\'accueil', onTap: () => context.go('/')),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE8ECF2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0x142563EB), Color(0x052563EB)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      data.providerName.isNotEmpty ? data.providerName[0] : '?',
                      style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.providerName, style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
                      Text(data.service, style: GoogleFonts.dmSans(fontSize: 11, color: const Color(0xFF64748B))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildOrderRow('Service', data.service, color: const Color(0xFF2563EB)),
          _buildOrderRow('Date', '${data.date.day}/${data.date.month}/${data.date.year}'),
          _buildOrderRow('Créneaux', formatHourRanges(data.heures)),
          _buildOrderRow('Adresse', data.adresse),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE8ECF2)),
          const SizedBox(height: 8),
          _buildOrderRow('Total', '${data.montant!.toStringAsFixed(0)} FCFA', total: true, color: const Color(0xFF2563EB)),
          const SizedBox(height: 16),
          _buildPromoField(data),
          const SizedBox(height: 16),
          _buildPayButton(data),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSecurityBadge(Icons.shield_outlined, 'Chiffré SSL'),
              const SizedBox(width: 16),
              _buildSecurityBadge(Icons.check_circle_outline, 'Remboursement garanti'),
            ],
          ),
          if (_isProcessing) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(
              backgroundColor: const Color(0xFFE8ECF2),
              valueColor: AlwaysStoppedAnimation<Color>(
                _selectedMethod == PaymentMethod.orangeMoney
                    ? const Color(0xFFFF6600)
                    : _selectedMethod == PaymentMethod.mtnMoMo
                        ? const Color(0xFFFFCC00)
                        : _selectedMethod == PaymentMethod.wave
                            ? const Color(0xFF1A56DB)
                            : const Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 8),
            Center(child: Text('Traitement du paiement en cours...', style: GoogleFonts.dmSans(fontSize: 12, color: const Color(0xFF64748B)))),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderRow(String label, String value, {bool total = false, bool light = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.dmSans(fontSize: total ? 15 : (light ? 12 : 13), fontWeight: total ? FontWeight.w700 : FontWeight.normal, color: light ? const Color(0xFF64748B) : const Color(0xFF1E293B))),
          Text(value, style: GoogleFonts.sora(fontSize: total ? 15 : 13, fontWeight: total ? FontWeight.w700 : FontWeight.w600, color: color ?? const Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildPromoField(Intervention data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE8ECF2))),
      child: Row(
        children: [
          const Icon(Icons.discount_outlined, size: 16, color: Color(0xFF94A3B8)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _promoController,
              style: GoogleFonts.sora(fontSize: 12, color: const Color(0xFF1E293B)),
              decoration: InputDecoration(
                hintText: 'Code promo',
                hintStyle: GoogleFonts.sora(fontSize: 12, color: const Color(0xFF94A3B8)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final code = _promoController.text.trim();
              if (code.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez entrer un code promo')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Code "$code" invalide')));
              }
            },
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF2563EB), padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: Size.zero),
            child: Text('Appliquer', style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton(Intervention data) {
    final phoneText = _phoneController.text.trim();
    final isPhoneValid = phoneText.length >= 9 && RegExp(r'^\d+$').hasMatch(phoneText);
    final canPay = _selectedMethod != null && (_selectedMethod == PaymentMethod.cash || isPhoneValid);
    final color = _selectedMethod == PaymentMethod.orangeMoney
        ? const Color(0xFFFF6600)
        : _selectedMethod == PaymentMethod.mtnMoMo
            ? const Color(0xFFFFCC00)
            : _selectedMethod == PaymentMethod.wave
                ? const Color(0xFF1A56DB)
                : _selectedMethod == PaymentMethod.cash
                    ? const Color(0xFF10B981)
                    : const Color(0xFF2563EB);

    return PointerCursor(
      child: GestureDetector(
        onTap: _isProcessing ? null : (canPay ? () => _processPayment(data) : null),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 50,
          decoration: BoxDecoration(
            gradient: canPay ? LinearGradient(colors: [color, color.withOpacity(0.85)]) : null,
            color: canPay ? null : const Color(0xFFE8ECF2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: canPay ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))] : [],
          ),
          child: Center(
            child: _isProcessing
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_selectedMethod == PaymentMethod.cash ? Icons.money : Icons.lock, size: 16, color: canPay ? Colors.white : const Color(0xFF94A3B8)),
                      const SizedBox(width: 8),
                      Text(
                        _selectedMethod == PaymentMethod.cash ? 'Confirmer' : 'Payer ${data.montant!.toStringAsFixed(0)} FCFA',
                        style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600, color: canPay ? Colors.white : const Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityBadge(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.dmSans(fontSize: 10, color: const Color(0xFF94A3B8))),
      ],
    );
  }

  Widget _buildActionButton(String label, {required VoidCallback onTap, bool isSecondary = false}) {
    return PointerCursor(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 46,
          constraints: const BoxConstraints(maxWidth: 300),
          decoration: BoxDecoration(
            gradient: isSecondary ? null : const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
            color: isSecondary ? Colors.white : null,
            borderRadius: BorderRadius.circular(12),
            border: isSecondary ? Border.all(color: const Color(0xFFE8ECF2)) : null,
            boxShadow: isSecondary ? [] : [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Center(
            child: Text(label, style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600, color: isSecondary ? const Color(0xFF1E293B) : Colors.white)),
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment(Intervention data) async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _isSuccess = true;
    });
    _successAnimController.forward();
  }
}
