import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

/// Écran affiché juste après la soumission du formulaire de candidature
/// livreur. Pas de formulaire ici — juste une confirmation rassurante
/// et un rappel du délai de traitement (voir cahier des charges 2.2).
class CandidatureEnvoyeeScreen extends StatelessWidget {
  const CandidatureEnvoyeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- Icône de succès animée ---
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                builder: (context, valeur, enfant) {
                  return Transform.scale(scale: valeur, child: enfant);
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success.withValues(alpha: 0.12),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 72,
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Candidature envoyée !',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Text(
                'Ton dossier est entre de bonnes mains. On revient vers toi très vite.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // --- Carte récapitulative du délai/statut ---
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
                            color: AppColors.statutEnAttente
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.hourglass_top_rounded,
                              color: AppColors.statutEnAttente, size: 22),
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
                              Text(
                                'En attente de validation',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(color: AppColors.border, height: 1),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.notifications_active_outlined,
                            color: AppColors.textSecondary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Tu recevras une notification dès que ton dossier sera examiné, sous 48h.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
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
              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  // TODO : une fois Firebase branché, permettre de relire
                  // son propre statut de candidature en direct (Firestore
                  // listener sur candidatures/{userId})
                  debugPrint('Suivre ma candidature');
                },
                child: const Text('Suivre ma candidature'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
