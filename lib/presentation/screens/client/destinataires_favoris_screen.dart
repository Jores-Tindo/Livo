import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class _Destinataire {
  final String nom;
  final String telephone;

  const _Destinataire({required this.nom, required this.telephone});
}

final List<_Destinataire> _destinatairesMock = [
  const _Destinataire(nom: 'Maman', telephone: '01 96 00 11 22'),
  const _Destinataire(nom: 'Fiacre (bureau)', telephone: '01 91 22 33 44'),
];

/// Contacts favoris pour le cas "autre personne" lors de la création
/// d'une mission (voir cahier des charges 2.5 — trois scénarios de
/// destinataire). Accélère la saisie pour les destinataires récurrents.
///
/// TODO une fois Firebase branché : lire/écrire sur
/// utilisateurs/{uid}/destinatairesFavoris, et proposer ces contacts en
/// auto-complétion dans nouvelle_mission_screen.dart.
class DestinatairesFavorisScreen extends StatefulWidget {
  const DestinatairesFavorisScreen({super.key});

  @override
  State<DestinatairesFavorisScreen> createState() =>
      _DestinatairesFavorisScreenState();
}

class _DestinatairesFavorisScreenState
    extends State<DestinatairesFavorisScreen> {
  final List<_Destinataire> _destinataires = List.of(_destinatairesMock);

  void _ajouterDestinataire() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FeuilleAjoutDestinataire(
        onAjouter: (nom, telephone) {
          setState(() => _destinataires
              .add(_Destinataire(nom: nom, telephone: telephone)));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Destinataires favoris'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: _destinataires.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people_outline_rounded,
                          size: 48, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      Text('Aucun destinataire enregistré',
                          style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                itemCount: _destinataires.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final destinataire = _destinataires[index];
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
                              color: AppColors.info.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(21)),
                          child: const Icon(Icons.person_rounded,
                              color: AppColors.info, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(destinataire.nom,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              Text(destinataire.telephone,
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              setState(() => _destinataires.removeAt(index)),
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
        onPressed: _ajouterDestinataire,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ajouter'),
      ),
    );
  }
}

class _FeuilleAjoutDestinataire extends StatefulWidget {
  final void Function(String nom, String telephone) onAjouter;
  const _FeuilleAjoutDestinataire({required this.onAjouter});

  @override
  State<_FeuilleAjoutDestinataire> createState() =>
      _FeuilleAjoutDestinataireState();
}

class _FeuilleAjoutDestinataireState extends State<_FeuilleAjoutDestinataire> {
  final _nomController = TextEditingController();
  final _telephoneController = TextEditingController();

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
          Text('Nouveau destinataire',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _nomController,
            decoration: const InputDecoration(labelText: 'Nom'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _telephoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Téléphone'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (_nomController.text.trim().isEmpty ||
                    _telephoneController.text.trim().isEmpty) return;
                widget.onAjouter(_nomController.text.trim(),
                    _telephoneController.text.trim());
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
