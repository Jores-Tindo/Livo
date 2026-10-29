import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

enum _Operateur { mtn, moov }

/// Retrait du solde du livreur vers son compte Mobile Money.
///
/// TODO une fois Firebase branché : le bouton appelle une Cloud Function
/// `demanderRetrait` qui, côté serveur : vérifie le solde réel, applique
/// minimum et frais, débite le portefeuille dans une transaction
/// Firestore, puis déclenche le virement via l'API de l'opérateur
/// (agrégateur type FedaPay / KKiaPay). Le montant affiché ici n'est
/// jamais une source de vérité.
class RetraitScreen extends StatefulWidget {
  final int solde;
  const RetraitScreen({super.key, required this.solde});

  @override
  State<RetraitScreen> createState() => _RetraitScreenState();
}

class _RetraitScreenState extends State<RetraitScreen> {
  static const _minimum = 1000;
  static const _fraisPourcent = 0.01; // 1 % (valeur de démonstration)

  final _formKey = GlobalKey<FormState>();
  final _montantController = TextEditingController();
  final _numeroController = TextEditingController();
  _Operateur _operateur = _Operateur.mtn;
  bool _traitement = false;
  bool _succes = false;

  @override
  void dispose() {
    _montantController.dispose();
    _numeroController.dispose();
    super.dispose();
  }

  int get _montant => int.tryParse(_montantController.text) ?? 0;
  int get _frais => (_montant * _fraisPourcent).ceil();
  int get _recu => (_montant - _frais).clamp(0, _montant);

  String _formater(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
      b.write(s[i]);
    }
    return '$b F';
  }

  Future<void> _confirmer() async {
    if (!_formKey.currentState!.validate() || _traitement) return;
    FocusScope.of(context).unfocus();
    setState(() => _traitement = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _traitement = false;
      _succes = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_succes) return _construireSucces();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Retrait Mobile Money'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Solde disponible',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85))),
                      const SizedBox(height: 4),
                      Text(
                        _formater(widget.solde),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Opérateur',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _CarteOperateur(
                        nom: 'MTN MoMo',
                        couleur: const Color(0xFFFFCC00),
                        selectionne: _operateur == _Operateur.mtn,
                        onTap: () =>
                            setState(() => _operateur = _Operateur.mtn),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CarteOperateur(
                        nom: 'Moov Money',
                        couleur: const Color(0xFF0072CE),
                        selectionne: _operateur == _Operateur.moov,
                        onTap: () =>
                            setState(() => _operateur = _Operateur.moov),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _numeroController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10)
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Numéro Mobile Money',
                    hintText: '01 97 00 00 00',
                    prefixIcon: Icon(Icons.phone_iphone_rounded),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Le numéro est requis';
                    // Numéros béninois : 10 chiffres depuis la réforme (préfixe 01).
                    if (v.length != 10)
                      return 'Le numéro doit contenir 10 chiffres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _montantController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(7)
                  ],
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Montant à retirer',
                    suffixText: 'F CFA',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                  validator: (v) {
                    final m = int.tryParse(v ?? '') ?? 0;
                    if (m < _minimum) return 'Minimum ${_formater(_minimum)}';
                    if (m > widget.solde) return 'Dépasse ton solde disponible';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final m in [5000, 10000, 20000])
                      if (m <= widget.solde)
                        ActionChip(
                          label: Text(_formater(m)),
                          onPressed: () =>
                              setState(() => _montantController.text = '$m'),
                        ),
                    ActionChip(
                      label: const Text('Tout retirer'),
                      onPressed: () => setState(
                          () => _montantController.text = '${widget.solde}'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_montant >= _minimum)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _LigneRecap(
                            label: 'Montant', valeur: _formater(_montant)),
                        const SizedBox(height: 8),
                        _LigneRecap(
                            label: 'Frais (1 %)',
                            valeur: '- ${_formater(_frais)}'),
                        const Divider(height: 24),
                        _LigneRecap(
                            label: 'Tu recevras',
                            valeur: _formater(_recu),
                            fort: true),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _traitement ? null : _confirmer,
                    child: _traitement
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Confirmer le retrait'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construireSucces() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success.withValues(alpha: 0.12),
                  ),
                  child: const Icon(Icons.check_rounded,
                      size: 64, color: AppColors.success),
                ),
              ),
              const SizedBox(height: 28),
              Text('Retrait en cours',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(
                '${_formater(_recu)} seront envoyés sur le ${_numeroController.text} '
                '(${_operateur == _Operateur.mtn ? 'MTN MoMo' : 'Moov Money'}) dans quelques minutes.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Retour au portefeuille'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarteOperateur extends StatelessWidget {
  final String nom;
  final Color couleur;
  final bool selectionne;
  final VoidCallback onTap;

  const _CarteOperateur(
      {required this.nom,
      required this.couleur,
      required this.selectionne,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: selectionne
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selectionne ? AppColors.primary : AppColors.border,
            width: selectionne ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(color: couleur, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                nom,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LigneRecap extends StatelessWidget {
  final String label;
  final String valeur;
  final bool fort;

  const _LigneRecap(
      {required this.label, required this.valeur, this.fort = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: fort ? AppColors.textPrimary : AppColors.textSecondary)),
        Text(
          valeur,
          style: TextStyle(
            fontWeight: fort ? FontWeight.w800 : FontWeight.w600,
            fontSize: fort ? 17 : 14,
            color: fort ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
