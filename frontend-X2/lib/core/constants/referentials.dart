/// Référentiels métiers/villes/services partagés par toute l'application.
/// Les métiers et villes sont toujours choisis via liste déroulante, jamais en texte libre.
class Referentials {
  static const List<String> metiers = [
    'Électricien',
    'Plombier',
    'Frigoriste / Climatisation',
    'Carreleur',
    'Peintre en bâtiment',
    'Menuisier',
    'Maçon',
    'Soudeur / Métallier',
    'Mécanicien',
    'Technicien de maintenance',
    'Vitrier',
    'Technicien réseau & domotique',
    'Jardinier / Paysagiste',
    'Agent de nettoyage',
  ];

  // Extensible : d'autres villes camerounaises pourront être ajoutées ici.
  static const List<String> villes = [
    'Douala',
    'Yaoundé',
    'Bafoussam',
    'Bamenda',
    'Garoua',
    'Maroua',
    'Ngaoundéré',
    'Bertoua',
    'Buea',
    'Limbe',
    'Kribi',
    'Édéa',
    'Kumba',
    'Ebolowa',
    'Dschang',
    'Foumban',
  ];

  static const List<String> services = [
    'Électricité',
    'Plomberie',
    'Climatisation',
    'Maintenance',
    'Carrelage',
    'Peinture',
  ];

  /// Le service d'une intervention est toujours déduit du métier du prestataire,
  /// jamais choisi librement par le client.
  static String serviceFromMetier(String metier) {
    final m = metier.toLowerCase();
    if (m.contains('électricien')) return 'Électricité';
    if (m.contains('plombier')) return 'Plomberie';
    if (m.contains('frigoriste') || m.contains('climatisation')) return 'Climatisation';
    if (m.contains('carreleur')) return 'Carrelage';
    if (m.contains('peintre')) return 'Peinture';
    return 'Maintenance';
  }
}
