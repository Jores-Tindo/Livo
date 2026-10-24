import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';

/// Formulaire de modification du profil, commun aux deux rôles (seuls
/// les champs affichés sont identiques pour l'instant — nom, téléphone,
/// email, photo). Sauvegarde mockée pour le moment.
///
/// TODO une fois Firebase branché : pré-remplir avec les vraies données
/// de utilisateurs/{uid}, uploader la photo sur Firebase Storage, et
/// écrire les champs modifiés sur le doc (jamais le rôle ni le statut
/// de candidature depuis cet écran — voir firestore.rules).
class ModifierProfilScreen extends StatefulWidget {
  const ModifierProfilScreen({super.key});

  @override
  State<ModifierProfilScreen> createState() => _ModifierProfilScreenState();
}

class _ModifierProfilScreenState extends State<ModifierProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _nomController = TextEditingController(text: 'Jores A.');
  final _telephoneController = TextEditingController(text: '01 97 00 00 00');
  final _emailController = TextEditingController();

  XFile? _photo;
  bool _enregistrement = false;

  @override
  void dispose() {
    _nomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _choisirPhoto() async {
    final image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) setState(() => _photo = image);
  }

  Future<void> _enregistrer() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _enregistrement = true);
    // TODO : une fois Firebase branché, appeler le repository pour
    // persister ces champs (+ upload photo) via Firestore/Storage.
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    setState(() => _enregistrement = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Profil mis à jour'),
          backgroundColor: AppColors.success),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Modifier mon profil'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              Center(
                child: GestureDetector(
                  onTap: _choisirPhoto,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.1),
                          image: _photo != null
                              ? DecorationImage(
                                  image: FileImage(File(_photo!.path)),
                                  fit: BoxFit.cover)
                              : null,
                        ),
                        child: _photo == null
                            ? const Icon(Icons.person_rounded,
                                color: AppColors.primary, size: 48)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                              color: AppColors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.edit_rounded,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  prefixIcon: Icon(Icons.person_outline_rounded,
                      color: AppColors.textSecondary, size: 20),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Le nom est requis'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telephoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  prefixIcon: Icon(Icons.phone_outlined,
                      color: AppColors.textSecondary, size: 20),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Le téléphone est requis'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email (optionnel)',
                  prefixIcon: Icon(Icons.mail_outline_rounded,
                      color: AppColors.textSecondary, size: 20),
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
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
