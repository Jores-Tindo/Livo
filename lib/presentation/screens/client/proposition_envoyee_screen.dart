import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

/// Écran d'attente après que le client a choisi un livreur. Affiche un
/// décompte (voir cahier des charges 2.4 — délai avant fallback vers un
/// autre livreur si pas de réponse). Pour l'instant purement visuel —
/// une fois Firebase branché, ce décompte sera basé sur un champ
/// `expiresAt` du document mission, écouté en temps réel (Firestore
/// listener), pas un simple timer local comme ici.
class PropositionEnvoyeeScreen extends StatefulWidget {
  final String nomLivreur;
  const PropositionEnvoyeeScreen({super.key, required this.nomLivreur});

  @override
  State<PropositionEnvoyeeScreen> createState() => _PropositionEnvoyeeScreenState();
}

class _PropositionEnvoyeeScreenState extends State<PropositionEnvoyeeScreen> {
  static const _dureeDecompte = 45;
  int _secondesRestantes = _dureeDecompte;
  Timer? _timer;
  bool _expire = false;

  @override
  void initState() {
    super.initState();
    _demarrerDecompte();
  }

  void _demarrerDecompte() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondesRestantes <= 1) {
        timer.cancel();
        setState(() => _expire = true);
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

  void _proposerAutreLivreur() {
    // TODO : une fois Firebase branché, repasser la mission à
    // 'en_attente_choix' et retourner à la liste des livreurs en
    // excluant celui qui n'a pas répondu.
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final progression = _secondesRestantes / _dureeDecompte;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_expire) ...[
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: progression,
                          strokeWidth: 6,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_secondesRestantes',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const Text('secondes', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Proposition envoyée à ${widget.nomLivreur}',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'En attente de sa réponse. Tu seras notifié dès qu\'il accepte.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () => context.go('/client/accueil'),
                    child: const Text('Annuler la mission'),
                  ),
                ),
              ] else ...[
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.statutEnAttente.withValues(alpha: 0.12),
                  ),
                  child: const Icon(Icons.schedule_rounded, size: 64, color: AppColors.statutEnAttente),
                ),
                const SizedBox(height: 32),
                Text(
                  '${widget.nomLivreur} n\'a pas répondu',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Pas de souci, choisis un autre livreur disponible pour ta mission.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _proposerAutreLivreur,
                    child: const Text('Proposer à un autre livreur'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/client/accueil'),
                  child: const Text('Annuler la mission'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}