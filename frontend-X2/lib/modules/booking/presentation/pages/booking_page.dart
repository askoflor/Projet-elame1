import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/localization/translation_provider.dart';
import '../../../../core/widgets/micro_interactions.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/hour_slot_grid.dart';
import '../../../../core/utils/hour_range_formatter.dart';
import '../../../../core/constants/referentials.dart';
import '../../../../modules/home/presentation/widgets/header/nav_bar.dart';
import '../../../intervention/state/intervention_provider.dart';
import '../../../search/domain/entities/provider_model.dart';

class BookingPage extends StatefulWidget {
  final ProviderModel? provider;
  final DateTime? initialDate;
  final List<int>? initialHours;

  const BookingPage({super.key, this.provider, this.initialDate, this.initialHours});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  // 0 = Service, 1 = Description, 2 = Date & Heure. Le client atterrit
  // directement à l'étape 1 : le service est déduit du métier du
  // prestataire, l'étape 0 reste accessible pour correction.
  int _currentStep = 1;
  int _selectedService = 0;
  int _selectedUrgency = 0;
  late DateTime _selectedDate;
  List<int> _selectedHours = [];
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    if (widget.initialHours != null) _selectedHours = List.of(widget.initialHours!);
    if (widget.provider != null) {
      final service = Referentials.serviceFromMetier(widget.provider!.specialty);
      final index = Referentials.services.indexOf(service);
      _selectedService = index >= 0 ? index : 0;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<InterventionProvider>().chargerPlanning(_providerName);
    });
  }

  static const _serviceKeys = [
    'booking.electricite',
    'booking.plomberie',
    'booking.climatisation',
    'booking.maintenance',
    'booking.carrelage',
    'booking.peinture',
  ];

  final List<Map<String, dynamic>> _services = const [
    {'icon': Icons.bolt, 'color': Color(0xFFD97706), 'bg': Color(0xFFFFFBEB)},
    {'icon': Icons.water_drop, 'color': Color(0xFF2563EB), 'bg': Color(0xFFEFF6FF)},
    {'icon': Icons.air, 'color': Color(0xFF0D9488), 'bg': Color(0xFFF0FDFA)},
    {'icon': Icons.build, 'color': Color(0xFF7C3AED), 'bg': Color(0xFFF5F3FF)},
    {'icon': Icons.grid_on, 'color': Color(0xFFF97316), 'bg': Color(0xFFFFF7ED)},
    {'icon': Icons.brush, 'color': Color(0xFFDB2777), 'bg': Color(0xFFFDF2F8)},
  ];

  Color get _currentServiceColor => _services[_selectedService]['color'] as Color;

  static const _urgencyKeys = ['booking.urgencePlanifie', 'booking.urgenceUrgent', 'booking.urgenceTresUrgent'];
  static const _urgencyLabels = ['Planifié', 'Urgent', 'Très urgent'];

  static const _stepLabelKeys = ['booking.stepService', 'booking.stepDescription', 'booking.stepDateTime'];

  String get _providerName => widget.provider?.name ?? 'Kofi Mensah';
  String get _providerInitials => widget.provider?.initials ?? 'KM';
  String get _providerSpecialty => widget.provider?.specialty ?? 'Électricien';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
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
                      const Align(alignment: Alignment.centerLeft, child: AppBackButton()),
                      const SizedBox(height: 12),
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildPageContent(),
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

  Widget _buildHeader() {
    final serviceColor = _currentServiceColor;
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [serviceColor, serviceColor.withOpacity(0.8)]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.book_online_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr('booking.headerTitle'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'Sora', color: Color(0xFF1E293B))),
            const SizedBox(height: 2),
            Text(context.tr('booking.headerSubtitle'),
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontFamily: 'DM Sans')),
          ],
        ),
      ],
    );
  }

  Widget _buildPageContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isStacked = constraints.maxWidth < 768;
        if (isStacked) {
          return Column(
            children: [_buildWizardCard(), const SizedBox(height: 16), _buildOrderSummary()],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildWizardCard()),
            const SizedBox(width: 20),
            SizedBox(width: 340, child: _buildOrderSummary()),
          ],
        );
      },
    );
  }

  Widget _buildWizardCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE8ECF2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(),
          const SizedBox(height: 20),
          _buildStepContent(),
          const SizedBox(height: 20),
          _buildStepNavigation(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final serviceColor = _currentServiceColor;
    return Row(
      children: List.generate(_stepLabelKeys.length, (i) {
        final isDone = i < _currentStep;
        final isActive = i == _currentStep;
        return Expanded(
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isDone ? const Color(0xFF10B981) : (isActive ? serviceColor : const Color(0xFFE8ECF2)),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, color: Colors.white, size: 12)
                      : Text('${i + 1}',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isActive ? Colors.white : const Color(0xFF64748B))),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr(_stepLabelKeys[i]),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isActive ? serviceColor : (isDone ? const Color(0xFF10B981) : const Color(0xFF64748B)),
                  fontFamily: 'Sora',
                ),
              ),
              if (i < _stepLabelKeys.length - 1)
                Container(
                  height: 1.5,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(1), color: isDone ? const Color(0xFF10B981) : const Color(0xFFE8ECF2)),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildServiceStep();
      case 1:
        return _buildDescriptionStep();
      case 2:
        return _buildDateTimeStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildServiceStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr('booking.serviceTitle'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Sora')),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.8),
          itemCount: _services.length,
          itemBuilder: (context, index) {
            final isSelected = _selectedService == index;
            final service = _services[index];
            final color = service['color'] as Color;
            final bg = service['bg'] as Color;
            return PointerCursor(
              child: GestureDetector(
                onTap: () => setState(() => _selectedService = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? bg : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? color : const Color(0xFFE8ECF2), width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(service['icon'] as IconData, color: isSelected ? color : const Color(0xFF94A3B8), size: 24),
                      const SizedBox(height: 8),
                      Text(
                        context.tr(_serviceKeys[index]),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? color : const Color(0xFF64748B), fontFamily: 'Sora'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr('booking.descTitle'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Sora')),
        const SizedBox(height: 16),
        _buildFormField(context.tr('booking.titleLabel'), _titleController, placeholder: context.tr('booking.titlePlaceholder')),
        const SizedBox(height: 16),
        _buildFormField(context.tr('booking.descLabel'), _descriptionController, placeholder: context.tr('booking.descPlaceholder'), maxLines: 4),
        const SizedBox(height: 16),
        Text(context.tr('booking.urgenceLabel'),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B), letterSpacing: 0.3, fontFamily: 'Sora')),
        const SizedBox(height: 10),
        Row(
          children: List.generate(_urgencyKeys.length, (i) {
            final isSelected = _selectedUrgency == i;
            const urgencyColors = [Color(0xFF10B981), Color(0xFFD97706), Color(0xFFEF4444)];
            const urgencyBgs = [Color(0xFFF0FDF4), Color(0xFFFFFBEB), Color(0xFFFEF2F2)];
            final color = urgencyColors[i];
            final bg = urgencyBgs[i];
            return Padding(
              padding: EdgeInsets.only(right: i < _urgencyKeys.length - 1 ? 6 : 0),
              child: PointerCursor(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedUrgency = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected ? bg : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: isSelected ? color : const Color(0xFFE8ECF2)),
                    ),
                    child: Text(context.tr(_urgencyKeys[i]),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? color : const Color(0xFF64748B), fontFamily: 'Sora')),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDateTimeStep() {
    final interventions = context.watch<InterventionProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr('booking.dateTimeTitle'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Sora')),
        const SizedBox(height: 20),
        _buildDateField(),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(context.tr('booking.slotsLabel'),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B), letterSpacing: 0.3, fontFamily: 'Sora')),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(20)),
              child: const Text('24h/24', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF059669))),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text('Les heures choisies sur le profil sont déjà sélectionnées. Cliquez pour en ajouter ou en retirer.',
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontFamily: 'DM Sans')),
        const SizedBox(height: 10),
        HourSlotGrid(
          selectedHours: _selectedHours,
          bookedHours: interventions.hoursBookedFor(_providerName, _selectedDate),
          onChanged: (hours) => setState(() => _selectedHours = hours),
        ),
        const SizedBox(height: 16),
        _buildFormField(context.tr('booking.addressLabel'), _addressController, placeholder: context.tr('booking.addressPlaceholder')),
      ],
    );
  }

  Widget _buildDateField() {
    final months = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
    final displayDate = '${_selectedDate.day} ${months[_selectedDate.month - 1]} ${_selectedDate.year}';
    final serviceColor = _currentServiceColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr('booking.dateLabel').toUpperCase(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B), letterSpacing: 0.3, fontFamily: 'Sora')),
        const SizedBox(height: 6),
        PointerCursor(
          child: GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: serviceColor, onPrimary: Colors.white)),
                    child: child!,
                  );
                },
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE8ECF2), width: 1.5), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Expanded(child: Text(displayDate, style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B), fontFamily: 'Sora'))),
                  Icon(Icons.calendar_today, color: serviceColor, size: 16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField(String label, TextEditingController controller, {String? placeholder, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B), letterSpacing: 0.3, fontFamily: 'Sora')),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE8ECF2), width: 1.5), borderRadius: BorderRadius.circular(8)),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B), fontFamily: 'Sora'),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontFamily: 'Sora'),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: maxLines > 1 ? 12 : 10),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmReservation() async {
    if (_selectedHours.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('booking.selectionnezHeure'))),
      );
      setState(() => _currentStep = 2);
      return;
    }
    final intervention = await context.read<InterventionProvider>().creer(
          providerName: _providerName,
          service: Referentials.services[_selectedService],
          titre: _titleController.text.trim().isEmpty
              ? '${context.tr('booking.interventionPrefix')} ${context.tr(_serviceKeys[_selectedService])}'
              : _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          date: _selectedDate,
          heures: _selectedHours,
          urgence: _urgencyLabels[_selectedUrgency],
          adresse: _addressController.text.trim().isEmpty ? context.tr('booking.adresseNonSpecifiee') : _addressController.text.trim(),
        );
    if (!mounted) return;
    if (intervention == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('booking.echecCreation'))),
      );
      return;
    }
    context.go('/espace-client');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${context.tr('booking.interventionCreeePrefix')} ${intervention.reference} ${context.tr('booking.interventionCreeeSuffix')}')),
    );
  }

  Widget _buildStepNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > 0)
          _buildNavButton(context.tr('booking.precedent'), isPrimary: false, onTap: () => setState(() => _currentStep--))
        else
          const SizedBox(),
        _buildNavButton(
          _currentStep == _stepLabelKeys.length - 1 ? context.tr('booking.confirmer') : context.tr('booking.continuer'),
          isPrimary: true,
          onTap: () {
            if (_currentStep < _stepLabelKeys.length - 1) {
              setState(() => _currentStep++);
            } else {
              _confirmReservation();
            }
          },
        ),
      ],
    );
  }

  Widget _buildNavButton(String label, {required bool isPrimary, required VoidCallback onTap}) {
    final serviceColor = _currentServiceColor;
    final bgColor = isPrimary ? serviceColor : Colors.transparent;
    final textColor = isPrimary ? Colors.white : serviceColor;
    final borderColor = isPrimary ? null : const Color(0xFFE8ECF2);
    return PointerCursor(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8), border: borderColor != null ? Border.all(color: borderColor) : null),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isPrimary) ...[Icon(Icons.arrow_back, size: 14, color: serviceColor), const SizedBox(width: 6)],
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor, fontFamily: 'Sora')),
              if (isPrimary) ...[const SizedBox(width: 6), const Icon(Icons.arrow_forward, size: 14, color: Colors.white)],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    final serviceColor = _currentServiceColor;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE8ECF2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('booking.summaryTitle'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Sora')),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: serviceColor.withOpacity(0.06), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: serviceColor.withOpacity(0.2), shape: BoxShape.circle),
                  child: Center(
                    child: Text(_providerInitials, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: serviceColor, fontFamily: 'Sora')),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_providerName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Sora')),
                    Text('$_providerSpecialty · ⭐ ${widget.provider?.rating.toStringAsFixed(1) ?? '4.9'}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontFamily: 'DM Sans')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildOrderRow(context.tr('booking.serviceLabel'), context.tr(_serviceKeys[_selectedService]), valueColor: serviceColor),
          _buildOrderRow(context.tr('booking.dateLabel'),
              '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}'),
          _buildOrderRow('Créneaux', formatHourRanges(_selectedHours)),
          _buildOrderRow(context.tr('booking.dureeLabel'), _selectedHours.isEmpty ? '—' : '${_selectedHours.length}h'),
          _buildOrderRow('Urgence', _urgencyLabels[_selectedUrgency]),
          const Divider(height: 24, color: Color(0xFFE8ECF2)),
          Text(
            'Montant à définir par le prestataire après échange téléphonique',
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontFamily: 'DM Sans', fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: serviceColor.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: serviceColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Aucun paiement n\'est demandé à cette étape. Le prestataire vous appellera pour convenir des modalités et fixer le montant.',
                    style: TextStyle(fontSize: 11, color: serviceColor, fontFamily: 'DM Sans'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderRow(String label, String value, {bool isTotal = false, Color? valueColor, Color? labelColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isTotal ? 15 : 13,
                  fontWeight: isTotal ? FontWeight.w700 : FontWeight.normal,
                  color: labelColor ?? const Color(0xFF1E293B),
                  fontFamily: isTotal ? 'Sora' : 'DM Sans')),
          Text(value,
              style: TextStyle(
                  fontSize: isTotal ? 15 : 13,
                  fontWeight: isTotal ? FontWeight.w700 : FontWeight.normal,
                  color: valueColor ?? const Color(0xFF1E293B),
                  fontFamily: isTotal ? 'Sora' : 'DM Sans')),
        ],
      ),
    );
  }
}
