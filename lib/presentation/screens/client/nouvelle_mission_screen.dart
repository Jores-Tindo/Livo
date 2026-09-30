import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';

enum _EtapeMission { position, details }

enum _TypeDestinataire { moiMeme, autrePersonne }

/// Écran de création de mission. Deux étapes internes :
/// 1. Positionnement départ/arrivée sur carte (pin fixe façon Uber/Bolt —
///    c'est la carte qui bouge sous le pin, pas l'inverse)
/// 2. Détails de la mission : colis, destinataire, point de repère
///
/// Voir cahier des charges 2.4 et 2.5 pour la logique des trois cas de
/// destinataire (lui-même / autre avec compte / autre sans compte).
class NouvelleMissionScreen extends StatefulWidget {
  const NouvelleMissionScreen({super.key});

  @override
  State<NouvelleMissionScreen> createState() => _NouvelleMissionScreenState();
}

class _NouvelleMissionScreenState extends State<NouvelleMissionScreen> {
  final _picker = ImagePicker();
  final _geocoding = Geocoding();
  GoogleMapController? _controleurCarte;

  _EtapeMission _etape = _EtapeMission.position;
  bool _choixDepart = true; // true = on positionne le départ, false = l'arrivée

  // Position par défaut : Cotonou (à ajuster si géolocalisation dispo)
  static const _positionParDefaut = LatLng(6.3703, 2.3912);

  LatLng _positionCarte = _positionParDefaut;
  String _adresseAffichee = 'Déplace la carte pour choisir un point';
  bool _chargementAdresse = false;

  LatLng? _positionDepart;
  String? _adresseDepart;
  LatLng? _positionArrivee;
  String? _adresseArrivee;

  final _pointRepereController = TextEditingController();
  final _descriptionColisController = TextEditingController();
  final _nomDestinataireController = TextEditingController();
  final _telephoneDestinataireController = TextEditingController();

  _TypeDestinataire _typeDestinataire = _TypeDestinataire.moiMeme;
  XFile? _photoLieu;
  bool _chargementEnvoi = false;

  @override
  void dispose() {
    _controleurCarte?.dispose();
    _pointRepereController.dispose();
    _descriptionColisController.dispose();
    _nomDestinataireController.dispose();
    _telephoneDestinataireController.dispose();
    super.dispose();
  }

  Future<void> _utiliserPositionActuelle() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final nouvelleAutorisation = await Geolocator.requestPermission();
        if (nouvelleAutorisation == LocationPermission.denied ||
            nouvelleAutorisation == LocationPermission.deniedForever) {
          _afficherErreur(
              'Autorise la localisation pour utiliser cette fonctionnalité');
          return;
        }
      }
      final position = await Geolocator.getCurrentPosition();
      final nouvellePosition = LatLng(position.latitude, position.longitude);
      _controleurCarte?.animateCamera(CameraUpdate.newLatLng(nouvellePosition));
      setState(() => _positionCarte = nouvellePosition);
      _actualiserAdresse(nouvellePosition);
    } catch (e) {
      _afficherErreur('Impossible de récupérer ta position');
    }
  }

  Future<void> _actualiserAdresse(LatLng position) async {
    setState(() => _chargementAdresse = true);
    try {
      final places = await _geocoding.placemarkFromCoordinates(
          position.latitude, position.longitude);
      if (places.isNotEmpty) {
        final p = places.first;
        setState(() {
          _adresseAffichee = [p.street, p.subLocality, p.locality]
              .where((e) => e != null && e.isNotEmpty)
              .join(', ');
          if (_adresseAffichee.isEmpty)
            _adresseAffichee = 'Position sélectionnée';
        });
      }
    } catch (_) {
      setState(() => _adresseAffichee = 'Position sélectionnée');
    } finally {
      setState(() => _chargementAdresse = false);
    }
  }

  void _confirmerPosition() {
    if (_choixDepart) {
      _positionDepart = _positionCarte;
      _adresseDepart = _adresseAffichee;
      setState(() {
        _choixDepart = false;
        _adresseAffichee = 'Déplace la carte pour choisir un point';
      });
    } else {
      _positionArrivee = _positionCarte;
      _adresseArrivee = _adresseAffichee;
      setState(() => _etape = _EtapeMission.details);
    }
  }

  Future<void> _choisirPhotoLieu() async {
    final image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) setState(() => _photoLieu = image);
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  void _envoyerMission() {
    if (_typeDestinataire == _TypeDestinataire.autrePersonne &&
        (_nomDestinataireController.text.trim().isEmpty ||
            _telephoneDestinataireController.text.trim().isEmpty)) {
      _afficherErreur('Renseigne le nom et le téléphone du destinataire');
      return;
    }
    if (_descriptionColisController.text.trim().isEmpty) {
      _afficherErreur('Décris brièvement ce que tu envoies');
      return;
    }

    setState(() => _chargementEnvoi = true);

    // TODO : une fois Firebase branché, créer le document dans missions/
    // avec statut = 'en_attente_choix', puis go_router vers l'écran de
    // liste des livreurs disponibles pour que le client en choisisse un
    // (voir cahier des charges 2.4 — sélection manuelle par le client).

    debugPrint(
        'Mission : $_adresseDepart -> $_adresseArrivee, ${_descriptionColisController.text}');

    setState(() => _chargementEnvoi = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _etape == _EtapeMission.position
          ? _construireEtapePosition()
          : _construireEtapeDetails(),
    );
  }

  // --- Étape 1 : sélection des positions sur la carte ---
  Widget _construireEtapePosition() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition:
              const CameraPosition(target: _positionParDefaut, zoom: 15),
          onMapCreated: (controller) => _controleurCarte = controller,
          onCameraMove: (position) => _positionCarte = position.target,
          onCameraIdle: () => _actualiserAdresse(_positionCarte),
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
        ),

        // Pin fixe au centre de l'écran
        const Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: Icon(Icons.location_on, size: 44, color: AppColors.primary),
          ),
        ),

        // Bouton retour
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _BoutonRond(
              icone: Icons.arrow_back_rounded,
              onTap: () {
                if (!_choixDepart) {
                  setState(() {
                    _choixDepart = true;
                    _adresseAffichee = _adresseDepart ??
                        'Déplace la carte pour choisir un point';
                  });
                } else {
                  Navigator.of(context).maybePop();
                }
              },
            ),
          ),
        ),

        // Bouton "ma position"
        Positioned(
          right: 16,
          bottom: 220,
          child: _BoutonRond(
              icone: Icons.my_location_rounded,
              onTap: _utiliserPositionActuelle),
        ),

        // Carte du bas : adresse + confirmation
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        _choixDepart ? Icons.trip_origin : Icons.flag_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _choixDepart ? 'Point de départ' : 'Point d\'arrivée',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.place_outlined,
                            color: AppColors.textSecondary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _chargementAdresse
                              ? const Text('Localisation en cours...',
                                  style:
                                      TextStyle(color: AppColors.textSecondary))
                              : Text(_adresseAffichee,
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _chargementAdresse ? null : _confirmerPosition,
                      child: Text(_choixDepart
                          ? 'Confirmer le départ'
                          : 'Confirmer l\'arrivée'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Étape 2 : détails de la mission ---
  Widget _construireEtapeDetails() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                _BoutonRond(
                  icone: Icons.arrow_back_rounded,
                  onTap: () => setState(() => _etape = _EtapeMission.position),
                ),
                const SizedBox(width: 12),
                Text('Détails de la mission',
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Récap trajet ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _LigneTrajet(
                            icone: Icons.trip_origin,
                            couleur: AppColors.primary,
                            texte: _adresseDepart ?? ''),
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 9),
                          child: SizedBox(
                            height: 16,
                            child: VerticalDivider(
                                color: AppColors.border, thickness: 1.5),
                          ),
                        ),
                        _LigneTrajet(
                            icone: Icons.flag_rounded,
                            couleur: AppColors.danger,
                            texte: _adresseArrivee ?? ''),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('Point de repère (optionnel)',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('Utile si l\'adresse est difficile à trouver',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _pointRepereController,
                    decoration: const InputDecoration(
                      hintText: 'Ex. Près du grand manguier, maison bleue',
                      prefixIcon: Icon(Icons.push_pin_outlined,
                          color: AppColors.textSecondary, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: _choisirPhotoLieu,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          if (_photoLieu != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(File(_photoLieu!.path),
                                  width: 36, height: 36, fit: BoxFit.cover),
                            )
                          else
                            const Icon(Icons.add_a_photo_outlined,
                                color: AppColors.textSecondary, size: 22),
                          const SizedBox(width: 12),
                          Text(
                            _photoLieu != null
                                ? 'Photo ajoutée'
                                : 'Ajouter une photo du lieu (optionnel)',
                            style:
                                const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('Description du colis',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _descriptionColisController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'Ex. Un carton de vêtements, environ 3 kg',
                      prefixIcon: Icon(Icons.inventory_2_outlined,
                          color: AppColors.textSecondary, size: 20),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('Qui reçoit le colis ?',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ChoixDestinataire(
                          label: 'Moi-même',
                          icone: Icons.person_outline_rounded,
                          selectionne:
                              _typeDestinataire == _TypeDestinataire.moiMeme,
                          onTap: () => setState(() =>
                              _typeDestinataire = _TypeDestinataire.moiMeme),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ChoixDestinataire(
                          label: 'Une autre personne',
                          icone: Icons.people_outline_rounded,
                          selectionne: _typeDestinataire ==
                              _TypeDestinataire.autrePersonne,
                          onTap: () => setState(() => _typeDestinataire =
                              _TypeDestinataire.autrePersonne),
                        ),
                      ),
                    ],
                  ),

                  if (_typeDestinataire == _TypeDestinataire.autrePersonne) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nomDestinataireController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du destinataire',
                        prefixIcon: Icon(Icons.badge_outlined,
                            color: AppColors.textSecondary, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _telephoneDestinataireController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone du destinataire',
                        prefixIcon: Icon(Icons.phone_outlined,
                            color: AppColors.textSecondary, size: 20),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: AppColors.info, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Le destinataire recevra un SMS avec le suivi de la livraison.',
                              style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // --- Estimation tarif (placeholder) ---
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.primary],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.payments_outlined,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tarif estimé',
                                  style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.85),
                                      fontSize: 13)),
                              const Text(
                                'Calculé à l\'étape suivante',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _chargementEnvoi ? null : _envoyerMission,
                      child: _chargementEnvoi
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Voir les livreurs disponibles'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoutonRond extends StatelessWidget {
  final IconData icone;
  final VoidCallback onTap;
  const _BoutonRond({required this.icone, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Icon(icone, color: AppColors.textPrimary),
      ),
    );
  }
}

class _LigneTrajet extends StatelessWidget {
  final IconData icone;
  final Color couleur;
  final String texte;
  const _LigneTrajet(
      {required this.icone, required this.couleur, required this.texte});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icone, color: couleur, size: 18),
        const SizedBox(width: 10),
        Expanded(
            child: Text(texte, maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class _ChoixDestinataire extends StatelessWidget {
  final String label;
  final IconData icone;
  final bool selectionne;
  final VoidCallback onTap;
  const _ChoixDestinataire(
      {required this.label,
      required this.icone,
      required this.selectionne,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selectionne
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selectionne ? AppColors.primary : AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icone,
                color:
                    selectionne ? AppColors.primary : AppColors.textSecondary,
                size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: selectionne ? AppColors.primary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
