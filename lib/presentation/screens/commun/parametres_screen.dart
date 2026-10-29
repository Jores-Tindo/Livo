import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

/// Paramètres de l'application, communs au client et au livreur.
///
/// TODO une fois Firebase branché :
///  - enregistrer les préférences de notification dans
///    utilisateurs/{uid}/preferences et le thème/la langue en local
///    (shared_preferences) ;
///  - la suppression de compte passe par une Cloud Function qui
///    anonymise ou supprime les données (Auth + Firestore + Storage) et
///    refuse s'il reste une mission en cours ou un solde à retirer.
class ParametresScreen extends StatefulWidget {
  const ParametresScreen({super.key});

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  bool _push = true;
  bool _sms = true;
  bool _promos = false;
  String _langue = 'Français';
  String _theme = 'Automatique';

  Future<void> _choisir(String titre, List<String> options, String actuel,
      ValueChanged<String> onChoix) async {
    final choix = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titre, style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final o in options)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(o),
                  trailing: o == actuel
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.primary)
                      : null,
                  onTap: () => Navigator.pop(ctx, o),
                ),
            ],
          ),
        ),
      ),
    );
    if (choix != null) onChoix(choix);
  }

  void _info(String titre, String texte) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titre),
        content: Text(texte),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Fermer'))
        ],
      ),
    );
  }

  Future<void> _supprimerCompte() async {
    final controller = TextEditingController();
    final confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Supprimer mon compte'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  'Cette action est définitive : tes données et ton historique seront supprimés.'),
              const SizedBox(height: 14),
              const Text('Tape SUPPRIMER pour confirmer :'),
              const SizedBox(height: 8),
              TextField(controller: controller, onChanged: (_) => setD(() {})),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler')),
            TextButton(
              onPressed: controller.text.trim() == 'SUPPRIMER'
                  ? () => Navigator.pop(ctx, true)
                  : null,
              child: const Text('Supprimer',
                  style: TextStyle(color: AppColors.danger)),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (confirme == true && mounted) context.go('/inscription');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            _Section(titre: 'Notifications', enfants: [
              _Interrupteur(
                icone: Icons.notifications_active_outlined,
                titre: 'Notifications push',
                valeur: _push,
                onChanged: (v) => setState(() => _push = v),
              ),
              _Interrupteur(
                icone: Icons.sms_outlined,
                titre: 'SMS de suivi',
                valeur: _sms,
                onChanged: (v) => setState(() => _sms = v),
              ),
              _Interrupteur(
                icone: Icons.local_offer_outlined,
                titre: 'Offres et nouveautés',
                valeur: _promos,
                onChanged: (v) => setState(() => _promos = v),
              ),
            ]),
            _Section(titre: 'Application', enfants: [
              _Ligne(
                icone: Icons.language_rounded,
                titre: 'Langue',
                valeur: _langue,
                onTap: () => _choisir('Langue', ['Français', 'English'],
                    _langue, (v) => setState(() => _langue = v)),
              ),
              _Ligne(
                icone: Icons.dark_mode_outlined,
                titre: 'Thème',
                valeur: _theme,
                onTap: () => _choisir(
                    'Thème',
                    ['Automatique', 'Clair', 'Sombre'],
                    _theme,
                    (v) => setState(() => _theme = v)),
              ),
            ]),
            _Section(titre: 'Sécurité', enfants: [
              _Ligne(
                icone: Icons.lock_reset_rounded,
                titre: 'Changer mon mot de passe',
                onTap: () => context.push('/mot-de-passe-oublie'),
              ),
            ]),
            _Section(titre: 'À propos', enfants: [
              _Ligne(
                icone: Icons.description_outlined,
                titre: 'Conditions d\'utilisation',
                onTap: () => _info('Conditions d\'utilisation',
                    'Le texte complet des CGU sera affiché ici.'),
              ),
              _Ligne(
                icone: Icons.privacy_tip_outlined,
                titre: 'Politique de confidentialité',
                onTap: () => _info('Confidentialité',
                    'La politique de confidentialité sera affichée ici.'),
              ),
              const _Ligne(
                  icone: Icons.info_outline_rounded,
                  titre: 'Version',
                  valeur: '1.0.0'),
            ]),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _supprimerCompte,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                minimumSize: const Size.fromHeight(52),
              ),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Supprimer mon compte'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String titre;
  final List<Widget> enfants;
  const _Section({required this.titre, required this.enfants});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(titre, style: Theme.of(context).textTheme.titleMedium),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                for (var i = 0; i < enfants.length; i++) ...[
                  if (i > 0) const Divider(height: 1, indent: 56),
                  enfants[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Ligne extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String? valeur;
  final VoidCallback? onTap;
  const _Ligne(
      {required this.icone, required this.titre, this.valeur, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icone, color: AppColors.primary),
      title: Text(titre),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (valeur != null)
            Text(valeur!, style: Theme.of(context).textTheme.bodyMedium),
          if (onTap != null)
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _Interrupteur extends StatelessWidget {
  final IconData icone;
  final String titre;
  final bool valeur;
  final ValueChanged<bool> onChanged;
  const _Interrupteur(
      {required this.icone,
      required this.titre,
      required this.valeur,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icone, color: AppColors.primary),
      title: Text(titre),
      value: valeur,
      activeColor: AppColors.primary,
      onChanged: onChanged,
    );
  }
}
