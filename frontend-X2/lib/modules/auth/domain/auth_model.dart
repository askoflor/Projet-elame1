class UserModel {
  final String id;
  final String email;
  final String nom;
  final String prenom;
  final String role;
  final String? telephone;
  final String? specialite;
  final DateTime? dateNaissance;
  final String? quartier;
  final String? photoUrl;
  final bool emailVerified;
  final bool certifie;

  const UserModel({
    required this.id,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.role,
    this.telephone,
    this.specialite,
    this.dateNaissance,
    this.quartier,
    this.photoUrl,
    this.emailVerified = false,
    this.certifie = false,
  });

  UserModel copyWith({String? nom, String? prenom, String? telephone, String? quartier, String? photoUrl}) => UserModel(
        id: id,
        email: email,
        nom: nom ?? this.nom,
        prenom: prenom ?? this.prenom,
        role: role,
        telephone: telephone ?? this.telephone,
        specialite: specialite,
        dateNaissance: dateNaissance,
        quartier: quartier ?? this.quartier,
        photoUrl: photoUrl ?? this.photoUrl,
        emailVerified: emailVerified,
        certifie: certifie,
      );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? '',
        email: json['email'] ?? '',
        nom: json['nom'] ?? '',
        prenom: json['prenom'] ?? '',
        role: json['role'] ?? 'USER',
        telephone: json['telephone'] as String?,
        specialite: json['specialite'] as String?,
        dateNaissance: _parseDate(json['dateNaissance']),
        quartier: json['quartier'] as String?,
        photoUrl: json['photoUrl'] as String?,
        emailVerified: json['emailVerified'] as bool? ?? false,
        certifie: json['certifie'] as bool? ?? false,
      );

  /// Tolerant a plusieurs representations possibles d'une date renvoyee par
  /// le backend (chaine ISO "2000-01-31", ou tableau [annee, mois, jour] si
  /// jamais la serialisation Jackson cote serveur change), pour ne jamais
  /// faire echouer tout le parsing de l'utilisateur sur ce seul champ.
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    if (value is List && value.length >= 3) {
      final y = value[0] as int?;
      final m = value[1] as int?;
      final d = value[2] as int?;
      if (y != null && m != null && d != null) return DateTime(y, m, d);
    }
    return null;
  }
}

class AuthResult {
  final bool success;
  final String? token;
  final UserModel? user;
  final String? errorMessage;

  const AuthResult({
    required this.success,
    this.token,
    this.user,
    this.errorMessage,
  });
}
