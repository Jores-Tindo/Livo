import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

/// Code de démonstration. En production, le code est généré et vérifié
/// par Firebase Auth (Phone Auth) : l'app ne connaît jamais le bon code.
const codeOtpDemo = '123456';

/// Saisie du code à 6 chiffres reçu par SMS. Sert à deux flux :
///  - suite == 'reinitialisation' -> /nouveau-mot-de-passe
///  - suite == 'inscription'      -> /choix-profil
///
/// TODO une fois Firebase branché : remplacer la comparaison locale par
/// PhoneAuthProvider.credential(...) + signInWithCredential, et laisser
/// Firebase gérer l'expiration et la limite d'essais.
class VerificationOtpScreen extends StatefulWidget {
  final String telephone;
  final String suite;
  const VerificationOtpScreen(
      {super.key, required this.telephone, required this.suite});

  @override
  State<VerificationOtpScreen> createState() => _VerificationOtpScreenState();
}

class _VerificationOtpScreenState extends State<VerificationOtpScreen> {
  static const _longueur = 6;
  static const _delaiRenvoi = 30;

  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _timer;
  int _secondes = _delaiRenvoi;
  bool _verification = false;
  bool _erreur = false;

  @override
  void initState() {
    super.initState();
    _demarrerDecompte();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _demarrerDecompte() {
    _timer?.cancel();
    setState(() => _secondes = _delaiRenvoi);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      if (_secondes <= 1) {
        t.cancel();
        setState(() => _secondes = 0);
      } else {
        setState(() => _secondes--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _verifier() async {
    if (_controller.text.length < _longueur || _verification) return;
    setState(() {
      _verification = true;
      _erreur = false;
    });
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    if (_controller.text == codeOtpDemo) {
      if (widget.suite == 'reinitialisation') {
        context.pushReplacement('/nouveau-mot-de-passe');
      } else {
        context.pushReplacement('/choix-profil');
      }
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _verification = false;
        _erreur = true;
        _controller.clear();
      });
    }
  }

  void _renvoyer() {
    // TODO : relancer verifyPhoneNumber (avec limite côté serveur).
    _demarrerDecompte();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Un nouveau code vient d\'être envoyé')),
    );
  }

  String get _numeroMasque {
    final t = widget.telephone;
    if (t.length < 4) return t;
    return '${'•' * (t.length - 2)}${t.substring(t.length - 2)}';
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
                child: const Icon(Icons.sms_outlined,
                    size: 34, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text('Vérification',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Entre le code à 6 chiffres envoyé au $_numeroMasque',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 28),
              Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _focus.requestFocus(),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        final texte = _controller.text;
                        return Row(
                          children: List.generate(_longueur, (i) {
                            final actif = i == texte.length;
                            return Expanded(
                              child: Container(
                                height: 60,
                                margin: EdgeInsets.only(
                                    right: i == _longueur - 1 ? 0 : 8),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _erreur
                                        ? AppColors.danger
                                        : actif
                                            ? AppColors.primary
                                            : AppColors.border,
                                    width: actif || _erreur ? 2 : 1,
                                  ),
                                ),
                                child: Text(
                                  i < texte.length ? texte[i] : '',
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                  Opacity(
                    opacity: 0,
                    child: SizedBox(
                      width: 1,
                      height: 1,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focus,
                        keyboardType: TextInputType.number,
                        maxLength: _longueur,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (v) {
                          setState(() => _erreur = false);
                          if (v.length == _longueur) _verifier();
                        },
                      ),
                    ),
                  ),
                ],
              ),
              if (_erreur) ...[
                const SizedBox(height: 12),
                const Text('Code incorrect, réessaie',
                    style: TextStyle(
                        color: AppColors.danger, fontWeight: FontWeight.w600)),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      (_controller.text.length < _longueur || _verification)
                          ? null
                          : _verifier,
                  child: _verification
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Vérifier'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: _secondes > 0
                    ? Text('Renvoyer le code dans ${_secondes}s',
                        style: Theme.of(context).textTheme.bodyMedium)
                    : TextButton(
                        onPressed: _renvoyer,
                        child: const Text('Renvoyer le code')),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text('(Démo) le code est 123456',
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
