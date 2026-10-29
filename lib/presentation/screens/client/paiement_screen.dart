import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

enum _MoyenPaiement { mtn, moov, qr }

enum _EtatPaiement { choix, traitement, succes }

String _formaterMontant(int montant) {
  final texte = montant.toString();
  final tampon = StringBuffer();
  for (var i = 0; i < texte.length; i++) {
    if (i > 0 && (texte.length - i) % 3 == 0) tampon.write(' ');
    tampon.write(texte[i]);
  }
  return '$tampon F';
}

/// Paiement de la course par le client : récapitulatif, choix du moyen
/// (MTN, Moov, QR code) puis confirmation. Le paiement est simulé.
///
/// IMPORTANT une fois Firebase branché : le paiement ne doit JAMAIS être
/// validé côté client. Le flux correct est :
///  1. le client lance le paiement via l'API de l'opérateur / agrégateur ;
///  2. le webhook de confirmation arrive sur une Cloud Function ;
///  3. cette fonction prélève la commission de la plateforme, crédite le
///     portefeuille du livreur et marque la mission comme payée.
/// L'écran se contente d'écouter le statut de paiement de la mission.
class PaiementScreen extends StatefulWidget {
  final String nomLivreur;
  final int montant;

  const PaiementScreen(
      {super.key, required this.nomLivreur, required this.montant});

  @override
  State<PaiementScreen> createState() => _PaiementScreenState();
}

class _PaiementScreenState extends State<PaiementScreen> {
  static const _fraisService = 100;

  _MoyenPaiement _moyen = _MoyenPaiement.mtn;
  _EtatPaiement _etat = _EtatPaiement.choix;

  int get _total => widget.montant + _fraisService;

  Future<void> _payer() async {
    setState(() => _etat = _EtatPaiement.traitement);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() => _etat = _EtatPaiement.succes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _etat == _EtatPaiement.succes
          ? null
          : AppBar(
              title: const Text('Paiement'),
              backgroundColor: AppColors.background,
              elevation: 0,
              foregroundColor: AppColors.textPrimary,
              automaticallyImplyLeading: false,
            ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _etat == _EtatPaiement.succes
              ? _construireSucces()
              : _construireChoix(),
        ),
      ),
    );
  }

  Widget _construireChoix() {
    final enCours = _etat == _EtatPaiement.traitement;

    return Column(
      key: const ValueKey('choix'),
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            children: [
              // --- Récapitulatif ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryDark, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Text('Total à payer',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85))),
                    const SizedBox(height: 4),
                    Text(
                      _formaterMontant(_total),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          _LigneRecap(
                              label: 'Course (${widget.nomLivreur})',
                              valeur: _formaterMontant(widget.montant)),
                          const SizedBox(height: 6),
                          _LigneRecap(
                              label: 'Frais de service',
                              valeur: _formaterMontant(_fraisService)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              Text('Moyen de paiement',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),

              _CarteMoyen(
                icone: Icons.phone_android_rounded,
                couleur: const Color(0xFFEF9F27),
                titre: 'MTN Mobile Money',
                sousTitre: '01 97 00 00 00',
                selectionne: _moyen == _MoyenPaiement.mtn,
                onTap: enCours
                    ? null
                    : () => setState(() => _moyen = _MoyenPaiement.mtn),
              ),
              const SizedBox(height: 10),
              _CarteMoyen(
                icone: Icons.phone_android_rounded,
                couleur: AppColors.info,
                titre: 'Moov Money',
                sousTitre: '01 95 11 22 33',
                selectionne: _moyen == _MoyenPaiement.moov,
                onTap: enCours
                    ? null
                    : () => setState(() => _moyen = _MoyenPaiement.moov),
              ),
              const SizedBox(height: 10),
              _CarteMoyen(
                icone: Icons.qr_code_2_rounded,
                couleur: AppColors.primary,
                titre: 'QR code',
                sousTitre: 'Scanne depuis ton application de paiement',
                selectionne: _moyen == _MoyenPaiement.qr,
                onTap: enCours
                    ? null
                    : () => setState(() => _moyen = _MoyenPaiement.qr),
              ),

              if (_moyen == _MoyenPaiement.qr) ...[
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 180,
                    height: 180,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    // TODO : remplacer par un vrai QR (package qr_flutter)
                    // généré à partir de la référence de paiement de la mission.
                    child: const Icon(Icons.qr_code_2_rounded,
                        size: 150, color: AppColors.textPrimary),
                  ),
                ),
              ],

              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.lock_outline_rounded,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Paiement sécurisé. Le livreur est payé après confirmation.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: enCours ? null : _payer,
              child: enCours
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text('Payer ${_formaterMontant(_total)}'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _construireSucces() {
    return Padding(
      key: const ValueKey('succes'),
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, valeur, enfant) =>
                Transform.scale(scale: valeur, child: enfant),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.12)),
              child: const Icon(Icons.check_circle_rounded,
                  size: 72, color: AppColors.success),
            ),
          ),
          const SizedBox(height: 28),
          Text('Paiement réussi',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(
            '${_formaterMontant(_total)} payés. Merci d\'avoir utilisé Livo !',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => context.pushReplacement('/client/notation',
                  extra: widget.nomLivreur),
              child: Text('Noter ${widget.nomLivreur}'),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.go('/client/accueil'),
            child: const Text('Plus tard'),
          ),
        ],
      ),
    );
  }
}

class _LigneRecap extends StatelessWidget {
  final String label;
  final String valeur;
  const _LigneRecap({required this.label, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Text(label,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13))),
        Text(valeur,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
      ],
    );
  }
}

class _CarteMoyen extends StatelessWidget {
  final IconData icone;
  final Color couleur;
  final String titre;
  final String sousTitre;
  final bool selectionne;
  final VoidCallback? onTap;

  const _CarteMoyen({
    required this.icone,
    required this.couleur,
    required this.titre,
    required this.sousTitre,
    required this.selectionne,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selectionne
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selectionne ? AppColors.primary : AppColors.border,
              width: selectionne ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: couleur.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icone, color: couleur, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titre,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(sousTitre, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Icon(
              selectionne ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: selectionne ? AppColors.primary : AppColors.border,
            ),
          ],
        ),
      ),
    );
  }
}
