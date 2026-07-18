class UserModel {
  final String id;
  final String email;
  final String nom;
  final String prenom;
  final String role;
  final String? specialite;
  final DateTime? dateNaissance;

  const UserModel({
    required this.id,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.role,
    this.specialite,
    this.dateNaissance,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id']?.toString() ?? '',
        email: json['email'] ?? '',
        nom: json['nom'] ?? '',
        prenom: json['prenom'] ?? '',
        role: json['role'] ?? 'USER',
        specialite: json['specialite'] as String?,
        dateNaissance: json['dateNaissance'] != null
            ? DateTime.tryParse(json['dateNaissance'] as String)
            : null,
      );
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