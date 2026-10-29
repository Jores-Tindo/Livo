import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

enum _StatutMission { enCours, livree, annulee }

enum _FiltreMission { toutes, enCours, terminees, annulees }

class _Mission {
  final String nomLivreur;
  final String adresseDepart;
  final String adresseArrivee;
  final DateTime date;
  final int montant;
  final _StatutMission statut;

  const _Mission({
    required this.nomLivreur,
    required this.adresseDepart,
    required this.adresseArrivee,
    required this.date,
    required this.montant,
    required this.statut,
  });
}

final _missionsMock = [
  _Mission(
    nomLivreur: 'Pascal Houngbo',
    adresseDepart: 'Carrefour Houeyiho, Cotonou',
    adresseArrivee: 'Rue 234, Akpakpa, Cotonou',
    date: DateTime.now().subtract(const Duration(minutes: 20)),
    montant: 1200,
    statut: _StatutMission.enCours,
  ),
  _Mission(
    nomLivreur: 'Sandrine Dossou',
    adresseDepart: 'Fidjrossè, Cotonou',
    adresseArrivee: 'Cadjehoun, Cotonou',
    date: DateTime.now().subtract(const Duration(days: 1)),
    montant: 1500,
    statut: _StatutMission.livree,
  ),
  _Mission(
    nomLivreur: 'Armel Kpossou',
    adresseDepart: 'Zogbo, Cotonou',
    adresseArrivee: 'Agla, Cotonou',
    date: DateTime.now().subtract(const Duration(days: 3)),
    montant: 900,
    statut: _StatutMission.annulee,
  ),
  _Mission(
    nomLivreur: 'Firmine Agbo',
    adresseDepart: 'Godomey, Abomey-Calavi',
    adresseArrivee: 'Akpakpa, Cotonou',
    date: DateTime.now().subtract(const Duration(days: 5)),
    montant: 2100,
    statut: _StatutMission.livree,
  ),
];

/// Contenu de l'onglet "Mes missions" pour un client — liste de toutes
/// ses missions (en cours, livrées, annulées), filtrables par statut.
/// Pas de Scaffold propre, affiché dans ClientShellScreen.
///
/// TODO une fois Firebase branché : écouter en temps réel
/// missions/{id} où clientId == uid (Firestore listener), et pour la
/// mission en cours, afficher un vrai suivi en direct (position du
/// livreur) plutôt qu'une carte statique.
class MesMissionsScreen extends StatefulWidget {
  const MesMissionsScreen({super.key});

  @override
  State<MesMissionsScreen> createState() => _MesMissionsScreenState();
}

class _MesMissionsScreenState extends State<MesMissionsScreen> {
  _FiltreMission _filtre = _FiltreMission.toutes;

  List<_Mission> get _missionsFiltrees {
    switch (_filtre) {
      case _FiltreMission.toutes:
        return _missionsMock;
      case _FiltreMission.enCours:
        return _missionsMock
            .where((m) => m.statut == _StatutMission.enCours)
            .toList();
      case _FiltreMission.terminees:
        return _missionsMock
            .where((m) => m.statut == _StatutMission.livree)
            .toList();
      case _FiltreMission.annulees:
        return _missionsMock
            .where((m) => m.statut == _StatutMission.annulee)
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final missions = _missionsFiltrees;

    return Container(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Row(
                children: [
                  Text('Mes missions',
                      style: Theme.of(context).textTheme.headlineMedium),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _ChipFiltre(
                        label: 'Toutes',
                        selectionne: _filtre == _FiltreMission.toutes,
                        onTap: () =>
                            setState(() => _filtre = _FiltreMission.toutes)),
                    const SizedBox(width: 8),
                    _ChipFiltre(
                        label: 'En cours',
                        selectionne: _filtre == _FiltreMission.enCours,
                        onTap: () =>
                            setState(() => _filtre = _FiltreMission.enCours)),
                    const SizedBox(width: 8),
                    _ChipFiltre(
                        label: 'Terminées',
                        selectionne: _filtre == _FiltreMission.terminees,
                        onTap: () =>
                            setState(() => _filtre = _FiltreMission.terminees)),
                    const SizedBox(width: 8),
                    _ChipFiltre(
                        label: 'Annulées',
                        selectionne: _filtre == _FiltreMission.annulees,
                        onTap: () =>
                            setState(() => _filtre = _FiltreMission.annulees)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: missions.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.inbox_outlined,
                                size: 48, color: AppColors.textSecondary),
                            const SizedBox(height: 16),
                            Text('Aucune mission ici',
                                style: Theme.of(context).textTheme.bodyLarge),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      itemCount: missions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => _CarteMission(
                        mission: missions[index],
                        onTap: () => context.push('/client/detail-mission',
                            extra: missions[index]._versMap()),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on _Mission {
  Map<String, dynamic> _versMap() => {
        'nomLivreur': nomLivreur,
        'adresseDepart': adresseDepart,
        'adresseArrivee': adresseArrivee,
        'date': date.toIso8601String(),
        'montant': montant,
        'statut': statut.name,
      };
}

class _ChipFiltre extends StatelessWidget {
  final String label;
  final bool selectionne;
  final VoidCallback onTap;
  const _ChipFiltre(
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
              fontSize: 13),
        ),
      ),
    );
  }
}

class _CarteMission extends StatelessWidget {
  final _Mission mission;
  final VoidCallback onTap;
  const _CarteMission({required this.mission, required this.onTap});

  (Color, String, IconData) get _config {
    switch (mission.statut) {
      case _StatutMission.enCours:
        return (
          AppColors.statutEnCours,
          'En cours',
          Icons.local_shipping_rounded
        );
      case _StatutMission.livree:
        return (AppColors.success, 'Livrée', Icons.check_circle_rounded);
      case _StatutMission.annulee:
        return (AppColors.danger, 'Annulée', Icons.cancel_rounded);
    }
  }

  String _formaterDate(DateTime date) {
    final maintenant = DateTime.now();
    final diff = maintenant.difference(date);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays == 1) return 'Hier';
    return 'Il y a ${diff.inDays} jours';
  }

  @override
  Widget build(BuildContext context) {
    final (couleur, libelle, icone) = _config;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: couleur.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icone, color: couleur, size: 13),
                      const SizedBox(width: 4),
                      Text(libelle,
                          style: TextStyle(
                              color: couleur,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const Spacer(),
                Text(_formaterDate(mission.date),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.primary, shape: BoxShape.circle)),
                    Container(width: 2, height: 24, color: AppColors.border),
                    const Icon(Icons.location_on_rounded,
                        color: AppColors.danger, size: 12),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mission.adresseDepart,
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 18),
                      Text(mission.adresseArrivee,
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: AppColors.border),
            Row(
              children: [
                const Icon(Icons.person_outline_rounded,
                    color: AppColors.textSecondary, size: 16),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(mission.nomLivreur,
                        style: Theme.of(context).textTheme.bodySmall)),
                Text('${mission.montant} F',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
