import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class _MoyenPaiement {
  final String operateur;
  final String numero;
  final bool parDefaut;

  const _MoyenPaiement(
      {required this.operateur, required this.numero, this.parDefaut = false});
}

final List<_MoyenPaiement> _moyensMock = [
  const _MoyenPaiement(
      operateur: 'MTN Mobile Money', numero: '01 97 00 00 00', parDefaut: true),
  const _MoyenPaiement(operateur: 'Moov Money', numero: '01 95 11 22 33'),
];

/// Liste des moyens de paiement Mobile Money du client (voir cahier des
/// charges — paiement QR + Mobile Money).
///
/// TODO une fois Firebase branché : lire/écrire sur
/// utilisateurs/{uid}/moyensPaiement. Ne jamais stocker de données
/// sensibles (code PIN, OTP) — seulement le numéro et l'opérateur.
class MoyensPaiementScreen extends StatefulWidget {
  const MoyensPaiementScreen({super.key});

  @override
  State<MoyensPaiementScreen> createState() => _MoyensPaiementScreenState();
}

class _MoyensPaiementScreenState extends State<MoyensPaiementScreen> {
  final List<_MoyenPaiement> _moyens = List.of(_moyensMock);

  void _definirParDefaut(int index) {
    setState(() {
      for (var i = 0; i < _moyens.length; i++) {
        _moyens[i] = _MoyenPaiement(
          operateur: _moyens[i].operateur,
          numero: _moyens[i].numero,
          parDefaut: i == index,
        );
      }
    });
  }

  void _ajouterMoyen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FeuilleAjoutMoyen(
        onAjouter: (operateur, numero) {
          setState(() => _moyens
              .add(_MoyenPaiement(operateur: operateur, numero: numero)));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Moyens de paiement'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
          itemCount: _moyens.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final moyen = _moyens[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color:
                        moyen.parDefaut ? AppColors.primary : AppColors.border,
                    width: moyen.parDefaut ? 1.5 : 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.account_balance_wallet_rounded,
                        color: AppColors.accent, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(moyen.operateur,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        Text(moyen.numero,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  if (moyen.parDefaut)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Text('Par défaut',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    )
                  else
                    TextButton(
                      onPressed: () => _definirParDefaut(index),
                      child:
                          const Text('Définir', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajouterMoyen,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ajouter'),
      ),
    );
  }
}

class _FeuilleAjoutMoyen extends StatefulWidget {
  final void Function(String operateur, String numero) onAjouter;
  const _FeuilleAjoutMoyen({required this.onAjouter});

  @override
  State<_FeuilleAjoutMoyen> createState() => _FeuilleAjoutMoyenState();
}

class _FeuilleAjoutMoyenState extends State<_FeuilleAjoutMoyen> {
  String _operateur = 'MTN Mobile Money';
  final _numeroController = TextEditingController();

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
          Text('Nouveau moyen de paiement',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            children: [
              ChoiceChip(
                label: const Text('MTN Mobile Money'),
                selected: _operateur == 'MTN Mobile Money',
                onSelected: (_) =>
                    setState(() => _operateur = 'MTN Mobile Money'),
              ),
              ChoiceChip(
                label: const Text('Moov Money'),
                selected: _operateur == 'Moov Money',
                onSelected: (_) => setState(() => _operateur = 'Moov Money'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _numeroController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Numéro associé'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (_numeroController.text.trim().isEmpty) return;
                widget.onAjouter(_operateur, _numeroController.text.trim());
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
