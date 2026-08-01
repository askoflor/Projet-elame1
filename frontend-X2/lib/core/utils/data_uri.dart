import 'dart:convert';
import 'dart:typed_data';

/// Decode une image encodee en data URI ("data:image/jpeg;base64,...") ou en
/// simple chaine base64. Retourne null si la valeur est absente ou invalide.
Uint8List? decodeDataUri(String? dataUri) {
  if (dataUri == null || dataUri.isEmpty) return null;
  try {
    final base64Part = dataUri.contains(',') ? dataUri.split(',').last : dataUri;
    return base64Decode(base64Part);
  } catch (_) {
    return null;
  }
}
