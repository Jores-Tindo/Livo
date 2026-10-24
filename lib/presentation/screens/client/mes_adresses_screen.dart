import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class _Adresse {
  final String libelle;
  final String details;
  final IconData icone;

  const _Adresse(
      {required this.libelle, required this.details, required this.icone});
}

final List<_Adresse> _adressesMock = [
  const _Adresse(
      libelle: 'Domicile',
      details: 'Rue 234, Akpakpa, Cotonou',
      icone: Icons.home_rounded),
  const _Adresse(
      libelle: 'Travail',
      details: 'Carrefour Houeyiho, Cotonou',
      icone: Icons.work_rounded),
];

/// Liste des adresses enregistrées par le client, pour accélérer la
/// création de missions récurrentes.
///
/// TODO une fois Firebase branché : lire/écrire sur
/// utilisateurs/{uid}/adresses, et proposer ces adresses comme
/// suggestions rapides dans nouvelle_mission_screen.dart.
class MesAdressesScreen extends StatefulWidget {
  const MesAdressesScreen({super.key});

  @override
  State<MesAdressesScreen> createState() => _MesAdressesScreenState();
}

class _MesAdressesScreenState extends State<MesAdressesScreen> {
  final List<_Adresse> _adresses = List.of(_adressesMock);

  void _ajouterAdresse() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FeuilleAjoutAdresse(
        onAjouter: (libelle, details) {
          setState(() => _adresses.add(_Adresse(
              libelle: libelle,
              details: details,
              icone: Icons.location_on_rounded)));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes adresses'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
          itemCount: _adresses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final adresse = _adresses[index];
            return Container(
              padding: const EdgeInsets.all(16),
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
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12)),
                    child:
                        Icon(adresse.icone, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(adresse.libelle,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        Text(adresse.details,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _adresses.removeAt(index)),
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.danger, size: 20),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajouterAdresse,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ajouter'),
      ),
    );
  }
}

class _FeuilleAjoutAdresse extends StatefulWidget {
  final void Function(String libelle, String details) onAjouter;
  const _FeuilleAjoutAdresse({required this.onAjouter});

  @override
  State<_FeuilleAjoutAdresse> createState() => _FeuilleAjoutAdresseState();
}

class _FeuilleAjoutAdresseState extends State<_FeuilleAjoutAdresse> {
  final _libelleController = TextEditingController();
  final _detailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Nouvelle adresse',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _libelleController,
            decoration:
                const InputDecoration(labelText: 'Nom (ex. Domicile, Travail)'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _detailsController,
            decoration: const InputDecoration(labelText: 'Adresse complète'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (_libelleController.text.trim().isEmpty ||
                    _detailsController.text.trim().isEmpty) return;
                widget.onAjouter(_libelleController.text.trim(),
                    _detailsController.text.trim());
                Navigator.of(context).pop();
              },
              child: const Text('Ajouter'),
            ),
          ),
        ],
      ),
    );
  }
}
