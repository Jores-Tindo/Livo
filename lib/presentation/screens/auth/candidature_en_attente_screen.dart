import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

/// Écran affiché quand un utilisateur avec le rôle "livreur" essaie
/// d'accéder à son espace mais que sa candidature n'est pas encore
/// `valide` (voir domain/entities/utilisateur.dart — StatutCandidature,
/// et `peutAccederEspaceLivreur`). Gère les trois statuts non-finaux
/// côté accès : enAttente, refuse, suspendu.
///
/// TODO une fois Firebase branché : cet écran doit écouter en temps réel
/// le doc candidatures/{userId} (Firestore listener) et rediriger
/// automatiquement vers /livreur/accueil dès que statut passe à 'valide',
/// sans que l'utilisateur ait à relancer l'app.
class CandidatureEnAttenteScreen extends StatelessWidget {
  final StatutAffichage statut;
  final String? motifRefus;

  const CandidatureEnAttenteScreen({
    super.key,
    this.statut = StatutAffichage.enAttente,
    this.motifRefus,
  });

  @override
  Widget build(BuildContext context) {
    final config = _configurationPour(statut, motifRefus);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                builder: (context, valeur, enfant) =>
                    Transform.scale(scale: valeur, child: enfant),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: config.couleur.withValues(alpha: 0.12),
                  ),
                  child: Icon(config.icone, size: 64, color: config.couleur),
                ),
              ),
              const SizedBox(height: 32),

              Text(
                config.titre,
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                config.message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // --- Carte de statut ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: config.couleur.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(config.iconeStatut,
                              color: config.couleur, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Statut',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 2),
                              Text(config.libelleStatut,
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (config.detail != null) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(color: AppColors.border, height: 1),
                      ),
                      Row(
                        children: [
                          Icon(config.iconeDetail,
                              color: AppColors.textSecondary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(config.detail!,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => context.go('/inscription'),
                  child: const Text('Retour à l\'accueil'),
                ),
              ),

              if (statut == StatutAffichage.refuse ||
                  statut == StatutAffichage.suspendu) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    // TODO : brancher sur un vrai canal de contact support
                    // (WhatsApp Business, email, ou écran de ticket interne).
                    debugPrint('Contacter le support');
                  },
                  child: const Text('Contacter le support'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  _ConfigStatut _configurationPour(StatutAffichage statut, String? motifRefus) {
    switch (statut) {
      case StatutAffichage.enAttente:
        return _ConfigStatut(
          icone: Icons.hourglass_top_rounded,
          couleur: AppColors.statutEnAttente,
          titre: 'Candidature en cours d\'examen',
          message:
              'On vérifie ton dossier. Tu seras notifié dès qu\'une décision sera prise.',
          libelleStatut: 'En attente de validation',
          iconeStatut: Icons.hourglass_top_rounded,
          iconeDetail: Icons.notifications_active_outlined,
          detail:
              'Tu recevras une notification dès que ton dossier sera examiné, sous 48h.',
        );
      case StatutAffichage.refuse:
        return _ConfigStatut(
          icone: Icons.cancel_rounded,
          couleur: AppColors.danger,
          titre: 'Candidature non retenue',
          message: 'Ton dossier n\'a pas pu être validé cette fois-ci.',
          libelleStatut: 'Refusée',
          iconeStatut: Icons.cancel_rounded,
          iconeDetail: Icons.info_outline_rounded,
          detail: motifRefus ??
              'Aucun motif détaillé n\'a été fourni. Contacte le support pour en savoir plus.',
        );
      case StatutAffichage.suspendu:
        return _ConfigStatut(
          icone: Icons.pause_circle_filled_rounded,
          couleur: AppColors.warning,
          titre: 'Compte suspendu',
          message:
              'Ton accès à l\'espace livreur a été temporairement suspendu.',
          libelleStatut: 'Suspendu',
          iconeStatut: Icons.pause_circle_filled_rounded,
          iconeDetail: Icons.info_outline_rounded,
          detail: motifRefus ??
              'Contacte le support pour connaître le motif et la marche à suivre.',
        );
    }
  }
}

enum StatutAffichage { enAttente, refuse, suspendu }

class _ConfigStatut {
  final IconData icone;
  final Color couleur;
  final String titre;
  final String message;
  final String libelleStatut;
  final IconData iconeStatut;
  final IconData iconeDetail;
  final String? detail;

  const _ConfigStatut({
    required this.icone,
    required this.couleur,
    required this.titre,
    required this.message,
    required this.libelleStatut,
    required this.iconeStatut,
    required this.iconeDetail,
    this.detail,
  });
}
