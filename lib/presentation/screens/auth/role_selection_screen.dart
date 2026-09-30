import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/utilisateur.dart';

/// Deuxième étape de l'inscription : choix du rôle. Même langage visuel
/// que RegisterScreen (header dégradé + carte flottante), avec la même
/// structure Column + Expanded + SingleChildScrollView pour ne jamais
/// déborder, quelle que soit la hauteur de l'écran ou la taille de police
/// système choisie par l'utilisateur.
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _choisirRole(BuildContext context, RoleUtilisateur role) {
    // TODO : une fois Firebase branché, écrire role dans users/{uid}
    // via AuthController avant de naviguer.
    if (role == RoleUtilisateur.client) {
      context.go('/client/accueil');
    } else {
      context.push('/candidature-livreur');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Column(
        children: [
          // --- Header dégradé ---
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryDark, AppColors.primary],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 6,
                          width: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          height: 6,
                          width: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Étape 2 sur 2',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Presque fini',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Que veux-tu faire sur Livo ?',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // --- Carte flottante, scrollable pour ne jamais déborder ---
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CarteRole(
                        titre: 'Je cherche un livreur',
                        description:
                            'Envoie un colis, trouve un livreur disponible près de toi',
                        icone: Icons.local_shipping_outlined,
                        couleur: AppColors.primary,
                        onTap: () =>
                            _choisirRole(context, RoleUtilisateur.client),
                      ),
                      const SizedBox(height: 16),
                      _CarteRole(
                        titre: 'Je veux devenir livreur',
                        description:
                            'Rejoins Livo et gagne de l\'argent en effectuant des livraisons',
                        icone: Icons.two_wheeler_outlined,
                        couleur: AppColors.accent,
                        onTap: () =>
                            _choisirRole(context, RoleUtilisateur.livreur),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarteRole extends StatefulWidget {
  final String titre;
  final String description;
  final IconData icone;
  final Color couleur;
  final VoidCallback onTap;

  const _CarteRole({
    required this.titre,
    required this.description,
    required this.icone,
    required this.couleur,
    required this.onTap,
  });

  @override
  State<_CarteRole> createState() => _CarteRoleState();
}

class _CarteRoleState extends State<_CarteRole> {
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
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
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
                  color: widget.couleur.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icone, color: widget.couleur, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.titre,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(widget.description,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
