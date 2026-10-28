/// Filtres transmis a la page de recherche depuis le popup de filtre
/// (categorie/sous-categorie + date de disponibilite + quartier) affiche sur
/// la page d'accueil.
class SearchEntryArgs {
  final String? specialite;
  final DateTime? date;
  final String? quartier;

  const SearchEntryArgs({this.specialite, this.date, this.quartier});
}
