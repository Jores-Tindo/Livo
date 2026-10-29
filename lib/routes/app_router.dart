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
import '../presentation/screens/client/detail_mission_screen.dart';
import '../presentation/screens/client/suivi_livraison_screen.dart';
import '../presentation/screens/client/paiement_screen.dart';
import '../presentation/screens/client/notation_screen.dart';
import '../presentation/screens/commun/modifier_profil_screen.dart';
import '../presentation/screens/commun/aide_support_screen.dart';
import '../presentation/screens/commun/notifications_screen.dart';
import '../presentation/screens/commun/parametres_screen.dart';
import '../presentation/screens/commun/suivi_destinataire_screen.dart';
import '../presentation/screens/onboarding/splash_screen.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../domain/entities/utilisateur.dart';
import '../presentation/screens/livreur/confirmation_livraison_screen.dart';
import '../presentation/screens/livreur/retrait_screen.dart';
import '../presentation/screens/auth/mot_de_passe_oublie_screen.dart';
import '../presentation/screens/auth/verification_otp_screen.dart';
import '../presentation/screens/auth/nouveau_mot_de_passe_screen.dart';

/// Centraliser la navigation ici évite deux problèmes fréquents :
/// 1. Un utilisateur qui accède à un écran livreur alors qu'il est client
///    (ou pire, un compte livreur non validé qui accède aux missions)
/// 2. Des routes dupliquées/incohérentes éparpillées dans les widgets
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
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
      GoRoute(
        path: '/client/suivi',
        builder: (context, state) {
          final donnees = state.extra as Map<String, dynamic>? ?? {};
          return SuiviLivraisonScreen(
            nomLivreur: donnees['nomLivreur'] as String? ?? 'Livreur',
            adresseDepart: donnees['adresseDepart'] as String? ?? '—',
            adresseArrivee: donnees['adresseArrivee'] as String? ?? '—',
            montant: donnees['montant'] as int? ?? 0,
          );
        },
      ),
      GoRoute(
        path: '/client/paiement',
        builder: (context, state) {
          final donnees = state.extra as Map<String, dynamic>? ?? {};
          return PaiementScreen(
            nomLivreur: donnees['nomLivreur'] as String? ?? 'Livreur',
            montant: donnees['montant'] as int? ?? 0,
          );
        },
      ),
      GoRoute(
        path: '/client/notation',
        builder: (context, state) {
          final nomLivreur = state.extra as String? ?? 'ton livreur';
          return NotationScreen(nomLivreur: nomLivreur);
        },
      ),
      GoRoute(
        path: '/client/detail-mission',
        builder: (context, state) {
          final donnees = state.extra as Map<String, dynamic>? ?? {};
          return DetailMissionScreen(
            nomLivreur: donnees['nomLivreur'] as String? ?? '—',
            adresseDepart: donnees['adresseDepart'] as String? ?? '—',
            adresseArrivee: donnees['adresseArrivee'] as String? ?? '—',
            date: DateTime.tryParse(donnees['date'] as String? ?? '') ??
                DateTime.now(),
            montant: donnees['montant'] as int? ?? 0,
            statut: donnees['statut'] as String? ?? 'livree',
          );
        },
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/parametres',
        builder: (context, state) => const ParametresScreen(),
      ),
      GoRoute(
        path: '/suivi-destinataire',
        builder: (context, state) {
          final d = state.extra as Map<String, dynamic>? ?? {};
          return SuiviDestinataireScreen(
            nomLivreur: d['nomLivreur'] as String? ?? 'ton livreur',
            etape: d['etape'] as int? ?? 1,
          );
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) {
          final role =
              state.extra as RoleUtilisateur? ?? RoleUtilisateur.client;
          return NotificationsScreen(role: role);
        },
      ),
      GoRoute(
        path: '/livreur/confirmation-livraison',
        builder: (context, state) => const ConfirmationLivraisonScreen(),
      ),
      GoRoute(
        path: '/livreur/retrait',
        builder: (context, state) =>
            RetraitScreen(solde: state.extra as int? ?? 0),
      ),
      GoRoute(
        path: '/mot-de-passe-oublie',
        builder: (context, state) => const MotDePasseOublieScreen(),
      ),
      GoRoute(
        path: '/verification-otp',
        builder: (context, state) {
          final d = state.extra as Map<String, dynamic>? ?? {};
          return VerificationOtpScreen(
            telephone: d['telephone'] as String? ?? '',
            suite: d['suite'] as String? ?? 'inscription',
          );
        },
      ),
      GoRoute(
        path: '/nouveau-mot-de-passe',
        builder: (context, state) => const NouveauMotDePasseScreen(),
      ),
    ],
  );
});
