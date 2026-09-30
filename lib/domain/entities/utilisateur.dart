/// Rôle d'un utilisateur dans l'application.
enum RoleUtilisateur { client, livreur }

/// Statut d'une candidature livreur.
enum StatutCandidature { nonSoumise, enAttente, valide, refuse, suspendu }

/// Entité pure représentant un utilisateur. Ne contient aucune logique
/// Firebase — elle sera construite/reconstruite par un repository à
/// partir d'un document Firestore, dans lib/data/repositories/.
class Utilisateur {
  final String id;
  final String nom;
  final String telephone;
  final String? email;
  final RoleUtilisateur? role;
  final StatutCandidature statutCandidature;

  const Utilisateur({
    required this.id,
    required this.nom,
    required this.telephone,
    this.email,
    this.role,
    this.statutCandidature = StatutCandidature.nonSoumise,
  });

  /// Un livreur ne peut accéder à l'espace missions que si son
  /// dossier a été validé par l'admin.
  bool get peutAccederEspaceLivreur =>
      role == RoleUtilisateur.livreur &&
      statutCandidature == StatutCandidature.valide;

  Utilisateur copyWith({
    String? nom,
    String? telephone,
    String? email,
    RoleUtilisateur? role,
    StatutCandidature? statutCandidature,
  }) {
    return Utilisateur(
      id: id,
      nom: nom ?? this.nom,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      role: role ?? this.role,
      statutCandidature: statutCandidature ?? this.statutCandidature,
    );
  }
}
