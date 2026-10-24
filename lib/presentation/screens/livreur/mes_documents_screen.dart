import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum _StatutDocument { valide, enAttente, refuse }

class _Document {
  final String titre;
  final String sousTitre;
  final IconData icone;
  final _StatutDocument statut;

  const _Document(
      {required this.titre,
      required this.sousTitre,
      required this.icone,
      required this.statut});
}

const _documentsMock = [
  _Document(
    titre: 'Pièce d\'identité',
    sousTitre: 'CNI, passeport ou carte consulaire',
    icone: Icons.badge_outlined,
    statut: _StatutDocument.valide,
  ),
  _Document(
    titre: 'Permis de conduire',
    sousTitre: 'Requis pour moto/voiture',
    icone: Icons.motorcycle_outlined,
    statut: _StatutDocument.valide,
  ),
  _Document(
    titre: 'Photo du véhicule',
    sousTitre: 'Vue de face avec plaque visible',
    icone: Icons.photo_camera_outlined,
    statut: _StatutDocument.enAttente,
  ),
];

/// Liste des documents du livreur avec leur statut de vérification.
///
/// TODO une fois Firebase branché : lire livreurs/{uid}.documents et
/// permettre de re-uploader un document refusé vers Firebase Storage
/// (le nouveau fichier doit repasser en 'enAttente' jusqu'à revalidation
/// admin — jamais 'valide' côté client).
class MesDocumentsScreen extends StatelessWidget {
  const MesDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes documents'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          itemCount: _documentsMock.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) =>
              _CarteDocument(document: _documentsMock[index]),
        ),
      ),
    );
  }
}

class _CarteDocument extends StatelessWidget {
  final _Document document;
  const _CarteDocument({required this.document});

  (Color, String, IconData) get _config {
    switch (document.statut) {
      case _StatutDocument.valide:
        return (AppColors.success, 'Validé', Icons.check_circle_rounded);
      case _StatutDocument.enAttente:
        return (
          AppColors.statutEnAttente,
          'En attente',
          Icons.hourglass_top_rounded
        );
      case _StatutDocument.refuse:
        return (AppColors.danger, 'Refusé', Icons.cancel_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (couleur, libelle, icone) = _config;

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
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(document.icone, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(document.titre,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(document.sousTitre,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: couleur.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icone, color: couleur, size: 14),
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
              TextButton.icon(
                onPressed: () => debugPrint('Re-uploader ${document.titre}'),
                icon: const Icon(Icons.upload_outlined, size: 16),
                label: const Text('Mettre à jour'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
