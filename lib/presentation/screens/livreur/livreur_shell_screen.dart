import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'livreur_accueil_screen.dart';
import 'livreur_portefeuille_screen.dart';
import 'livreur_profil_screen.dart';

/// Enveloppe de navigation pour tout le parcours livreur, même langage
/// visuel et même pattern que ClientShellScreen (IndexedStack + barre
/// de navigation custom animée).
class LivreurShellScreen extends StatefulWidget {
  const LivreurShellScreen({super.key});

  @override
  State<LivreurShellScreen> createState() => _LivreurShellScreenState();
}

class _LivreurShellScreenState extends State<LivreurShellScreen> {
  int _indexActif = 0;

  static const _pages = [
    LivreurAccueilScreen(),
    LivreurPortefeuilleScreen(),
    LivreurProfilScreen(),
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
                  icone: Icons.account_balance_wallet_rounded,
                  iconeInactive: Icons.account_balance_wallet_outlined,
                  label: 'Portefeuille',
                  actif: _indexActif == 1,
                  onTap: () => setState(() => _indexActif = 1),
                ),
                _ItemNav(
                  icone: Icons.person_rounded,
                  iconeInactive: Icons.person_outline_rounded,
                  label: 'Profil',
                  actif: _indexActif == 2,
                  onTap: () => setState(() => _indexActif = 2),
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
