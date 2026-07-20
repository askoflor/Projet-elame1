import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/localization/translation_provider.dart';
import '../../../../modules/home/presentation/widgets/header/nav_bar.dart';
import '../widgets/filters/filters_panel.dart';
import '../widgets/provider_list/result_card.dart';
import '../widgets/search_bar/search_bar_widget.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../data/models/mock_providers.dart';
import '../../domain/entities/provider_model.dart';

class SearchPage extends StatefulWidget {
  final String? initialCategory;

  const SearchPage({super.key, this.initialCategory});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int selectedIndex = 0;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'Tous';
  }

  List<ProviderModel> get _filteredProviders => mockProviders
      .where((p) => _matchesCategory(p, _selectedCategory))
      .toList();

  bool _matchesCategory(ProviderModel provider, String category) {
    if (category == 'Tous') return true;
    final s = provider.specialty.toLowerCase();
    switch (category) {
      case 'Électricité':
        return s.contains('électricien');
      case 'Plomberie':
        return s.contains('plomb');
      case 'Climatisation':
        return s.contains('clim') || s.contains('frigoriste');
      case 'Carrelage':
        return s.contains('carrel');
      case 'Maintenance':
        return s.contains('maintenance');
      case 'Jardinage':
        return s.contains('jardin');
      case 'Peinture':
        return s.contains('peintre') || s.contains('peinture');
      case 'Menuiserie':
        return s.contains('menuis');
      default:
        return true;
    }
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
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildBackButton(),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SearchBarWidget(),
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(height: 1, color: Color(0xFFE8ECF2)),
                    ),
                    const SizedBox(height: 16),
                    _buildSearchPage(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchPage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        if (isMobile) {
          return Column(
            children: [
              _buildFiltersPanel(),
              const SizedBox(height: 16),
              _buildResultsList(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFiltersPanel(),
            const SizedBox(width: 20),
            Expanded(child: _buildResultsList()),
          ],
        );
      },
    );
  }

  Widget _buildFiltersPanel() {
    return FiltersPanel(
      initialCategory: _selectedCategory,
      onCategoryChanged: (category) {
        setState(() {
          _selectedCategory = category;
          selectedIndex = 0;
        });
      },
    );
  }

  Widget _buildResultsList() {
    final providers = _filteredProviders;

    if (providers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            _buildResultsHeader(),
            const SizedBox(height: 40),
            Text(
              'Aucun prestataire trouvé pour cette catégorie',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          _buildResultsHeader(),
          const SizedBox(height: 12),
          ...providers.asMap().entries.map((entry) {
            final provider = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ResultCard(
                isCertified: provider.isCertified,
                initials: provider.initials,
                name: provider.name,
                specialty: provider.specialty,
                location: provider.location,
                interventions: provider.interventions,
                isAvailable: provider.isAvailable,
                tags: provider.tags,
                rating: provider.rating,
                reviewCount: provider.reviewCount,
                price: provider.price,
                avatarColor: provider.avatarColor,
                avatarBgColor: provider.avatarBgColor,
                isSelected: selectedIndex == entry.key,
                onTap: () {
                  setState(() => selectedIndex = entry.key);
                  context.push('/profil', extra: provider);
                },
                onReserve: () => context.push('/reservation', extra: provider),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: AppBackButton(),
    );
  }

  Widget _buildResultsHeader() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${_filteredProviders.length * 15} ' + context.tr('search.resultsCount').trim() + ' ',
            style: GoogleFonts.sora(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          TextSpan(
            text: context.tr('search.resultsLocation'),
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
