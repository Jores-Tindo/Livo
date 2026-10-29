import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

/// Étape finale : choix du nouveau mot de passe.
///
/// TODO une fois Firebase branché : l'utilisateur est connecté après la
/// vérification OTP ; appeler user.updatePassword(...). Les règles de
/// robustesse ci-dessous doivent aussi être imposées côté serveur.
class NouveauMotDePasseScreen extends StatefulWidget {
  const NouveauMotDePasseScreen({super.key});

  @override
  State<NouveauMotDePasseScreen> createState() =>
      _NouveauMotDePasseScreenState();
}

class _NouveauMotDePasseScreenState extends State<NouveauMotDePasseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mdpController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _visible = false;
  bool _enregistrement = false;

  @override
  void dispose() {
    _mdpController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate() || _enregistrement) return;
    setState(() => _enregistrement = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mot de passe modifié. Connecte-toi !'),
        backgroundColor: AppColors.success,
      ),
    );
    context.go('/connexion');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(Icons.verified_user_outlined,
                      size: 34, color: AppColors.success),
                ),
                const SizedBox(height: 24),
                Text('Nouveau mot de passe',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                    'Numéro vérifié. Choisis un mot de passe que tu n\'utilises nulle part ailleurs.',
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _mdpController,
                  obscureText: !_visible,
                  decoration: InputDecoration(
                    labelText: 'Nouveau mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_visible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () => setState(() => _visible = !_visible),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 8)
                      return 'Au moins 8 caractères';
                    if (!RegExp(r'[0-9]').hasMatch(v))
                      return 'Ajoute au moins un chiffre';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmController,
                  obscureText: !_visible,
                  decoration: const InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                  validator: (v) => v != _mdpController.text
                      ? 'Les mots de passe ne correspondent pas'
                      : null,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _enregistrement ? null : _enregistrer,
                    child: _enregistrement
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Enregistrer'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
