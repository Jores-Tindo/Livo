import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/auth/role_selection_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/candidature_livreur_screen.dart';
import '../presentation/screens/auth/candidature_envoyee_screen.dart';
import '../presentation/screens/auth/candidature_en_attente_screen.dart';
import '../presentation/screens/client/client_shell_screen.dart';
import '../presentation/screens/client/nouvelle_mission_screen.dart';
import '../presentation/screens/client/liste_livreurs_screen.dart';
import '../presentation/screens/client/proposition_envoyee_screen.dart';
import '../presentation/screens/livreur/livreur_shell_screen.dart';
import '../presentation/screens/livreur/mission_proposee_screen.dart';
import '../presentation/screens/livreur/mission_en_cours_screen.dart';
import '../presentation/screens/livreur/mon_vehicule_screen.dart';
import '../presentation/screens/livreur/mes_documents_screen.dart';
import '../presentation/screens/livreur/zone_couverture_screen.dart';
import '../presentation/screens/client/mes_adresses_screen.dart';
import '../presentation/screens/client/moyens_paiement_screen.dart';
import '../presentation/screens/client/destinataires_favoris_screen.dart';
import '../presentation/screens/commun/modifier_profil_screen.dart';
import '../presentation/screens/commun/aide_support_screen.dart';

/// Centraliser la navigation ici évite deux problèmes fréquents :
/// 1. Un utilisateur qui accède à un écran livreur alors qu'il est client
///    (ou pire, un compte livreur non validé qui accède aux missions)
/// 2. Des routes dupliquées/incohérentes éparpillées dans les widgets
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/inscription',
    // TODO : une fois Firebase branché, ajouter ici la logique de
    // redirection selon l'état d'authentification :
    //   - non connecté -> /inscription
    //   - role == livreur && statutCandidature != 'valide' -> /candidature-en-attente
    //   - role == client -> /client/accueil
    //   - role == livreur (valide) -> /livreur/accueil
    routes: [
      GoRoute(
        path: '/inscription',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/choix-profil',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/connexion',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/candidature-livreur',
        builder: (context, state) => const CandidatureLivreurScreen(),
      ),
      GoRoute(
        path: '/candidature-envoyee',
        builder: (context, state) => const CandidatureEnvoyeeScreen(),
      ),
      GoRoute(
        path: '/client/accueil',
        builder: (context, state) => const ClientShellScreen(),
      ),
      GoRoute(
        path: '/client/nouvelle-mission',
        builder: (context, state) => const NouvelleMissionScreen(),
      ),
      GoRoute(
        path: '/client/liste-livreurs',
        builder: (context, state) => const ListeLivreursScreen(),
      ),
      GoRoute(
        path: '/client/proposition-envoyee',
        builder: (context, state) {
          final nomLivreur = state.extra as String? ?? 'ce livreur';
          return PropositionEnvoyeeScreen(nomLivreur: nomLivreur);
        },
      ),
      GoRoute(
        path: '/livreur/accueil',
        builder: (context, state) => const LivreurShellScreen(),
      ),
      GoRoute(
        path: '/livreur/mission-proposee',
        builder: (context, state) {
          final donnees = state.extra as Map<String, dynamic>? ?? {};
          return MissionProposeeScreen(
            nomClient: donnees['nomClient'] as String? ?? 'Client',
            adresseDepart: donnees['adresseDepart'] as String? ?? '—',
            adresseArrivee: donnees['adresseArrivee'] as String? ?? '—',
            distanceKm: (donnees['distanceKm'] as num?)?.toDouble() ?? 0,
            montant: donnees['montant'] as int? ?? 0,
            description: donnees['description'] as String? ?? '—',
          );
        },
      ),
      GoRoute(
        path: '/livreur/mission-en-cours',
        builder: (context, state) {
          final donnees = state.extra as Map<String, dynamic>? ?? {};
          return MissionEnCoursScreen(
            nomClient: donnees['nomClient'] as String? ?? 'Client',
            adresseDepart: donnees['adresseDepart'] as String? ?? '—',
            adresseArrivee: donnees['adresseArrivee'] as String? ?? '—',
            montant: donnees['montant'] as int? ?? 0,
            description: donnees['description'] as String? ?? '—',
          );
        },
      ),
      GoRoute(
        path: '/candidature-en-attente',
        builder: (context, state) {
          final statut =
              state.extra as StatutAffichage? ?? StatutAffichage.enAttente;
          return CandidatureEnAttenteScreen(statut: statut);
        },
      ),
      GoRoute(
        path: '/profil/modifier',
        builder: (context, state) => const ModifierProfilScreen(),
      ),
      GoRoute(
        path: '/profil/aide',
        builder: (context, state) => const AideSupportScreen(),
      ),
      GoRoute(
        path: '/livreur/mon-vehicule',
        builder: (context, state) => const MonVehiculeScreen(),
      ),
      GoRoute(
        path: '/livreur/mes-documents',
        builder: (context, state) => const MesDocumentsScreen(),
      ),
      GoRoute(
        path: '/livreur/zone-couverture',
        builder: (context, state) => const ZoneCouvertureScreen(),
      ),
      GoRoute(
        path: '/client/mes-adresses',
        builder: (context, state) => const MesAdressesScreen(),
      ),
      GoRoute(
        path: '/client/moyens-paiement',
        builder: (context, state) => const MoyensPaiementScreen(),
      ),
      GoRoute(
        path: '/client/destinataires-favoris',
        builder: (context, state) => const DestinatairesFavorisScreen(),
      ),
    ],
  );
});
