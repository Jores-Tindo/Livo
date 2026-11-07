import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// État "liste vide" ou "erreur" réutilisable : icône, titre, message et
/// action facultative (ex. "Réessayer", "Ajouter").
class EtatVide extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String? message;
  final String? libelleAction;
  final VoidCallback? onAction;

  const EtatVide({
    super.key,
    required this.icone,
    required this.titre,
    this.message,
    this.libelleAction,
    this.onAction,
  });

  /// Variante pour les erreurs de chargement (réseau, serveur).
  const EtatVide.erreur({super.key, required VoidCallback this.onAction})
      : icone = Icons.wifi_off_rounded,
        titre = 'Impossible de charger',
        message = 'Vérifie ta connexion internet puis réessaie.',
        libelleAction = 'Réessayer';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icone, size: 34, color: AppColors.primary),
            ),
            const SizedBox(height: 18),
            Text(titre,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(message!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
            if (libelleAction != null && onAction != null) ...[
              const SizedBox(height: 20),
              OutlinedButton(onPressed: onAction, child: Text(libelleAction!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Indicateur de chargement centré, cohérent d'un écran à l'autre.
class EtatChargement extends StatelessWidget {
  const EtatChargement({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: CircularProgressIndicator(color: AppColors.primary));
  }
}
