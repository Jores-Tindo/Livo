import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

/// Écran de connexion. Même langage visuel que RegisterScreen (encoche
/// du header, carte flottante, style des champs) pour que le parcours
/// d'authentification soit cohérent d'un écran à l'autre.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifiantController = TextEditingController();
  final _motDePasseController = TextEditingController();

  bool _chargement = false;
  bool _motDePasseVisible = false;

  @override
  void dispose() {
    _identifiantController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  void _seConnecter() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _chargement = true);

      // TODO : une fois Firebase branché, remplacer par un vrai appel
      // à AuthController/AuthRepository (Firebase Auth signInWithEmailAndPassword
      // ou équivalent téléphone), puis rediriger selon le rôle de l'utilisateur.

      debugPrint('Connexion : ${_identifiantController.text}');

      setState(() => _chargement = false);
    }
  }

  void _seConnecterAvecGoogle() {
    // TODO : une fois Firebase branché, intégrer le package google_sign_in
    // + FirebaseAuth.instance.signInWithCredential(...). L'utilisateur
    // devra ensuite passer par /choix-profil s'il n'a pas encore de rôle.
    debugPrint('Connexion Google demandée');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Column(
        children: [
          // --- Header dégradé avec encoche (même forme que RegisterScreen) ---
          Container(
            // Hauteur MINIMALE (et non fixe) : le header grandit si le
            // contenu est plus grand que prévu au lieu de déborder.
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height * 0.35,
            ),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryDark, AppColors.primary],
              ),
              borderRadius:
                  BorderRadius.only(bottomRight: Radius.circular(500)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Image.asset(
                                'assets/images/logo/Logo_livo.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Livo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 50,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(height: 0.5),
                                Text(
                                  'Un livreur à portée de main',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Content de te revoir',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Connecte-toi pour continuer',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // --- Carte flottante + lien "S'inscrire" rattaché juste en dessous ---
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(15),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: SafeArea(
                      top: false,
                      bottom: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: _identifiantController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Téléphone ou email',
                                    hintText: 'Ex. 01 97 00 00 00',
                                    prefixIcon: Icon(
                                        Icons.person_outline_rounded,
                                        color: AppColors.textSecondary,
                                        size: 20),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty)
                                      return 'Ce champ est requis';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _motDePasseController,
                                  obscureText: !_motDePasseVisible,
                                  decoration: InputDecoration(
                                    labelText: 'Mot de passe',
                                    hintText: '••••••••',
                                    prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                        color: AppColors.textSecondary,
                                        size: 20),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _motDePasseVisible
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: AppColors.textSecondary,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(() =>
                                          _motDePasseVisible =
                                              !_motDePasseVisible),
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty)
                                      return 'Le mot de passe est requis';
                                    return null;
                                  },
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () =>
                                        context.push('/mot-de-passe-oublie'),
                                    child: const Text('Mot de passe oublié ?'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _chargement ? null : _seConnecter,
                              child: _chargement
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text('Se connecter'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              const Expanded(
                                  child: Divider(color: AppColors.border)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text('OU',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ),
                              const Expanded(
                                  child: Divider(color: AppColors.border)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 54,
                            child: OutlinedButton(
                              onPressed: _seConnecterAvecGoogle,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                side: const BorderSide(color: AppColors.border),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  _LogoGoogle(),
                                  SizedBox(width: 12),
                                  Text('Continuer avec Google'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- Lien rattaché à distance fixe (16px) sous la carte ---
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Pas encore de compte ?",
                            style: TextStyle(color: Colors.white)),
                        TextButton(
                          onPressed: () => context.go('/inscription'),
                          child: Text(
                            '  S\'inscrire',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Petit substitut visuel au logo Google officiel (pas d'accès aux
/// assets de marque ici). À remplacer par le vrai logo (SVG/PNG
/// officiel Google) une fois récupéré, pour rester conforme aux
/// règles d'utilisation de la marque Google.
class _LogoGoogle extends StatelessWidget {
  const _LogoGoogle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: const Text(
        'G',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
