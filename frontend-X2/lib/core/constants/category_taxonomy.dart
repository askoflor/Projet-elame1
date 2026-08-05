import 'package:flutter/material.dart';

/// Sous-categorie = metier precis, c'est la valeur reellement stockee comme
/// `specialite` d'un prestataire (choisie a l'inscription). Chaque sous
/// categorie est rattachee a une categorie principale, utilisee pour le
/// regroupement visuel (page d'accueil, popup de choix).
class SubCategory {
  final String label;
  final String emoji;

  const SubCategory(this.label, this.emoji);
}

class MainCategory {
  final String label;
  final String emoji;
  final Color pastelBg;
  final Color accent;
  final List<SubCategory> sousCategories;

  const MainCategory({
    required this.label,
    required this.emoji,
    required this.pastelBg,
    required this.accent,
    required this.sousCategories,
  });
}

/// Taxonomie categorie -> sous-categories consommee a la fois par la page
/// d'accueil (choix visuel) et par l'inscription prestataire (choix du
/// metier exact, range ensuite par categorie principale pour l'affichage).
class CategoryTaxonomy {
  static const List<MainCategory> categories = [
    MainCategory(
      label: 'Maintenance Maison',
      emoji: '🔧',
      pastelBg: Color(0xFFDBEAFE),
      accent: Color(0xFF2563EB),
      sousCategories: [
        SubCategory('Électricité', '⚡'),
        SubCategory('Plomberie', '🚰'),
        SubCategory('Climatisation', '❄️'),
        SubCategory('Menuiserie', '🪚'),
        SubCategory('Peinture', '🎨'),
        SubCategory('Carrelage', '🧱'),
        SubCategory('Maçonnerie', '🧰'),
        SubCategory('Serrurerie', '🔑'),
      ],
    ),
    MainCategory(
      label: 'Jardinage & Extérieur',
      emoji: '🌿',
      pastelBg: Color(0xFFDCFCE7),
      accent: Color(0xFF16A34A),
      sousCategories: [
        SubCategory('Jardinage', '🌳'),
        SubCategory('Nettoyage extérieur', '🧽'),
        SubCategory('Entretien piscine', '🏊'),
      ],
    ),
    MainCategory(
      label: 'Beauté & Bien-être',
      emoji: '💇',
      pastelBg: Color(0xFFFCE7F3),
      accent: Color(0xFFDB2777),
      sousCategories: [
        SubCategory('Coiffure Homme', '💈'),
        SubCategory('Coiffure Femme', '💇‍♀️'),
        SubCategory('Manucure & Pédicure', '💅'),
        SubCategory('Maquillage', '💄'),
        SubCategory('Massage & Spa', '🧖'),
      ],
    ),
    MainCategory(
      label: 'Nettoyage & Entretien',
      emoji: '🧹',
      pastelBg: Color(0xFFFEF3C7),
      accent: Color(0xFFD97706),
      sousCategories: [
        SubCategory('Ménage à domicile', '🧺'),
        SubCategory('Nettoyage de bureaux', '🏢'),
        SubCategory('Pressing & Blanchisserie', '👔'),
      ],
    ),
    MainCategory(
      label: 'Déménagement & Transport',
      emoji: '🚚',
      pastelBg: Color(0xFFF3E8FF),
      accent: Color(0xFF9333EA),
      sousCategories: [
        SubCategory('Déménagement', '📦'),
        SubCategory('Chauffeur & Livraison', '🚗'),
      ],
    ),
    MainCategory(
      label: 'Informatique & Électronique',
      emoji: '💻',
      pastelBg: Color(0xFFCCFBF1),
      accent: Color(0xFF0D9488),
      sousCategories: [
        SubCategory('Réparation téléphone', '📱'),
        SubCategory('Réparation ordinateur', '💻'),
        SubCategory('Installation réseau & domotique', '📡'),
      ],
    ),
  ];

  /// Toutes les sous-categories, a plat (utilisees a l'inscription).
  static List<SubCategory> get toutesSousCategories =>
      categories.expand((c) => c.sousCategories).toList();

  /// Categorie principale d'une sous-categorie donnee (par son libelle).
  static MainCategory? categorieDe(String sousCategorieLabel) {
    for (final cat in categories) {
      if (cat.sousCategories.any((s) => s.label == sousCategorieLabel)) return cat;
    }
    return null;
  }
}
