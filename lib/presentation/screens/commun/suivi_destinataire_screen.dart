import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';

/// Page vue par un destinataire SANS compte Livo, ouverte depuis le lien
/// reçu par SMS. Il suit son colis et présente le code/QR au livreur.
///
/// TODO une fois Firebase branché :
///  - c'est une page web publique (Firebase Hosting) accessible par un
///    lien à jeton long et aléatoire propre à la mission, jamais par un
///    simple identifiant devinable ;
///  - le code de remise est lu côté serveur pour cette seule mission et
///    n'est pas modifiable par le client ;
///  - la remise est validée par une Cloud Function (voir
///    ConfirmationLivraisonScreen).
class SuiviDestinataireScreen extends StatelessWidget {
  final String expediteur;
  final String nomLivreur;
  final String code;
  final int etape; // 0 collecte, 1 en route, 2 arrivé

  const SuiviDestinataireScreen({
    super.key,
    this.expediteur = 'Esther K.',
    this.nomLivreur = 'Pascal Houngbo',
    this.code = '4827',
    this.etape = 1,
  });

  @override
  Widget build(BuildContext context) {
    const etapes = [
      'Livreur en route vers l\'expéditeur',
      'Colis en route vers toi',
      'Livreur arrivé'
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Suivi de ton colis'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            Text('$expediteur t\'envoie un colis',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text('Livré par $nomLivreur',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < etapes.length; i++)
                    _EtapeLigne(
                      texte: etapes[i],
                      faite: i < etape,
                      active: i == etape,
                      derniere: i == etapes.length - 1,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text('Ton code de remise',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18)),
                    child: QrImageView(
                      data: 'livo:remise:$code',
                      size: 170,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    code.split('').join('  '),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Montre le QR ou donne ce code au livreur seulement quand tu as ton colis en main.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Code copié')));
              },
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)),
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Copier le code'),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, color: AppColors.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ne partage ce code avec personne d\'autre que le livreur qui te remet le colis. Livo ne te le demandera jamais par téléphone.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EtapeLigne extends StatelessWidget {
  final String texte;
  final bool faite;
  final bool active;
  final bool derniere;
  const _EtapeLigne(
      {required this.texte,
      required this.faite,
      required this.active,
      required this.derniere});

  @override
  Widget build(BuildContext context) {
    final couleur = (faite || active) ? AppColors.primary : AppColors.border;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: faite ? AppColors.primary : AppColors.surface,
                  border: Border.all(color: couleur, width: 2),
                ),
                child: faite
                    ? const Icon(Icons.check_rounded,
                        size: 14, color: Colors.white)
                    : null,
              ),
              if (!derniere)
                Expanded(
                    child: Container(
                        width: 2,
                        color: faite ? AppColors.primary : AppColors.border)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: derniere ? 0 : 20),
              child: Text(
                texte,
                style: TextStyle(
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: (faite || active)
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
