/// Filtres transmis a la page de recherche depuis le popup de filtre
/// (categorie/sous-categorie + date de disponibilite) affiche sur la page
/// d'accueil.
class SearchEntryArgs {
  final String? specialite;
  final DateTime? date;

  const SearchEntryArgs({this.specialite, this.date});
}
