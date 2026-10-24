import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

const _zonesDisponibles = [
  'Cotonou - Akpakpa',
  'Cotonou - Houeyiho',
  'Cotonou - Fidjrossè',
  'Cotonou - Cadjehoun',
  'Abomey-Calavi',
  'Porto-Novo',
];

/// Sélection des zones où le livreur accepte de recevoir des missions.
/// Le matching ne lui proposera des missions que si le point de collecte
/// tombe dans une de ces zones (voir cahier des charges 2.4).
///
/// TODO une fois Firebase branché : lire/écrire livreurs/{uid}.zones, et
/// côté matching, filtrer les missions proposées par zone de couverture
/// (requête Firestore ou logique Cloud Function).
class ZoneCouvertureScreen extends StatefulWidget {
  const ZoneCouvertureScreen({super.key});

  @override
  State<ZoneCouvertureScreen> createState() => _ZoneCouvertureScreenState();
}

class _ZoneCouvertureScreenState extends State<ZoneCouvertureScreen> {
  final Set<String> _zonesSelectionnees = {
    'Cotonou - Akpakpa',
    'Cotonou - Houeyiho'
  };
  bool _enregistrement = false;

  Future<void> _enregistrer() async {
    setState(() => _enregistrement = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _enregistrement = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Zone de couverture mise à jour'),
          backgroundColor: AppColors.success),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Zone de couverture'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                children: [
                  Text(
                    'Choisis les zones où tu veux recevoir des missions',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ..._zonesDisponibles.map((zone) {
                    final selectionnee = _zonesSelectionnees.contains(zone);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => setState(() {
                          if (selectionnee) {
                            _zonesSelectionnees.remove(zone);
                          } else {
                            _zonesSelectionnees.add(zone);
                          }
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: selectionnee
                                ? AppColors.primary.withValues(alpha: 0.08)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: selectionnee
                                    ? AppColors.primary
                                    : AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: selectionnee
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Text(zone,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500))),
                              Icon(
                                selectionnee
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                color: selectionnee
                                    ? AppColors.primary
                                    : AppColors.border,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _enregistrement ? null : _enregistrer,
                  child: _enregistrement
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(
                          'Enregistrer (${_zonesSelectionnees.length} zones)'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
