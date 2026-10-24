import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/utilisateur.dart';
import '../commun/historique_screen.dart';
import '../commun/profil_screen.dart';
import 'client_accueil_screen.dart';
import 'mes_missions_screen.dart';

/// Enveloppe de navigation pour tout le parcours client, avec une
/// BottomNavigationBar commune. Chaque onglet garde son état grâce à
/// IndexedStack (on ne perd pas le scroll de l'accueil en changeant
/// d'onglet puis en revenant).
class ClientShellScreen extends StatefulWidget {
  const ClientShellScreen({super.key});

  @override
  State<ClientShellScreen> createState() => _ClientShellScreenState();
}

class _ClientShellScreenState extends State<ClientShellScreen> {
  int _indexActif = 0;

  static const _pages = [
    ClientAccueilScreen(),
    MesMissionsScreen(),
    HistoriqueScreen(role: RoleUtilisateur.client),
    ProfilScreen(role: RoleUtilisateur.client),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _indexActif, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ItemNav(
                  icone: Icons.home_rounded,
                  iconeInactive: Icons.home_outlined,
                  label: 'Accueil',
                  actif: _indexActif == 0,
                  onTap: () => setState(() => _indexActif = 0),
                ),
                _ItemNav(
                  icone: Icons.local_shipping_rounded,
                  iconeInactive: Icons.local_shipping_outlined,
                  label: 'Missions',
                  actif: _indexActif == 1,
                  onTap: () => setState(() => _indexActif = 1),
                ),
                _ItemNav(
                  icone: Icons.bar_chart_rounded,
                  iconeInactive: Icons.bar_chart_outlined,
                  label: 'Historique',
                  actif: _indexActif == 2,
                  onTap: () => setState(() => _indexActif = 2),
                ),
                _ItemNav(
                  icone: Icons.person_rounded,
                  iconeInactive: Icons.person_outline_rounded,
                  label: 'Profil',
                  actif: _indexActif == 3,
                  onTap: () => setState(() => _indexActif = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemNav extends StatelessWidget {
  final IconData icone;
  final IconData iconeInactive;
  final String label;
  final bool actif;
  final VoidCallback onTap;

  const _ItemNav({
    required this.icone,
    required this.iconeInactive,
    required this.label,
    required this.actif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: actif
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(actif ? icone : iconeInactive,
                color: actif ? AppColors.primary : AppColors.textSecondary,
                size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: actif ? FontWeight.w600 : FontWeight.w400,
                color: actif ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
