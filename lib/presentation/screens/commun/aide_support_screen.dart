import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class _Question {
  final String question;
  final String reponse;
  const _Question(this.question, this.reponse);
}

const _faq = [
  _Question(
    'Comment fonctionne le paiement ?',
    'Tu payes par Mobile Money ou QR code directement dans l\'app. La commission de la plateforme est déjà déduite du montant affiché au livreur.',
  ),
  _Question(
    'Que faire si mon livreur ne répond pas ?',
    'Après 45 secondes sans réponse, tu peux proposer ta mission à un autre livreur disponible depuis la liste.',
  ),
  _Question(
    'Comment devenir livreur sur Livo ?',
    'Depuis l\'écran d\'inscription, choisis le profil "Livreur" puis complète le formulaire de candidature. Ton dossier est examiné sous 48h.',
  ),
  _Question(
    'Puis-je annuler une mission en cours ?',
    'Oui, tant que le colis n\'a pas été récupéré par le livreur. Des frais peuvent s\'appliquer selon le délai d\'annulation.',
  ),
];

/// Écran d'aide commun aux deux rôles — FAQ + canaux de contact.
///
/// TODO une fois Firebase branché : brancher les boutons de contact sur
/// de vrais canaux (WhatsApp Business via url_launcher, email, ou un
/// système de ticket interne), et éventuellement charger la FAQ depuis
/// Firestore pour pouvoir la mettre à jour sans redéployer l'app.
class AideSupportScreen extends StatelessWidget {
  const AideSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Aide et support'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            Text('Nous contacter',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _CarteContact(
                    icone: Icons.chat_bubble_outline_rounded,
                    titre: 'WhatsApp',
                    couleur: AppColors.success,
                    onTap: () => debugPrint('Ouvrir WhatsApp support'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CarteContact(
                    icone: Icons.mail_outline_rounded,
                    titre: 'Email',
                    couleur: AppColors.info,
                    onTap: () => debugPrint('Ouvrir email support'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CarteContact(
                    icone: Icons.call_outlined,
                    titre: 'Appeler',
                    couleur: AppColors.primary,
                    onTap: () => debugPrint('Appeler support'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('Questions fréquentes',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ..._faq.map((q) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CarteFaq(question: q),
                )),
          ],
        ),
      ),
    );
  }
}

class _CarteContact extends StatelessWidget {
  final IconData icone;
  final String titre;
  final Color couleur;
  final VoidCallback onTap;

  const _CarteContact(
      {required this.icone,
      required this.titre,
      required this.couleur,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icone, color: couleur, size: 24),
            const SizedBox(height: 8),
            Text(titre,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _CarteFaq extends StatefulWidget {
  final _Question question;
  const _CarteFaq({required this.question});

  @override
  State<_CarteFaq> createState() => _CarteFaqState();
}

class _CarteFaqState extends State<_CarteFaq> {
  bool _ouvert = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _ouvert = !_ouvert),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(widget.question.question,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  AnimatedRotation(
                    turns: _ouvert ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(widget.question.reponse,
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
            crossFadeState:
                _ouvert ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
