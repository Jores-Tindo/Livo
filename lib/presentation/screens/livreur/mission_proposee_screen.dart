import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

/// Écran reçu par le livreur quand une mission lui est proposée — le
/// pendant côté livreur de l'écran client "proposition envoyée". Décompte
/// court (20s) car c'est le livreur qui doit répondre vite ici.
///
/// TODO une fois Firebase branché : écouter le doc mission en temps réel
/// (le client peut annuler sa proposition entretemps), et le décompte
/// doit se baser sur `expiresAt`, pas un Timer local.
class MissionProposeeScreen extends StatefulWidget {
  final String nomClient;
  final String adresseDepart;
  final String adresseArrivee;
  final double distanceKm;
  final int montant;
  final String description;

  const MissionProposeeScreen({
    super.key,
    required this.nomClient,
    required this.adresseDepart,
    required this.adresseArrivee,
    required this.distanceKm,
    required this.montant,
    required this.description,
  });

  @override
  State<MissionProposeeScreen> createState() => _MissionProposeeScreenState();
}

class _MissionProposeeScreenState extends State<MissionProposeeScreen> {
  static const _dureeDecompte = 20;
  int _secondesRestantes = _dureeDecompte;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondesRestantes <= 1) {
        timer.cancel();
        _refuser(automatique: true);
      } else {
        setState(() => _secondesRestantes--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _accepter() {
    _timer?.cancel();
    // TODO : une fois Firebase branché, mettre à jour missions/{id}.statut
    // = 'acceptee' via Cloud Function (jamais en écriture directe client
    // pour un champ qui affecte le matching).
    context.pushReplacement(
      '/livreur/mission-en-cours',
      extra: {
        'nomClient': widget.nomClient,
        'adresseDepart': widget.adresseDepart,
        'adresseArrivee': widget.adresseArrivee,
        'montant': widget.montant,
        'description': widget.description,
      },
    );
  }

  void _refuser({bool automatique = false}) {
    _timer?.cancel();
    // TODO : repasser la mission à 'en_attente_choix' côté client pour
    // qu'il puisse proposer à un autre livreur.
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final progression = _secondesRestantes / _dureeDecompte;
    final urgent = _secondesRestantes <= 5;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              // --- Décompte ---
              Row(
                children: [
                  Text('Nouvelle mission',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const Spacer(),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            value: progression,
                            strokeWidth: 4,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation(
                                urgent ? AppColors.danger : AppColors.primary),
                          ),
                        ),
                        Text(
                          '$_secondesRestantes',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: urgent
                                ? AppColors.danger
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // --- Montant ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.primaryDark, AppColors.primary],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${widget.montant} F CFA',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.distanceKm.toStringAsFixed(1)} km • ${widget.nomClient}',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- Trajet ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle),
                                    ),
                                    Container(
                                        width: 2,
                                        height: 36,
                                        color: AppColors.border),
                                    const Icon(Icons.location_on_rounded,
                                        color: AppColors.danger, size: 18),
                                  ],
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Collecte',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                      Text(widget.adresseDepart,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge),
                                      const SizedBox(height: 26),
                                      Text('Livraison',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                      Text(widget.adresseArrivee,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 32, color: AppColors.border),
                            Row(
                              children: [
                                const Icon(Icons.inventory_2_outlined,
                                    color: AppColors.textSecondary, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(widget.description,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // --- Actions ---
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () => _refuser(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                        ),
                        child: const Text('Refuser'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _accepter,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success),
                        child: const Text('Accepter la mission'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
