import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

enum _TypeTransaction { gain, retrait }

class _Transaction {
  final String titre;
  final DateTime date;
  final int montant;
  final _TypeTransaction type;

  const _Transaction(
      {required this.titre,
      required this.date,
      required this.montant,
      required this.type});
}

final _transactionsMock = [
  _Transaction(
      titre: 'Livraison - Esther K.',
      date: DateTime.now(),
      montant: 1200,
      type: _TypeTransaction.gain),
  _Transaction(
      titre: 'Livraison - Rachid M.',
      date: DateTime.now().subtract(const Duration(hours: 3)),
      montant: 1800,
      type: _TypeTransaction.gain),
  _Transaction(
      titre: 'Retrait Mobile Money',
      date: DateTime.now().subtract(const Duration(days: 1)),
      montant: 15000,
      type: _TypeTransaction.retrait),
  _Transaction(
      titre: 'Livraison - Firmine A.',
      date: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      montant: 900,
      type: _TypeTransaction.gain),
  _Transaction(
      titre: 'Livraison - Pascal H.',
      date: DateTime.now().subtract(const Duration(days: 2)),
      montant: 1500,
      type: _TypeTransaction.gain),
];

/// Contenu de l'onglet Portefeuille pour un livreur — solde, retrait
/// Mobile Money, historique des gains. Pas de Scaffold propre, affiché
/// dans LivreurShellScreen.
///
/// TODO une fois Firebase branché : le solde et l'historique viennent
/// d'une sous-collection `livreurs/{uid}/transactions`, alimentée
/// uniquement par les Cloud Functions au moment du paiement d'une
/// mission (jamais en écriture directe client — voir firestore.rules).
/// Le montant affiché au livreur doit déjà exclure la commission
/// plateforme, prélevée avant le versement.
class LivreurPortefeuilleScreen extends StatelessWidget {
  const LivreurPortefeuilleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Text('Portefeuille',
                    style: Theme.of(context).textTheme.headlineMedium),
              ),
            ),

            // --- Carte solde ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primaryDark, AppColors.primary],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Solde disponible',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85))),
                      const SizedBox(height: 6),
                      const Text(
                        '38 400 F CFA',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              context.push('/livreur/retrait', extra: 38400),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primaryDark,
                          ),
                          icon: const Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 18),
                          label: const Text('Retirer via Mobile Money'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- Mini-stats ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Row(
                  children: const [
                    Expanded(
                      child: _CarteStat(
                          label: 'Cette semaine',
                          valeur: '24 300 F',
                          icone: Icons.calendar_view_week_rounded),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _CarteStat(
                          label: 'Ce mois-ci',
                          valeur: '96 800 F',
                          icone: Icons.calendar_month_rounded),
                    ),
                  ],
                ),
              ),
            ),

            // --- Historique ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                child: Text('Historique',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              sliver: SliverList.separated(
                itemCount: _transactionsMock.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) =>
                    _CarteTransaction(transaction: _transactionsMock[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarteStat extends StatelessWidget {
  final String label;
  final String valeur;
  final IconData icone;

  const _CarteStat(
      {required this.label, required this.valeur, required this.icone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: AppColors.textSecondary, size: 18),
          const SizedBox(height: 10),
          Text(valeur, style: Theme.of(context).textTheme.titleMedium),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _CarteTransaction extends StatelessWidget {
  final _Transaction transaction;
  const _CarteTransaction({required this.transaction});

  String _formaterDate(DateTime date) {
    final maintenant = DateTime.now();
    if (date.day == maintenant.day && date.month == maintenant.month) {
      return 'Aujourd\'hui, ${date.hour.toString().padLeft(2, '0')}h${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} à ${date.hour.toString().padLeft(2, '0')}h${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final estGain = transaction.type == _TypeTransaction.gain;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (estGain ? AppColors.success : AppColors.info)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              estGain
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: estGain ? AppColors.success : AppColors.info,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.titre,
                    style: Theme.of(context).textTheme.bodyLarge,
                    overflow: TextOverflow.ellipsis),
                Text(_formaterDate(transaction.date),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            '${estGain ? '+' : '-'}${transaction.montant} F',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: estGain ? AppColors.success : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
