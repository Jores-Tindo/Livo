import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

enum _EtapeLivraison { versCollecte, colisRecupere, versLivraison, livre }

/// Suivi d'une mission acceptée par le livreur, étape par étape (voir
/// cahier des charges — statuts mission : acceptee -> en_cours -> livree).
///
/// Pour l'instant les étapes avancent manuellement au clic. Une fois
/// Firebase branché : chaque passage d'étape doit écrire sur
/// missions/{id} (via Cloud Function pour les étapes sensibles), et la
/// position GPS du livreur doit être poussée en continu pendant
/// versCollecte/versLivraison pour que le client suive la course en
/// direct (accès restreint aux seuls participants de la mission).
class MissionEnCoursScreen extends StatefulWidget {
  final String nomClient;
  final String adresseDepart;
  final String adresseArrivee;
  final int montant;
  final String description;

  const MissionEnCoursScreen({
    super.key,
    required this.nomClient,
    required this.adresseDepart,
    required this.adresseArrivee,
    required this.montant,
    required this.description,
  });

  @override
  State<MissionEnCoursScreen> createState() => _MissionEnCoursScreenState();
}

class _MissionEnCoursScreenState extends State<MissionEnCoursScreen> {
  _EtapeLivraison _etape = _EtapeLivraison.versCollecte;

  String get _titreEtape {
    switch (_etape) {
      case _EtapeLivraison.versCollecte:
        return 'En route vers la collecte';
      case _EtapeLivraison.colisRecupere:
        return 'Colis récupéré';
      case _EtapeLivraison.versLivraison:
        return 'En route vers la livraison';
      case _EtapeLivraison.livre:
        return 'Livraison terminée';
    }
  }

  String get _libelleBouton {
    switch (_etape) {
      case _EtapeLivraison.versCollecte:
        return 'J\'ai récupéré le colis';
      case _EtapeLivraison.colisRecupere:
        return 'Démarrer la livraison';
      case _EtapeLivraison.versLivraison:
        return 'Confirmer la livraison';
      case _EtapeLivraison.livre:
        return 'Retour à l\'accueil';
    }
  }

  void _etapeSuivante() {
    switch (_etape) {
      case _EtapeLivraison.versCollecte:
        setState(() => _etape = _EtapeLivraison.colisRecupere);
        break;
      case _EtapeLivraison.colisRecupere:
        setState(() => _etape = _EtapeLivraison.versLivraison);
        break;
      case _EtapeLivraison.versLivraison:
        // TODO : une fois Firebase branché, demander ici la confirmation
        // QR/photo prévue au cahier des charges avant de marquer 'livree'.
        setState(() => _etape = _EtapeLivraison.livre);
        break;
      case _EtapeLivraison.livre:
        context.go('/livreur/accueil');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final estLivre = _etape == _EtapeLivraison.livre;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mission en cours'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // --- Statut visuel ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color:
                              estLivre ? AppColors.success : AppColors.primary,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: (estLivre
                                      ? AppColors.success
                                      : AppColors.primary)
                                  .withValues(alpha: 0.3),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              estLivre
                                  ? Icons.check_circle_rounded
                                  : Icons.navigation_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _titreEtape,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.nomClient,
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- Timeline des étapes ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            _EtapeTimeline(
                              icone: Icons.flag_circle_outlined,
                              titre: 'Collecte',
                              sousTitre: widget.adresseDepart,
                              faite: _etape.index >=
                                  _EtapeLivraison.colisRecupere.index,
                              encours: _etape == _EtapeLivraison.versCollecte,
                            ),
                            _EtapeTimeline(
                              icone: Icons.inventory_2_outlined,
                              titre: 'Colis récupéré',
                              sousTitre: widget.description,
                              faite: _etape.index >=
                                  _EtapeLivraison.versLivraison.index,
                              encours: _etape == _EtapeLivraison.colisRecupere,
                            ),
                            _EtapeTimeline(
                              icone: Icons.location_on_outlined,
                              titre: 'Livraison',
                              sousTitre: widget.adresseArrivee,
                              faite: _etape == _EtapeLivraison.livre,
                              encours: _etape == _EtapeLivraison.versLivraison,
                              dernier: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.payments_outlined,
                                color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            const Expanded(child: Text('Montant de la course')),
                            Text('${widget.montant} F',
                                style: Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _etapeSuivante,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        estLivre ? AppColors.success : AppColors.primary,
                  ),
                  child: Text(_libelleBouton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EtapeTimeline extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String sousTitre;
  final bool faite;
  final bool encours;
  final bool dernier;

  const _EtapeTimeline({
    required this.icone,
    required this.titre,
    required this.sousTitre,
    required this.faite,
    required this.encours,
    this.dernier = false,
  });

  @override
  Widget build(BuildContext context) {
    final couleur = faite
        ? AppColors.success
        : encours
            ? AppColors.primary
            : AppColors.textSecondary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: (faite || encours)
                      ? couleur.withValues(alpha: 0.12)
                      : AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: couleur, width: encours ? 2 : 1),
                ),
                child: Icon(
                  faite ? Icons.check_rounded : icone,
                  color: couleur,
                  size: 18,
                ),
              ),
              if (!dernier)
                Expanded(child: Container(width: 2, color: AppColors.border)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: dernier ? 0 : 24, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    style: TextStyle(
                      fontWeight: encours ? FontWeight.w700 : FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(sousTitre, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
