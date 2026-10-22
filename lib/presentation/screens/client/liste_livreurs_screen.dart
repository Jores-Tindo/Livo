import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

/// Données mock d'un livreur disponible — à remplacer par un vrai modèle
/// Firestore (collection `livreurs`, filtrée sur disponibilité + zone de
/// couverture) une fois Firebase branché.
class _LivreurDispo {
  final String nom;
  final double note;
  final int nombreLivraisons;
  final String vehicule;
  final double distanceKm;
  final IconData iconeVehicule;

  const _LivreurDispo({
    required this.nom,
    required this.note,
    required this.nombreLivraisons,
    required this.vehicule,
    required this.distanceKm,
    required this.iconeVehicule,
  });
}

const _livreursMock = [
  _LivreurDispo(
    nom: 'Pascal Houngbo',
    note: 4.8,
    nombreLivraisons: 213,
    vehicule: 'Moto',
    distanceKm: 1.2,
    iconeVehicule: Icons.two_wheeler_rounded,
  ),
  _LivreurDispo(
    nom: 'Sandrine Dossou',
    note: 4.9,
    nombreLivraisons: 340,
    vehicule: 'Moto',
    distanceKm: 1.8,
    iconeVehicule: Icons.two_wheeler_rounded,
  ),
  _LivreurDispo(
    nom: 'Armel Kpossou',
    note: 4.6,
    nombreLivraisons: 98,
    vehicule: 'Vélo',
    distanceKm: 2.4,
    iconeVehicule: Icons.pedal_bike_rounded,
  ),
  _LivreurDispo(
    nom: 'Firmine Agbo',
    note: 4.7,
    nombreLivraisons: 157,
    vehicule: 'Voiture',
    distanceKm: 3.1,
    iconeVehicule: Icons.directions_car_filled_rounded,
  ),
];

/// Liste des livreurs disponibles proche du point de départ, proposée au
/// client après la création d'une mission. Le client choisit manuellement
/// (voir cahier des charges 2.4 — matching manuel côté client, pas
/// d'attribution automatique).
class ListeLivreursScreen extends StatelessWidget {
  const ListeLivreursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Livreurs disponibles'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${_livreursMock.length} livreurs près de toi',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemCount: _livreursMock.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final livreur = _livreursMock[index];
                return _CarteLivreurDispo(
                  livreur: livreur,
                  onChoisir: () => context.push('/client/proposition-envoyee', extra: livreur.nom),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CarteLivreurDispo extends StatelessWidget {
  final _LivreurDispo livreur;
  final VoidCallback onChoisir;

  const _CarteLivreurDispo({required this.livreur, required this.onChoisir});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(livreur.iconeVehicule, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  livreur.nom,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
                    const SizedBox(width: 2),
                    Text('${livreur.note}', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(width: 10),
                    Text(
                      '${livreur.nombreLivraisons} livraisons',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(livreur.vehicule, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(width: 8),
                    const Icon(Icons.circle, size: 3, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      '${livreur.distanceKm.toStringAsFixed(1)} km',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onChoisir,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            child: const Text('Choisir'),
          ),
        ],
      ),
    );
  }
}