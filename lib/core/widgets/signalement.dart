import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Feuille "Signaler un problème" sur une mission terminée.
///
/// TODO une fois Firebase branché : créer signalements/{id} via une Cloud
/// Function (missionId, uid, motif, détails), jamais modifiable ensuite
/// par l'utilisateur ; l'équipe Livo le traite depuis le back-office.
Future<void> afficherSignalement(BuildContext context) async {
  final envoye = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => const _FeuilleSignalement(),
  );
  if (envoye == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Signalement envoyé. Notre équipe te répond sous 24 h.'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

class _FeuilleSignalement extends StatefulWidget {
  const _FeuilleSignalement();

  @override
  State<_FeuilleSignalement> createState() => _FeuilleSignalementState();
}

class _FeuilleSignalementState extends State<_FeuilleSignalement> {
  static const _motifs = [
    'Colis abîmé ou manquant',
    'Livreur en retard',
    'Comportement du livreur',
    'Problème de paiement',
    'Autre',
  ];

  String? _motif;
  final _details = TextEditingController();

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Signaler un problème',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            for (final m in _motifs)
              RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                value: m,
                groupValue: _motif,
                activeColor: AppColors.primary,
                title: Text(m),
                onChanged: (v) => setState(() => _motif = v),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: _details,
              maxLines: 3,
              maxLength: 300,
              decoration: const InputDecoration(
                  hintText: 'Explique-nous ce qui s\'est passé (facultatif)'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed:
                    _motif == null ? null : () => Navigator.pop(context, true),
                child: const Text('Envoyer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
