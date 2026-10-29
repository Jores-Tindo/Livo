import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Détail d'une mission passée ou en cours, ouvert depuis la liste
/// "Mes missions". Reçoit les données via `extra` (Map) depuis
/// mes_missions_screen.dart.
///
/// TODO une fois Firebase branché : charger le doc missions/{id} complet
/// (avec sous-collection d'événements pour la timeline), et pour une
/// mission en cours, écouter la position du livreur en temps réel sur
/// une carte plutôt que d'afficher une timeline statique.
class DetailMissionScreen extends StatelessWidget {
  final String nomLivreur;
  final String adresseDepart;
  final String adresseArrivee;
  final DateTime date;
  final int montant;
  final String statut;

  const DetailMissionScreen({
    super.key,
    required this.nomLivreur,
    required this.adresseDepart,
    required this.adresseArrivee,
    required this.date,
    required this.montant,
    required this.statut,
  });

  (Color, String, IconData) get _config {
    switch (statut) {
      case 'enCours':
        return (
          AppColors.statutEnCours,
          'En cours',
          Icons.local_shipping_rounded
        );
      case 'annulee':
        return (AppColors.danger, 'Annulée', Icons.cancel_rounded);
      default:
        return (AppColors.success, 'Livrée', Icons.check_circle_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (couleur, libelle, icone) = _config;
    final enCours = statut == 'enCours';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Détail de la mission'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            // --- Statut ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: couleur,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  Icon(icone, color: Colors.white, size: 36),
                  const SizedBox(height: 10),
                  Text(libelle,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  if (enCours) ...[
                    const SizedBox(height: 4),
                    Text('Livreur en route',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85))),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Trajet ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle)),
                      Container(width: 2, height: 36, color: AppColors.border),
                      const Icon(Icons.location_on_rounded,
                          color: AppColors.danger, size: 18),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Collecte',
                            style: Theme.of(context).textTheme.bodySmall),
                        Text(adresseDepart,
                            style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 26),
                        Text('Livraison',
                            style: Theme.of(context).textTheme.bodySmall),
                        Text(adresseArrivee,
                            style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Livreur ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.person_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nomLivreur,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        Text('Livreur',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  if (enCours)
                    IconButton(
                      onPressed: () => debugPrint('Appeler le livreur'),
                      icon: const Icon(Icons.call_rounded,
                          color: AppColors.primary),
                      style: IconButton.styleFrom(
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.1)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Montant ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments_outlined,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(child: Text('Montant payé')),
                  Text('$montant F',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),

            if (!enCours) ...[
              const SizedBox(height: 20),
              SizedBox(
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () => debugPrint('Signaler un problème'),
                  icon: const Icon(Icons.flag_outlined, size: 18),
                  label: const Text('Signaler un problème'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
