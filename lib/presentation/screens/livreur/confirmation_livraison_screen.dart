import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

/// Code de remise de démonstration. En production, ce code est généré par
/// le serveur pour CHAQUE mission, transmis au destinataire (QR dans son
/// app, ou SMS s'il n'a pas de compte) et vérifié côté serveur.
const codeRemiseDemo = '4827';

/// Le livreur confirme la remise du colis au destinataire, soit en
/// scannant son QR code, soit en saisissant le code à 4 chiffres que le
/// destinataire lui donne. Retourne `true` via `context.pop(true)` si la
/// remise est validée.
///
/// TODO une fois Firebase branché :
///  - ajouter le package `mobile_scanner` (+ permission CAMERA) pour le
///    vrai scan du QR code ;
///  - vérifier le code via une Cloud Function (jamais côté app), qui
///    marque la mission "livree" et déclenche le versement au livreur
///    après prélèvement de la commission ;
///  - limiter le nombre d'essais pour éviter de deviner le code.
class ConfirmationLivraisonScreen extends StatefulWidget {
  const ConfirmationLivraisonScreen({super.key});

  @override
  State<ConfirmationLivraisonScreen> createState() =>
      _ConfirmationLivraisonScreenState();
}

class _ConfirmationLivraisonScreenState
    extends State<ConfirmationLivraisonScreen> {
  static const _essaisMax = 5;

  final _codeController = TextEditingController();
  final _focus = FocusNode();
  bool _modeScan = true;
  bool _verification = false;
  bool _erreur = false;
  int _essais = 0;

  @override
  void dispose() {
    _codeController.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _verifierCode() async {
    if (_codeController.text.length < 4 || _verification) return;

    if (_essais >= _essaisMax) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Trop d\'essais. Demande au client de te renvoyer le code.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() {
      _verification = true;
      _erreur = false;
    });
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    if (_codeController.text == codeRemiseDemo) {
      context.pop(true);
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _verification = false;
        _erreur = true;
        _essais++;
        _codeController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Confirmer la remise'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            children: [
              // --- Bascule scan / code ---
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _OngletMode(
                        label: 'Scanner le QR',
                        icone: Icons.qr_code_scanner_rounded,
                        actif: _modeScan,
                        onTap: () => setState(() => _modeScan = true),
                      ),
                    ),
                    Expanded(
                      child: _OngletMode(
                        label: 'Saisir le code',
                        icone: Icons.pin_outlined,
                        actif: !_modeScan,
                        onTap: () {
                          setState(() => _modeScan = false);
                          _focus.requestFocus();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                  child: _modeScan ? _construireScan() : _construireCode()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construireScan() {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Viseur
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CustomPaint(painter: _PeintreViseur()),
                ),
                const Icon(Icons.qr_code_2_rounded,
                    size: 90, color: Colors.white24),
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: Text(
                    'Place le QR code du destinataire dans le cadre',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppColors.info, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Le scan par caméra sera actif bientôt. En attendant, utilise « Saisir le code ».',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _construireCode() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            'Demande au destinataire le code à 4 chiffres affiché dans son application',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 28),

          // Cases visibles + champ réel invisible
          Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () => _focus.requestFocus(),
                child: AnimatedBuilder(
                  animation: _codeController,
                  builder: (context, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (i) {
                        final texte = _codeController.text;
                        final rempli = i < texte.length;
                        final actif = i == texte.length;
                        return Container(
                          width: 62,
                          height: 70,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
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
                            rempli ? texte[i] : '',
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.w700),
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
                    controller: _codeController,
                    focusNode: _focus,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (valeur) {
                      setState(() => _erreur = false);
                      if (valeur.length == 4) _verifierCode();
                    },
                  ),
                ),
              ),
            ],
          ),

          if (_erreur) ...[
            const SizedBox(height: 16),
            Text(
              'Code incorrect (${_essaisMax - _essais} essais restants)',
              style: const TextStyle(
                  color: AppColors.danger, fontWeight: FontWeight.w600),
            ),
          ],

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (_codeController.text.length < 4 || _verification)
                  ? null
                  : _verifierCode,
              child: _verification
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Valider la remise'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OngletMode extends StatelessWidget {
  final String label;
  final IconData icone;
  final bool actif;
  final VoidCallback onTap;

  const _OngletMode(
      {required this.label,
      required this.icone,
      required this.actif,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: actif ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone,
                size: 18,
                color: actif ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: actif ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quatre coins façon viseur de scanner.
class _PeintreViseur extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pinceau = Paint()
      ..color = AppColors.primaryLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    const l = 36.0;
    final w = size.width;
    final h = size.height;

    canvas.drawLine(const Offset(0, l), const Offset(0, 0), pinceau);
    canvas.drawLine(const Offset(0, 0), const Offset(l, 0), pinceau);
    canvas.drawLine(Offset(w - l, 0), Offset(w, 0), pinceau);
    canvas.drawLine(Offset(w, 0), Offset(w, l), pinceau);
    canvas.drawLine(Offset(0, h - l), Offset(0, h), pinceau);
    canvas.drawLine(Offset(0, h), Offset(l, h), pinceau);
    canvas.drawLine(Offset(w - l, h), Offset(w, h), pinceau);
    canvas.drawLine(Offset(w, h), Offset(w, h - l), pinceau);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
