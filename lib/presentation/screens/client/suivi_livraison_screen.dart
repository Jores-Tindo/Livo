import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

enum _EtapeSuivi { versCollecte, colisRecupere, versLivraison, livre }

/// Suivi en direct de la livraison côté client, une fois qu'un livreur a
/// accepté la mission. Pour l'instant la progression est simulée par un
/// Timer (une étape toutes les 5 secondes) et la carte est dessinée à la
/// main, car Google Maps est en attente de facturation.
///
/// TODO une fois Firebase + Maps branchés :
///  - écouter missions/{id} (statut) et la position du livreur en temps
///    réel via Firestore, accessible aux seuls participants de la mission
///    (voir firestore.rules) ;
///  - remplacer _CarteSimulee par un vrai GoogleMap avec marqueur mobile
///    et polyline du trajet ;
///  - l'annulation doit passer par une Cloud Function (frais éventuels).
class SuiviLivraisonScreen extends StatefulWidget {
  final String nomLivreur;
  final String adresseDepart;
  final String adresseArrivee;
  final int montant;

  const SuiviLivraisonScreen({
    super.key,
    required this.nomLivreur,
    required this.adresseDepart,
    required this.adresseArrivee,
    required this.montant,
  });

  @override
  State<SuiviLivraisonScreen> createState() => _SuiviLivraisonScreenState();
}

class _SuiviLivraisonScreenState extends State<SuiviLivraisonScreen> {
  static const _dureeEtape = Duration(seconds: 5);

  _EtapeSuivi _etape = _EtapeSuivi.versCollecte;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_dureeEtape, (timer) {
      if (!mounted) return;
      if (_etape.index >= _EtapeSuivi.livre.index) {
        timer.cancel();
        return;
      }
      setState(() => _etape = _EtapeSuivi.values[_etape.index + 1]);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Progression du livreur sur le tracé : 0 = point de départ du livreur,
  // 0.4 = point de collecte, 1 = point de livraison.
  double get _progression {
    switch (_etape) {
      case _EtapeSuivi.versCollecte:
        return 0.2;
      case _EtapeSuivi.colisRecupere:
        return 0.4;
      case _EtapeSuivi.versLivraison:
        return 0.75;
      case _EtapeSuivi.livre:
        return 1.0;
    }
  }

  String get _titre {
    switch (_etape) {
      case _EtapeSuivi.versCollecte:
        return '${widget.nomLivreur} arrive au point de collecte';
      case _EtapeSuivi.colisRecupere:
        return 'Colis récupéré';
      case _EtapeSuivi.versLivraison:
        return 'En route vers la livraison';
      case _EtapeSuivi.livre:
        return 'Colis livré !';
    }
  }

  String get _sousTitre {
    switch (_etape) {
      case _EtapeSuivi.versCollecte:
        return 'Arrivée estimée dans 4 min';
      case _EtapeSuivi.colisRecupere:
        return 'Le livreur démarre la livraison';
      case _EtapeSuivi.versLivraison:
        return 'Arrivée estimée dans 8 min';
      case _EtapeSuivi.livre:
        return 'Procède au paiement pour terminer';
    }
  }

  Future<void> _confirmerAnnulation() async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la mission ?'),
        content: const Text(
          'Le livreur est déjà en route. Des frais d\'annulation peuvent s\'appliquer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non, continuer'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Oui, annuler',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirme == true && mounted) {
      // TODO : appeler la Cloud Function d'annulation (statut -> annulee).
      context.go('/client/accueil');
    }
  }

  @override
  Widget build(BuildContext context) {
    final livre = _etape == _EtapeSuivi.livre;
    final peutAnnuler = _etape.index < _EtapeSuivi.versLivraison.index;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // --- Carte simulée ---
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Positioned.fill(
                    child: _CarteSimulee(progression: _progression)),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: () => context.go('/client/accueil'),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8),
                          ],
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: AppColors.textPrimary),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- Panneau d'informations ---
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          key: ValueKey(_etape),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_titre,
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 4),
                            Text(_sousTitre,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _BarreEtapes(etape: _etape),
                      const SizedBox(height: 20),

                      // --- Carte livreur ---
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.two_wheeler_rounded,
                                  color: AppColors.primary),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.nomLivreur,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  Row(
                                    children: const [
                                      Icon(Icons.star_rounded,
                                          color: AppColors.accent, size: 14),
                                      SizedBox(width: 2),
                                      Text('4.8',
                                          style: TextStyle(fontSize: 13)),
                                      SizedBox(width: 8),
                                      Text('Moto • AB 1234 RB',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => debugPrint('Appeler le livreur'),
                              icon: const Icon(Icons.call_rounded,
                                  color: AppColors.primary),
                              style: IconButton.styleFrom(
                                  backgroundColor:
                                      AppColors.primary.withValues(alpha: 0.1)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // --- Trajet ---
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle)),
                                Container(
                                    width: 2,
                                    height: 26,
                                    color: AppColors.border),
                                const Icon(Icons.location_on_rounded,
                                    color: AppColors.danger, size: 16),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.adresseDepart,
                                      style: const TextStyle(fontSize: 13)),
                                  const SizedBox(height: 18),
                                  Text(widget.adresseArrivee,
                                      style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (livre)
                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () => context.pushReplacement(
                              '/client/paiement',
                              extra: {
                                'nomLivreur': widget.nomLivreur,
                                'montant': widget.montant,
                              },
                            ),
                            child: const Text('Procéder au paiement'),
                          ),
                        )
                      else ...[
                        // --- Démo : ce que verra un destinataire sans compte ---
                        // TODO : remplacer par "Partager le lien de suivi" (SMS/WhatsApp).
                        OutlinedButton.icon(
                          onPressed: () =>
                              context.push('/suivi-destinataire', extra: {
                            'nomLivreur': widget.nomLivreur,
                            'etape': 1,
                          }),
                          icon: const Icon(Icons.share_outlined, size: 18),
                          label: const Text('Voir la page du destinataire'),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (!livre && peutAnnuler)
                        TextButton(
                          onPressed: _confirmerAnnulation,
                          child: const Text('Annuler la mission',
                              style: TextStyle(color: AppColors.danger)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Barre de progression en 4 segments.
class _BarreEtapes extends StatelessWidget {
  final _EtapeSuivi etape;
  const _BarreEtapes({required this.etape});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (i) {
        final atteint = i <= etape.index;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == 3 ? 0 : 6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: 6,
              decoration: BoxDecoration(
                color: atteint ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Carte dessinée à la main : fond quadrillé façon plan de ville, tracé
/// du trajet, points de collecte/livraison et marqueur du livreur qui
/// glisse le long du tracé selon `progression`.
class _CarteSimulee extends StatelessWidget {
  final double progression;
  const _CarteSimulee({required this.progression});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progression),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      builder: (context, valeur, _) => CustomPaint(
        painter: _PeintreCarte(valeur),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _PeintreCarte extends CustomPainter {
  final double progression;
  _PeintreCarte(this.progression);

  Offset _pointSurTrace(Size size, double t) {
    // Courbe de Bézier cubique entre le départ du livreur et l'arrivée.
    final p0 = Offset(size.width * 0.12, size.height * 0.75);
    final p1 = Offset(size.width * 0.35, size.height * 0.25);
    final p2 = Offset(size.width * 0.6, size.height * 0.85);
    final p3 = Offset(size.width * 0.88, size.height * 0.3);
    final u = 1 - t;
    return p0 * (u * u * u) +
        p1 * (3 * u * u * t) +
        p2 * (3 * u * t * t) +
        p3 * (t * t * t);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Fond
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFE8F0EC));

    // Quadrillage (rues)
    final rue = Paint()
      ..color = Colors.white
      ..strokeWidth = 10;
    for (double x = size.width * 0.1; x < size.width; x += size.width * 0.22) {
      canvas.drawLine(Offset(x, 0), Offset(x + 20, size.height), rue);
    }
    for (double y = size.height * 0.15;
        y < size.height;
        y += size.height * 0.28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y - 15), rue);
    }

    // Tracé complet (gris) puis partie parcourue (vert)
    final trace = Path()
      ..moveTo(_pointSurTrace(size, 0).dx, _pointSurTrace(size, 0).dy);
    for (double t = 0.02; t <= 1.0; t += 0.02) {
      final p = _pointSurTrace(size, t);
      trace.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      trace,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );

    final parcouru = Path()
      ..moveTo(_pointSurTrace(size, 0).dx, _pointSurTrace(size, 0).dy);
    for (double t = 0.02; t <= progression; t += 0.02) {
      final p = _pointSurTrace(size, t);
      parcouru.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      parcouru,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );

    // Point de collecte (à 40 % du tracé) et de livraison (fin)
    final collecte = _pointSurTrace(size, 0.4);
    canvas.drawCircle(collecte, 9, Paint()..color = Colors.white);
    canvas.drawCircle(collecte, 6, Paint()..color = AppColors.accent);

    final arrivee = _pointSurTrace(size, 1.0);
    canvas.drawCircle(arrivee, 11, Paint()..color = Colors.white);
    canvas.drawCircle(arrivee, 7, Paint()..color = AppColors.danger);

    // Marqueur du livreur
    final livreur = _pointSurTrace(size, progression);
    canvas.drawCircle(
        livreur, 20, Paint()..color = AppColors.primary.withValues(alpha: 0.2));
    canvas.drawCircle(livreur, 13, Paint()..color = Colors.white);
    canvas.drawCircle(livreur, 9, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(covariant _PeintreCarte ancien) =>
      ancien.progression != progression;
}
