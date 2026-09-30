import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

/// Formulaire de candidature livreur. Collecte les documents et infos
/// nécessaires à la validation par l'admin (voir cahier des charges,
/// section 2.2). Même langage visuel que RegisterScreen/LoginScreen.
class CandidatureLivreurScreen extends StatefulWidget {
  const CandidatureLivreurScreen({super.key});

  @override
  State<CandidatureLivreurScreen> createState() =>
      _CandidatureLivreurScreenState();
}

class _CandidatureLivreurScreenState extends State<CandidatureLivreurScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _zoneController = TextEditingController();
  final _referencesController = TextEditingController();

  XFile? _photoProfil;
  XFile? _piecIdentite;
  String? _moyenTransport;
  bool _chargement = false;

  static const _moyensTransport = ['Moto', 'Vélo', 'Voiture', 'À pied'];

  @override
  void dispose() {
    _zoneController.dispose();
    _referencesController.dispose();
    super.dispose();
  }

  Future<void> _choisirPhoto({required bool estProfil}) async {
    final image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image == null) return;
    setState(() {
      if (estProfil) {
        _photoProfil = image;
      } else {
        _piecIdentite = image;
      }
    });
  }

  void _soumettre() {
    if (_photoProfil == null) {
      _afficherErreur('Ajoute une photo de profil');
      return;
    }
    if (_piecIdentite == null) {
      _afficherErreur('Ajoute une photo de ta pièce d\'identité');
      return;
    }
    if (_moyenTransport == null) {
      _afficherErreur('Choisis ton moyen de transport');
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _chargement = true);

      // TODO : une fois Firebase branché, uploader _photoProfil et
      // _piecIdentite vers Firebase Storage, puis créer le document
      // dans la collection candidatures/ avec statutCandidature = 'en_attente'
      // (voir firestore.rules — écriture réservée au propriétaire).

      debugPrint('Candidature : $_moyenTransport, ${_zoneController.text}');

      setState(() => _chargement = false);
      if (mounted) context.push('/candidature-envoyee');
      // TODO : go_router vers un écran de confirmation "Candidature envoyée"
    }
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Column(
        children: [
          // --- Header dégradé avec encoche ---
          Container(
            height: MediaQuery.sizeOf(context).height * 0.3,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryDark, AppColors.primary],
              ),
              borderRadius:
                  BorderRadius.only(bottomRight: Radius.circular(500)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Icon(
                        Icons.delivery_dining,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Roule. Livre. Gagne.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Deviens livreur Livo et gagne à ton rythme',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: SafeArea(
                  top: false,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- Photo de profil, ronde et centrée ---
                        Center(
                          child: GestureDetector(
                            onTap: () => _choisirPhoto(estProfil: true),
                            child: Stack(
                              children: [
                                Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary
                                        .withValues(alpha: 0.08),
                                    border: Border.all(
                                        color: AppColors.border, width: 1.5),
                                    image: _photoProfil != null
                                        ? DecorationImage(
                                            image: FileImage(
                                                File(_photoProfil!.path)),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: _photoProfil == null
                                      ? const Icon(Icons.person_outline_rounded,
                                          size: 40, color: AppColors.primary)
                                      : null,
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary,
                                    ),
                                    child: const Icon(
                                        Icons.add_a_photo_outlined,
                                        size: 15,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            'Photo de profil',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(height: 28),

                        Text('Pièce d\'identité',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(
                          'CNI, passeport ou permis en cours de validité',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        _CarteUpload(
                          fichier: _piecIdentite,
                          onTap: () => _choisirPhoto(estProfil: false),
                        ),
                        const SizedBox(height: 24),

                        Text('Moyen de transport',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _moyensTransport.map((moyen) {
                            final selectionne = _moyenTransport == moyen;
                            return ChoiceChip(
                              label: Text(moyen),
                              selected: selectionne,
                              onSelected: (_) =>
                                  setState(() => _moyenTransport = moyen),
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: selectionne
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              backgroundColor: AppColors.surface,
                              side: BorderSide(
                                  color: selectionne
                                      ? AppColors.primary
                                      : AppColors.border),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        TextFormField(
                          controller: _zoneController,
                          decoration: const InputDecoration(
                            labelText: 'Zone de couverture souhaitée',
                            hintText: 'Ex. Parakou, Bannikani, Arafat',
                            prefixIcon: Icon(Icons.map_outlined,
                                color: AppColors.textSecondary, size: 20),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'La zone de couverture est requise';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _referencesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Expérience ou références (optionnel)',
                            hintText:
                                'Ex. 2 ans en tant que livreur indépendant',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 28),

                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _chargement ? null : _soumettre,
                            child: _chargement
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text('Soumettre mon inscription'),
                                      SizedBox(width: 8),
                                      Icon(Icons.send_rounded, size: 18),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            'Réponse au plus tard 48h après vérification des pièces.',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
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

/// Carte cliquable pour uploader un document, avec aperçu une fois choisi.
class _CarteUpload extends StatelessWidget {
  final XFile? fichier;
  final VoidCallback onTap;

  const _CarteUpload({required this.fichier, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: fichier != null ? AppColors.primary : AppColors.border,
            width: fichier != null ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: fichier != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(File(fichier!.path), fit: BoxFit.cover),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.edit_outlined,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.cloud_upload_outlined,
                      size: 32, color: AppColors.textSecondary),
                  SizedBox(height: 8),
                  Text('Appuie pour ajouter une photo',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
      ),
    );
  }
}
