import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/localization/translation_provider.dart';
import '../../../../modules/home/presentation/widgets/header/nav_bar.dart';
import '../widgets/filters/filters_panel.dart';
import '../widgets/provider_list/result_card.dart';
import '../../data/search_repository.dart';
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
  String? _selectedQuartier;
  final _repository = SearchRepository();
  List<ProviderModel> _providers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'Tous';
    _rechercher();
  }

  Future<void> _rechercher() async {
    setState(() => _loading = true);
    final results = await _repository.rechercherPrestataires(
      specialite: _selectedCategory == 'Tous' ? null : _selectedCategory,
      quartier: _selectedQuartier,
    );
    if (!mounted) return;
    setState(() {
      _providers = results;
      _loading = false;
      selectedIndex = 0;
    });
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
                      _buildSearchPage(),
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
            SizedBox(width: 300, child: _buildFiltersPanel()),
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
      initialQuartier: _selectedQuartier,
      onCategoryChanged: (category) {
        setState(() => _selectedCategory = category);
        _rechercher();
      },
      onQuartierChanged: (quartier) {
        setState(() => _selectedQuartier = quartier);
        _rechercher();
      },
    );
  }

  Widget _buildResultsList() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final providers = _providers;

    if (providers.isEmpty) {
      return Column(
        children: [
          _buildResultsHeader(),
          const SizedBox(height: 40),
          Text(
            context.tr('search.aucunResultat'),
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      );
    }

    return Column(
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
              photoUrl: provider.photoUrl,
              isSelected: selectedIndex == entry.key,
              onTap: () {
                setState(() => selectedIndex = entry.key);
                context.push('/profil', extra: provider);
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildResultsHeader() {
    return Text(
      context.tr('search.resultsHeaderNoCount'),
      style: GoogleFonts.sora(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1E293B),
      ),
    );
  }
}
