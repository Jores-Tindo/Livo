import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/auth/role_selection_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/candidature_livreur_screen.dart';
import '../presentation/screens/auth/candidature_envoyee_screen.dart';
import '../presentation/screens/client/client_shell_screen.dart';
import '../presentation/screens/client/nouvelle_mission_screen.dart';

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
      // Prochaines routes à ajouter au fur et à mesure des écrans :
      // GoRoute(path: '/candidature-livreur', builder: ...),
      // GoRoute(path: '/candidature-en-attente', builder: ...),
      // GoRoute(path: '/client/accueil', builder: ...),
      // GoRoute(path: '/livreur/accueil', builder: ...),
    ],
  );
});
