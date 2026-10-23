import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

/// Contenu de l'onglet Accueil pour un livreur. Pas de Scaffold propre —
/// ce widget est affiché comme page dans LivreurShellScreen.
///
/// TODO une fois Firebase branché : le toggle disponibilité doit écrire
/// `disponible: bool` sur le doc `livreurs/{uid}`, et la liste des
/// missions proposées doit écouter en temps réel les missions dont
/// `statut == 'proposee' && livreurId == uid` (voir cahier des charges 2.4).
class LivreurAccueilScreen extends StatefulWidget {
  const LivreurAccueilScreen({super.key});

  @override
  State<LivreurAccueilScreen> createState() => _LivreurAccueilScreenState();
}

class _LivreurAccueilScreenState extends State<LivreurAccueilScreen> {
  bool _disponible = true;

  String get _salutation {
    final heure = DateTime.now().hour;
    if (heure < 12) return 'Bonjour';
    if (heure < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // --- En-tête avec toggle disponibilité ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primaryDark, AppColors.primary],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.two_wheeler_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$_salutation 👋',
                              style: Theme.of(context).textTheme.bodyMedium),
                          Text('Prêt à livrer ?',
                              style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                    ),
                    _BoutonIcone(
                      icone: Icons.notifications_none_rounded,
                      badge: true,
                      onTap: () => debugPrint('Notifications'),
                    ),
                  ],
                ),
              ),
            ),

            // --- Carte de disponibilité ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: _CarteDisponibilite(
                  disponible: _disponible,
                  onChanged: (valeur) => setState(() => _disponible = valeur),
                ),
              ),
            ),

            // --- Résumé du jour ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                child: Text('Résumé du jour',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: const [
                    Expanded(
                      child: _CarteStat(
                        icone: Icons.payments_outlined,
                        valeur: '12 500 F',
                        label: 'Gains du jour',
                        couleur: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _CarteStat(
                        icone: Icons.local_shipping_outlined,
                        valeur: '6',
                        label: 'Livraisons',
                        couleur: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Missions proposées (si dispo) ---
            if (_disponible) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                  child: Text('Mission proposée',
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: _CarteMissionProposee(
                    onTap: () => context.push(
                      '/livreur/mission-proposee',
                      extra: {
                        'nomClient': 'Esther K.',
                        'adresseDepart': 'Carrefour Houeyiho, Cotonou',
                        'adresseArrivee': 'Rue 234, Akpakpa, Cotonou',
                        'distanceKm': 3.4,
                        'montant': 1200,
                        'description': 'Un petit carton (documents)',
                      },
                    ),
                  ),
                ),
              ),
            ] else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color:
                                AppColors.textSecondary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.bedtime_outlined,
                              size: 26, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Tu es hors ligne',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Active ta disponibilité pour recevoir des missions',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BoutonIcone extends StatelessWidget {
  final IconData icone;
  final bool badge;
  final VoidCallback onTap;

  const _BoutonIcone(
      {required this.icone, required this.onTap, this.badge = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icone, color: AppColors.textPrimary, size: 22),
          ),
          if (badge)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: AppColors.danger, shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
  }
}

class _CarteDisponibilite extends StatelessWidget {
  final bool disponible;
  final ValueChanged<bool> onChanged;

  const _CarteDisponibilite(
      {required this.disponible, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: disponible
              ? [AppColors.primaryDark, AppColors.primary]
              : [
                  AppColors.textSecondary,
                  AppColors.textSecondary.withValues(alpha: 0.7)
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: (disponible ? AppColors.primary : AppColors.textSecondary)
                .withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              disponible
                  ? Icons.bolt_rounded
                  : Icons.power_settings_new_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  disponible ? 'Tu es en ligne' : 'Tu es hors ligne',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  disponible
                      ? 'Tu peux recevoir des missions'
                      : 'Active-toi pour recevoir des missions',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13),
                ),
              ],
            ),
          ),
          Switch(
            value: disponible,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.white.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

class _CarteStat extends StatelessWidget {
  final IconData icone;
  final String valeur;
  final String label;
  final Color couleur;

  const _CarteStat(
      {required this.icone,
      required this.valeur,
      required this.label,
      required this.couleur});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: couleur.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icone, color: couleur, size: 20),
          ),
          const SizedBox(height: 12),
          Text(valeur, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _CarteMissionProposee extends StatefulWidget {
  final VoidCallback onTap;
  const _CarteMissionProposee({required this.onTap});

  @override
  State<_CarteMissionProposee> createState() => _CarteMissionProposeeState();
}

class _CarteMissionProposeeState extends State<_CarteMissionProposee> {
  bool _pressee = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressee = true),
      onTapUp: (_) => setState(() => _pressee = false),
      onTapCancel: () => setState(() => _pressee = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressee ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
                color: AppColors.statutProposee.withValues(alpha: 0.4),
                width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.statutProposee.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.statutProposee.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Nouvelle demande',
                      style: TextStyle(
                          color: AppColors.statutProposee,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Spacer(),
                  const Text('1 200 F',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle)),
                      Container(width: 2, height: 28, color: AppColors.border),
                      const Icon(Icons.location_on_rounded,
                          color: AppColors.danger, size: 14),
                    ],
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Carrefour Houeyiho, Cotonou',
                            style: TextStyle(fontSize: 13)),
                        SizedBox(height: 22),
                        Text('Rue 234, Akpakpa, Cotonou',
                            style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: widget.onTap,
                  child: const Text('Voir la proposition'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
