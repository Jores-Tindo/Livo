import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class _Page {
  final IconData icone;
  final Color couleur;
  final String titre;
  final String texte;
  const _Page(this.icone, this.couleur, this.titre, this.texte);
}

const _pages = [
  _Page(
    Icons.inventory_2_rounded,
    AppColors.primary,
    'Envoie un colis en quelques secondes',
    'Indique où récupérer et où livrer, choisis un livreur disponible près de toi. C\'est tout.',
  ),
  _Page(
    Icons.location_searching_rounded,
    AppColors.info,
    'Suis ta livraison en direct',
    'Vois ton livreur avancer sur la carte et reçois une alerte à chaque étape.',
  ),
  _Page(
    Icons.verified_user_rounded,
    AppColors.accent,
    'Sûr pour tous',
    'Livreurs vérifiés, paiement Mobile Money et code de remise : ton colis arrive à la bonne personne.',
  ),
];

/// Présentation de l'app au premier lancement.
///
/// TODO : mémoriser "onboarding vu" avec shared_preferences pour ne
/// l'afficher qu'une fois.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _derniere => _index == _pages.length - 1;

  void _suivant() {
    if (_derniere) {
      context.go('/inscription');
    } else {
      _controller.nextPage(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _derniere ? 0 : 1,
                  child: TextButton(
                    onPressed:
                        _derniere ? null : () => context.go('/inscription'),
                    child: const Text('Passer'),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final p = _pages[i];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          minHeight: MediaQuery.sizeOf(context).height * 0.55),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: p.couleur.withValues(alpha: 0.1),
                            ),
                            child: Center(
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: p.couleur.withValues(alpha: 0.18),
                                ),
                                child:
                                    Icon(p.icone, size: 60, color: p.couleur),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(p.titre,
                              textAlign: TextAlign.center,
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 14),
                          Text(p.texte,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final actif = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: actif ? 26 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: actif ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _suivant,
                  child: Text(_derniere ? 'Commencer' : 'Suivant'),
                ),
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _derniere ? 1 : 0,
              child: TextButton(
                onPressed: _derniere ? () => context.go('/connexion') : null,
                child: const Text('J\'ai déjà un compte'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
