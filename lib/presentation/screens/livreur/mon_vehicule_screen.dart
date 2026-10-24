import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum _TypeVehicule { moto, velo, voiture, aPied }

/// Écran de gestion du véhicule du livreur. Données pré-remplies
/// mockées pour l'instant.
///
/// TODO une fois Firebase branché : lire/écrire sur livreurs/{uid}.vehicule,
/// et exiger une re-vérification admin si le type de véhicule change
/// (impact sur le matching de missions).
class MonVehiculeScreen extends StatefulWidget {
  const MonVehiculeScreen({super.key});

  @override
  State<MonVehiculeScreen> createState() => _MonVehiculeScreenState();
}

class _MonVehiculeScreenState extends State<MonVehiculeScreen> {
  _TypeVehicule _type = _TypeVehicule.moto;
  final _immatriculationController = TextEditingController(text: 'AB 1234 RB');
  bool _enregistrement = false;

  @override
  void dispose() {
    _immatriculationController.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    setState(() => _enregistrement = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _enregistrement = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Informations véhicule mises à jour'),
          backgroundColor: AppColors.success),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mon véhicule'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            Text('Type de véhicule',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _ChipVehicule(
                    label: 'Moto',
                    icone: Icons.two_wheeler_rounded,
                    selectionne: _type == _TypeVehicule.moto,
                    onTap: () => setState(() => _type = _TypeVehicule.moto)),
                _ChipVehicule(
                    label: 'Vélo',
                    icone: Icons.pedal_bike_rounded,
                    selectionne: _type == _TypeVehicule.velo,
                    onTap: () => setState(() => _type = _TypeVehicule.velo)),
                _ChipVehicule(
                    label: 'Voiture',
                    icone: Icons.directions_car_filled_rounded,
                    selectionne: _type == _TypeVehicule.voiture,
                    onTap: () => setState(() => _type = _TypeVehicule.voiture)),
                _ChipVehicule(
                    label: 'À pied',
                    icone: Icons.directions_walk_rounded,
                    selectionne: _type == _TypeVehicule.aPied,
                    onTap: () => setState(() => _type = _TypeVehicule.aPied)),
              ],
            ),
            if (_type != _TypeVehicule.aPied &&
                _type != _TypeVehicule.velo) ...[
              const SizedBox(height: 28),
              Text('Immatriculation',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: _immatriculationController,
                decoration: const InputDecoration(
                  hintText: 'Ex. AB 1234 RB',
                  prefixIcon: Icon(Icons.confirmation_number_outlined,
                      color: AppColors.textSecondary, size: 20),
                ),
              ),
            ],
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.info, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Un changement de véhicule peut nécessiter une nouvelle vérification de ton dossier.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _enregistrement ? null : _enregistrer,
                child: _enregistrement
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipVehicule extends StatelessWidget {
  final String label;
  final IconData icone;
  final bool selectionne;
  final VoidCallback onTap;

  const _ChipVehicule(
      {required this.label,
      required this.icone,
      required this.selectionne,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selectionne ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selectionne ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone,
                size: 18,
                color: selectionne ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                  color: selectionne ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
