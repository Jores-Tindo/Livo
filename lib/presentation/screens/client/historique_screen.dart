import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';

enum _TypeGraphique { barres, cercle }

enum _Periode { semaine, mois, annee }

/// Dashboard historique du client : statistiques globales + graphique
/// bascule barres/donut selon la période sélectionnée. Données mockées
/// pour l'instant — à remplacer par une agrégation Firestore une fois
/// branché (probablement via une Cloud Function qui pré-calcule ces
/// chiffres plutôt que de tout recompter côté client).
class HistoriqueScreen extends StatefulWidget {
  const HistoriqueScreen({super.key});

  @override
  State<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen> {
  _TypeGraphique _typeGraphique = _TypeGraphique.barres;
  _Periode _periode = _Periode.mois;

  // --- Données mockées, à connecter à Firestore plus tard ---
  static const _stats = [
    _Stat(
        label: 'Missions faites',
        valeur: '42',
        icone: Icons.list_alt_rounded,
        couleur: AppColors.primary),
    _Stat(
        label: 'Effectuées',
        valeur: '37',
        icone: Icons.check_circle_outline_rounded,
        couleur: AppColors.success),
    _Stat(
        label: 'Annulées',
        valeur: '5',
        icone: Icons.cancel_outlined,
        couleur: AppColors.danger),
    _Stat(
        label: 'Colis reçus',
        valeur: '40',
        icone: Icons.inventory_2_outlined,
        couleur: AppColors.info),
    _Stat(
        label: 'Livreurs contactés',
        valeur: '15',
        icone: Icons.people_outline_rounded,
        couleur: AppColors.accent),
    _Stat(
        label: 'Paiements',
        valeur: '42',
        icone: Icons.receipt_long_outlined,
        couleur: AppColors.primaryLight),
  ];

  static const _montantTotal = '128 500 FCFA';

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
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
                child: Text('Historique',
                    style: Theme.of(context).textTheme.headlineMedium),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Text('Ton activité en un coup d\'œil',
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),

            // --- Filtres de période ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _ChipPeriode(
                      label: 'Semaine',
                      selectionne: _periode == _Periode.semaine,
                      onTap: () => setState(() => _periode = _Periode.semaine),
                    ),
                    const SizedBox(width: 8),
                    _ChipPeriode(
                      label: 'Mois',
                      selectionne: _periode == _Periode.mois,
                      onTap: () => setState(() => _periode = _Periode.mois),
                    ),
                    const SizedBox(width: 8),
                    _ChipPeriode(
                      label: 'Année',
                      selectionne: _periode == _Periode.annee,
                      onTap: () => setState(() => _periode = _Periode.annee),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => debugPrint('Filtres avancés'),
                      icon: const Icon(Icons.tune_rounded,
                          color: AppColors.textSecondary),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Grille de statistiques colorées ---
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _CarteStat(stat: _stats[index]),
                  childCount: _stats.length,
                ),
              ),
            ),

            // --- Montant total sur la période ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primaryDark, AppColors.primary],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total dépensé (${_libellePeriode(_periode)})',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _montantTotal,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.payments_outlined,
                            color: Colors.white, size: 26),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- Bascule type de graphique ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Répartition des missions',
                        style: Theme.of(context).textTheme.titleLarge),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          _BoutonTypeGraphique(
                            icone: Icons.bar_chart_rounded,
                            actif: _typeGraphique == _TypeGraphique.barres,
                            onTap: () => setState(
                                () => _typeGraphique = _TypeGraphique.barres),
                          ),
                          _BoutonTypeGraphique(
                            icone: Icons.donut_large_rounded,
                            actif: _typeGraphique == _TypeGraphique.cercle,
                            onTap: () => setState(
                                () => _typeGraphique = _TypeGraphique.cercle),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Graphique ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  height: 280,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _typeGraphique == _TypeGraphique.barres
                        ? const _GraphiqueBarres(key: ValueKey('barres'))
                        : const _GraphiqueCercle(key: ValueKey('cercle')),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _libellePeriode(_Periode p) {
    switch (p) {
      case _Periode.semaine:
        return 'cette semaine';
      case _Periode.mois:
        return 'ce mois';
      case _Periode.annee:
        return 'cette année';
    }
  }
}

class _Stat {
  final String label;
  final String valeur;
  final IconData icone;
  final Color couleur;
  const _Stat(
      {required this.label,
      required this.valeur,
      required this.icone,
      required this.couleur});
}

class _CarteStat extends StatelessWidget {
  final _Stat stat;
  const _CarteStat({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: stat.couleur.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(stat.icone, color: stat.couleur, size: 20),
          ),
          const Spacer(),
          Text(stat.valeur, style: Theme.of(context).textTheme.headlineMedium),
          Text(stat.label,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _ChipPeriode extends StatelessWidget {
  final String label;
  final bool selectionne;
  final VoidCallback onTap;
  const _ChipPeriode(
      {required this.label, required this.selectionne, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selectionne ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selectionne ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selectionne ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _BoutonTypeGraphique extends StatelessWidget {
  final IconData icone;
  final bool actif;
  final VoidCallback onTap;
  const _BoutonTypeGraphique(
      {required this.icone, required this.actif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: actif ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icone,
            size: 20, color: actif ? Colors.white : AppColors.textSecondary),
      ),
    );
  }
}

/// Vue en barres : missions effectuées vs annulées, mois par mois.
class _GraphiqueBarres extends StatelessWidget {
  const _GraphiqueBarres({super.key});

  static const _moisLabels = ['Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep'];
  static const _effectuees = [4.0, 6.0, 5.0, 8.0, 7.0, 7.0];
  static const _annulees = [1.0, 0.0, 2.0, 0.0, 1.0, 1.0];

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 10,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (valeur, meta) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _moisLabels[valeur.toInt()],
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ),
            ),
          ),
        ),
        barGroups: List.generate(_moisLabels.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: _effectuees[i],
                color: AppColors.primary,
                width: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              BarChartRodData(
                toY: _annulees[i],
                color: AppColors.danger.withValues(alpha: 0.6),
                width: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
            barsSpace: 4,
          );
        }),
      ),
    );
  }
}

/// Vue en donut : répartition effectuées / annulées / en cours.
class _GraphiqueCercle extends StatelessWidget {
  const _GraphiqueCercle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 50,
              sections: [
                PieChartSectionData(
                  value: 37,
                  color: AppColors.primary,
                  title: '',
                  radius: 26,
                ),
                PieChartSectionData(
                  value: 5,
                  color: AppColors.danger,
                  title: '',
                  radius: 26,
                ),
                PieChartSectionData(
                  value: 3,
                  color: AppColors.accent,
                  title: '',
                  radius: 26,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _LegendeGraphique(
                couleur: AppColors.primary, label: 'Effectuées', valeur: '37'),
            SizedBox(height: 12),
            _LegendeGraphique(
                couleur: AppColors.danger, label: 'Annulées', valeur: '5'),
            SizedBox(height: 12),
            _LegendeGraphique(
                couleur: AppColors.accent, label: 'En cours', valeur: '3'),
          ],
        ),
      ],
    );
  }
}

class _LegendeGraphique extends StatelessWidget {
  final Color couleur;
  final String label;
  final String valeur;
  const _LegendeGraphique(
      {required this.couleur, required this.label, required this.valeur});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: couleur, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text('$label ',
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(valeur,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}
