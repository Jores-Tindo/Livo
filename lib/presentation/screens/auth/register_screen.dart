import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

/// Premier écran du parcours d'inscription. Header dégradé avec le logo
/// Livo, formulaire présenté dans une carte flottante par-dessus — le
/// style visuel qu'on retrouve sur la plupart des apps de livraison/VTC
/// (Uber, Bolt, Yango) : rassurant, moderne, pas générique.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _motDePasseController = TextEditingController();

  bool _chargement = false;
  bool _motDePasseVisible = false;
  bool _conditionsAcceptees = false;

  @override
  void dispose() {
    _nomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  void _valider() {
    if (!_conditionsAcceptees) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Vous devez accepter les conditions d'utilisation et la politique de confidentialité pour continuer."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _chargement = true);

      // TODO : une fois Firebase branché, remplacer par un vrai appel
      // à AuthController/AuthRepository (Firebase Auth + doc users/{uid})

      debugPrint(
          'Inscription : ${_nomController.text}, ${_telephoneController.text}');

      setState(() => _chargement = false);
      if (mounted) context.push('/choix-profil');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Column(
        children: [
          Stack(
            children: [
              // --- Header dégradé avec logo ---
              Container(
                height: MediaQuery.sizeOf(context).height * 0.35,
                width: double.infinity,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primaryDark, AppColors.primary],
                    ),
                    borderRadius:
                        BorderRadius.only(bottomRight: Radius.circular(500))),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 150,
                              height: 150,
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Livo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 50,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(
                                  height: 0.5,
                                ),
                                const Text(
                                  'Un livreur à porter de main',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Text(
                          'Bienvenue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Crée ton compte pour commencer',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // --- Carte flottante contenant le formulaire ---
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Indicateur d'étape
                            Row(
                              children: [
                                const _PointEtape(actif: true),
                                const SizedBox(width: 6),
                                const _PointEtape(actif: false),
                                const SizedBox(width: 12),
                                Text(
                                  'Étape 1 sur 2',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _ChampFormulaire(
                                    controller: _nomController,
                                    label: 'Nom complet',
                                    hint: 'Ex. Votre Nom',
                                    icone: Icons.person_outline_rounded,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty)
                                        return 'Le nom est requis';
                                      if (v.trim().length < 3)
                                        return 'Nom trop court';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _ChampFormulaire(
                                    controller: _telephoneController,
                                    label: 'Numéro de téléphone',
                                    hint: 'Ex. 01 97 00 00 00',
                                    icone: Icons.phone_outlined,
                                    clavier: TextInputType.phone,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty)
                                        return 'Le téléphone est requis';
                                      if (v.trim().length < 8)
                                        return 'Numéro invalide';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _ChampFormulaire(
                                    controller: _emailController,
                                    label: 'Email (optionnel)',
                                    hint: 'tonemail@exemple.com',
                                    icone: Icons.mail_outline_rounded,
                                    clavier: TextInputType.emailAddress,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty)
                                        return null;
                                      final motif =
                                          RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                                      if (!motif.hasMatch(v.trim()))
                                        return 'Email invalide';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _ChampFormulaire(
                                    controller: _motDePasseController,
                                    label: 'Mot de passe',
                                    hint: '••••••••',
                                    icone: Icons.lock_outline_rounded,
                                    masque: !_motDePasseVisible,
                                    suffixe: IconButton(
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
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return 'Le mot de passe est requis';
                                      if (v.length < 6)
                                        return 'Minimum 6 caractères';
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            //SECTION DE CONDITION D'UTILISATION
                            Row(
                              children: [
                                Checkbox(
                                  value: _conditionsAcceptees,
                                  activeColor:
                                      Colors.green, //couleur quand activé
                                  checkColor:
                                      Colors.white, //couleur du signe de check
                                  onChanged: (Value) => setState(() =>
                                      _conditionsAcceptees = Value ?? false),
                                ),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      children: [
                                        TextSpan(text: "J'accepte les "),
                                        TextSpan(
                                          text: "Conditions d'utilisation",
                                          style: TextStyle(
                                            color: Colors.green.shade600,
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                        TextSpan(text: " et la "),
                                        TextSpan(
                                          text: "politique de confidentialité",
                                          style: TextStyle(
                                            color: Colors.green.shade600,
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _chargement ? null : _valider,
                                child: _chargement
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Text('Continuer'),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_forward_rounded,
                                              size: 20),
                                        ],
                                      ),
                              ),
                            ),
                            SizedBox(
                              height: 50,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Vous avez dejà un compte ?',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        context.go('/connexion');
                                      },
                                      child: Text(
                                        '  Se connecter',
                                        style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ]),
                            ),
                          ],
                        ),
                      ),
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

class _PointEtape extends StatelessWidget {
  final bool actif;
  const _PointEtape({required this.actif});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 6,
      width: actif ? 28 : 14,
      decoration: BoxDecoration(
        color: actif ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

/// Champ de formulaire réutilisable avec icône, pour une cohérence
/// visuelle sur tous les écrans du parcours d'inscription/candidature.
class _ChampFormulaire extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icone;
  final TextInputType? clavier;
  final bool masque;
  final Widget? suffixe;
  final String? Function(String?) validator;

  const _ChampFormulaire({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icone,
    required this.validator,
    this.clavier,
    this.masque = false,
    this.suffixe,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: clavier,
      obscureText: masque,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icone, color: AppColors.textSecondary, size: 20),
        suffixIcon: suffixe,
      ),
    );
  }
}
