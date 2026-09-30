import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

/// Contenu de l'onglet Accueil pour un client. Pas de Scaffold propre —
/// ce widget est affiché comme page dans ClientShellScreen, qui porte
/// la BottomNavigationBar commune à tout le parcours client.
class ClientAccueilScreen extends StatelessWidget {
  const ClientAccueilScreen({super.key});

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
                      child: const Icon(Icons.delivery_dining_sharp,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$_salutation ',
                              style: Theme.of(context).textTheme.bodyMedium),
                          Text('Tu veux reçevoir ou envoyer un colis ?',
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

            // --- Carte CTA principale pour une nouvelle mission ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: _CarteCTA(
                    onTap: () => context.push('/client/nouvelle-mission')),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Livreurs disponibles',
                        style: Theme.of(context).textTheme.titleLarge),
                    TextButton(
                      onPressed: () => debugPrint('Voir tout'),
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 178,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _livreursExemple.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) =>
                      _CarteLivreur(livreur: _livreursExemple[index]),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
                child: Text('Missions récentes',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
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
                          color: AppColors.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.inbox_outlined,
                            size: 26, color: AppColors.primary),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Aucune mission pour l\'instant',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tes livraisons récentes apparaîtront ici',
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

class _CarteCTA extends StatefulWidget {
  final VoidCallback onTap;
  const _CarteCTA({required this.onTap});

  @override
  State<_CarteCTA> createState() => _CarteCTAState();
}

class _CarteCTAState extends State<_CarteCTA> {
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
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.primary],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Faites livrer ou faites vous livrer un colis',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Trouve un livreur en quelques secondes',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 14),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('Commencer',
                              style: TextStyle(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_rounded,
                              size: 16, color: AppColors.primaryDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.local_shipping_outlined,
                    color: Colors.white, size: 34),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LivreurExemple {
  final String nom;
  final double note;
  final String distance;
  final IconData vehicule;
  final bool enLigne;

  const _LivreurExemple({
    required this.nom,
    required this.note,
    required this.distance,
    required this.vehicule,
    this.enLigne = true,
  });
}

const _livreursExemple = [
  _LivreurExemple(
      nom: 'Kokou A.',
      note: 4.8,
      distance: '1.2 km',
      vehicule: Icons.two_wheeler_outlined),
  _LivreurExemple(
      nom: 'Fidèle H.',
      note: 4.9,
      distance: '2.0 km',
      vehicule: Icons.pedal_bike_outlined),
  _LivreurExemple(
      nom: 'Rachid M.',
      note: 4.7,
      distance: '2.6 km',
      vehicule: Icons.two_wheeler_outlined),
];

class _CarteLivreur extends StatelessWidget {
  final _LivreurExemple livreur;
  const _CarteLivreur({required this.livreur});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(livreur.vehicule, color: AppColors.primary, size: 22),
              ),
              if (livreur.enLigne)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(livreur.nom,
              style: Theme.of(context).textTheme.labelLarge,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.accent, size: 14),
              const SizedBox(width: 2),
              Text('${livreur.note}',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  color: AppColors.textSecondary, size: 14),
              const SizedBox(width: 2),
              Text(livreur.distance,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}
