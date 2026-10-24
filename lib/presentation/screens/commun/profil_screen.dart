import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/utilisateur.dart';

/// Écran de profil unique, partagé entre client et livreur — même en-tête,
/// même style de menu, seules les sections "Mon activité" changent selon
/// le rôle. Évite de maintenir deux écrans quasi identiques en double.
/// Affiché dans ClientShellScreen (role: client) et LivreurShellScreen
/// (role: livreur). Pas de Scaffold propre.
///
/// TODO une fois Firebase branché : charger nom/téléphone/email depuis
/// utilisateurs/{uid}, et pour un livreur, véhicule/note/documents depuis
/// livreurs/{uid}. Brancher la déconnexion sur FirebaseAuth.signOut().
class ProfilScreen extends StatelessWidget {
  final RoleUtilisateur role;

  const ProfilScreen({super.key, required this.role});

  bool get _estLivreur => role == RoleUtilisateur.livreur;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          children: [
            Text('Profil', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),

            // --- En-tête profil ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primaryDark, AppColors.primary],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jores A.',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 2),
                        if (_estLivreur)
                          Row(
                            children: const [
                              Icon(Icons.star_rounded,
                                  color: AppColors.accent, size: 16),
                              SizedBox(width: 2),
                              Text('4.8',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                              SizedBox(width: 8),
                              Text('• 213 livraisons',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13)),
                            ],
                          )
                        else
                          const Text(
                            '• 01 97 00 00 00',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 13),
                          ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Compte vérifié',
                            style: TextStyle(
                                color: AppColors.success,
                                fontSize: 11,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            Text('Mon activité', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),

            // --- Section spécifique au rôle ---
            if (_estLivreur) ...[
              _CarteMenu(
                icone: Icons.two_wheeler_outlined,
                titre: 'Mon véhicule',
                sousTitre: 'Moto • AB 1234 RB',
                onTap: () => context.push('/livreur/mon-vehicule'),
              ),
              const SizedBox(height: 10),
              _CarteMenu(
                icone: Icons.badge_outlined,
                titre: 'Mes documents',
                sousTitre: 'Pièce d\'identité, permis',
                onTap: () => context.push('/livreur/mes-documents'),
              ),
              const SizedBox(height: 10),
              _CarteMenu(
                icone: Icons.map_outlined,
                titre: 'Zone de couverture',
                sousTitre: 'Cotonou, Akpakpa',
                onTap: () => context.push('/livreur/zone-couverture'),
              ),
            ] else ...[
              _CarteMenu(
                icone: Icons.location_on_outlined,
                titre: 'Mes adresses enregistrées',
                sousTitre: 'Domicile, travail...',
                onTap: () => context.push('/client/mes-adresses'),
              ),
              const SizedBox(height: 10),
              _CarteMenu(
                icone: Icons.account_balance_wallet_outlined,
                titre: 'Moyens de paiement',
                sousTitre: 'Mobile Money',
                onTap: () => context.push('/client/moyens-paiement'),
              ),
              const SizedBox(height: 10),
              _CarteMenu(
                icone: Icons.people_outline_rounded,
                titre: 'Destinataires favoris',
                sousTitre: 'Accès rapide à tes contacts habituels',
                onTap: () => context.push('/client/destinataires-favoris'),
              ),
            ],

            const SizedBox(height: 28),
            Text('Compte', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _CarteMenu(
              icone: Icons.edit_outlined,
              titre: 'Modifier mon profil',
              onTap: () => context.push('/profil/modifier'),
            ),
            const SizedBox(height: 10),
            _CarteMenu(
              icone: Icons.help_outline_rounded,
              titre: 'Aide et support',
              onTap: () => context.push('/profil/aide'),
            ),
            const SizedBox(height: 10),
            _CarteMenu(
              icone: Icons.logout_rounded,
              titre: 'Se déconnecter',
              couleur: AppColors.danger,
              onTap: () => context.go('/connexion'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarteMenu extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String? sousTitre;
  final Color couleur;
  final VoidCallback onTap;

  const _CarteMenu({
    required this.icone,
    required this.titre,
    required this.onTap,
    this.sousTitre,
    this.couleur = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: couleur.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icone, color: couleur, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titre,
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: couleur)),
                  if (sousTitre != null) ...[
                    const SizedBox(height: 2),
                    Text(sousTitre!,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
