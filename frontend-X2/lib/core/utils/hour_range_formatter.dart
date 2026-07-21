String _pad2(int h) => (h % 24).toString().padLeft(2, '0');

/// Fusionne une liste d'heures (0-23) en plages consécutives lisibles,
/// ex. [8,9,14,15,16] -> "08h – 09h, 14h – 17h".
String formatHourRanges(List<int> hours) {
  if (hours.isEmpty) return '—';
  final sorted = [...hours]..sort();
  final ranges = <String>[];
  int start = sorted.first;
  int prev = sorted.first;
  for (var i = 1; i <= sorted.length; i++) {
    if (i < sorted.length && sorted[i] == prev + 1) {
      prev = sorted[i];
      continue;
    }
    ranges.add('${_pad2(start)}h – ${_pad2(prev + 1)}h');
    if (i < sorted.length) {
      start = sorted[i];
      prev = sorted[i];
    }
  }
  return ranges.join(', ');
}

/// Libellé de durée estimée pré-rempli dans la modale de chiffrage,
/// à partir du nombre d'heures réservées.
String dureeLabelFromHours(int hourCount) {
  if (hourCount <= 0) return '—';
  if (hourCount <= 3) return '${hourCount}h';
  if (hourCount <= 6) return 'Demi-journée';
  return 'Journée complète';
}
