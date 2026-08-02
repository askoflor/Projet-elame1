/// Tolerant a plusieurs representations possibles d'une date/heure renvoyee
/// par le backend (chaine ISO, ou tableau [annee, mois, jour, ...] selon la
/// configuration de serialisation Jackson cote serveur).
DateTime? parseFlexibleDate(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  if (value is List && value.length >= 3) {
    final parts = value.map((e) => e is int ? e : int.tryParse('$e') ?? 0).toList();
    return DateTime(
      parts[0],
      parts[1],
      parts[2],
      parts.length > 3 ? parts[3] : 0,
      parts.length > 4 ? parts[4] : 0,
      parts.length > 5 ? parts[5] : 0,
    );
  }
  return null;
}
