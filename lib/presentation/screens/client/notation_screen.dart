import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

const _tagsPositifs = [
  'Ponctuel',
  'Aimable',
  'Colis bien protégé',
  'Rapide',
  'Bonne communication'
];
const _tagsNegatifs = [
  'En retard',
  'Peu aimable',
  'Colis abîmé',
  'Mauvaise communication'
];
const _pourboires = [0, 200, 500, 1000];

/// Notation du livreur après une livraison payée : étoiles, étiquettes
/// rapides, commentaire et pourboire optionnel.
///
/// TODO une fois Firebase branché : écrire l'avis via une Cloud Function
/// (un seul avis par mission et par client, recalcul de la note moyenne
/// du livreur côté serveur — jamais en écriture directe depuis l'app),
/// et traiter le pourboire comme un paiement à part entière.
class NotationScreen extends StatefulWidget {
  final String nomLivreur;
  const NotationScreen({super.key, required this.nomLivreur});

  @override
  State<NotationScreen> createState() => _NotationScreenState();
}

class _NotationScreenState extends State<NotationScreen> {
  int _note = 0;
  int _pourboire = 0;
  final Set<String> _tags = {};
  final _commentaireController = TextEditingController();
  bool _envoi = false;

  @override
  void dispose() {
    _commentaireController.dispose();
    super.dispose();
  }

  String get _libelleNote {
    switch (_note) {
      case 1:
        return 'Très décevant';
      case 2:
        return 'Décevant';
      case 3:
        return 'Correct';
      case 4:
        return 'Très bien';
      case 5:
        return 'Excellent !';
      default:
        return 'Touche une étoile pour noter';
    }
  }

  List<String> get _tagsAffiches =>
      _note > 0 && _note <= 3 ? _tagsNegatifs : _tagsPositifs;

  Future<void> _envoyer() async {
    setState(() => _envoi = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Merci pour ton avis !'),
          backgroundColor: AppColors.success),
    );
    context.go('/client/accueil');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => context.go('/client/accueil'),
            child: const Text('Passer'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                children: [
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primaryDark, AppColors.primary],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: Colors.white, size: 42),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Comment s\'est passée ta livraison avec ${widget.nomLivreur} ?',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // --- Étoiles ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final active = i < _note;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _note = i + 1;
                          _tags.clear();
                        }),
                        child: AnimatedScale(
                          scale: active ? 1.12 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              active
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 46,
                              color:
                                  active ? AppColors.accent : AppColors.border,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _libelleNote,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _note == 0
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),

                  if (_note > 0) ...[
                    const SizedBox(height: 24),
                    Text(
                        _note <= 3
                            ? 'Qu\'est-ce qui n\'a pas été ?'
                            : 'Qu\'as-tu apprécié ?',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tagsAffiches.map((tag) {
                        final selectionne = _tags.contains(tag);
                        return FilterChip(
                          label: Text(tag),
                          selected: selectionne,
                          onSelected: (valeur) => setState(() {
                            if (valeur) {
                              _tags.add(tag);
                            } else {
                              _tags.remove(tag);
                            }
                          }),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _commentaireController,
                      maxLines: 3,
                      maxLength: 200,
                      decoration: const InputDecoration(
                        hintText: 'Un commentaire ? (optionnel)',
                      ),
                    ),
                  ],

                  if (_note >= 4) ...[
                    const SizedBox(height: 12),
                    Text('Laisser un pourboire',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: _pourboires.map((montant) {
                        final selectionne = _pourboire == montant;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _pourboire = montant),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selectionne
                                      ? AppColors.primary
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: selectionne
                                          ? AppColors.primary
                                          : AppColors.border),
                                ),
                                child: Text(
                                  montant == 0 ? 'Non' : '$montant F',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: selectionne
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_note == 0 || _envoi) ? null : _envoyer,
                  child: _envoi
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Envoyer mon avis'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
