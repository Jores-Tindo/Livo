import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

/// Étape 1 de la réinitialisation : l'utilisateur donne son numéro, on lui
/// envoie un code par SMS (voir VerificationOtpScreen).
///
/// TODO une fois Firebase branché : appeler
/// FirebaseAuth.verifyPhoneNumber. Afficher le même message que le numéro
/// existe ou non, pour ne pas révéler quels numéros ont un compte.
class MotDePasseOublieScreen extends StatefulWidget {
  const MotDePasseOublieScreen({super.key});

  @override
  State<MotDePasseOublieScreen> createState() => _MotDePasseOublieScreenState();
}

class _MotDePasseOublieScreenState extends State<MotDePasseOublieScreen> {
  final _formKey = GlobalKey<FormState>();
  final _telephoneController = TextEditingController();
  bool _envoi = false;

  @override
  void dispose() {
    _telephoneController.dispose();
    super.dispose();
  }

  Future<void> _envoyerCode() async {
    if (!_formKey.currentState!.validate() || _envoi) return;
    setState(() => _envoi = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _envoi = false);
    context.push('/verification-otp', extra: {
      'telephone': _telephoneController.text,
      'suite': 'reinitialisation',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
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
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(Icons.lock_reset_rounded,
                      size: 36, color: AppColors.primary),
                ),
                const SizedBox(height: 24),
                Text('Mot de passe oublié ?',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Entre le numéro de téléphone de ton compte. Nous t\'enverrons un code par SMS pour choisir un nouveau mot de passe.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _telephoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10)
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Numéro de téléphone',
                    hintText: '01 97 00 00 00',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Le numéro est requis';
                    if (v.length != 10)
                      return 'Le numéro doit contenir 10 chiffres';
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _envoi ? null : _envoyerCode,
                    child: _envoi
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Envoyer le code'),
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
