import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';

/// Page vue par un destinataire SANS compte Livo, ouverte depuis le lien
/// reçu par SMS. Il suit le livreur en direct sur la carte, peut confirmer
/// sa position exacte, et présente le code/QR au livreur à la remise.
///
/// TODO une fois Firebase branché :
///  - c'est une page web publique (Firebase Hosting) accessible par un
///    lien à jeton long et aléatoire propre à la mission, jamais par un
///    identifiant devinable ; le lien est en lecture seule et expire
///    après la livraison ;
///  - la position du livreur vient d'un listener Firestore sur la mission
///    (le livreur y écrit sa position toutes les quelques secondes) ;
///  - "Confirmer ma position" appelle une Cloud Function qui valide le jeton
///    puis met à jour le point d'arrivée de CETTE mission uniquement ;
///  - le code de remise est lu côté serveur et la remise est validée par
///    une Cloud Function (voir ConfirmationLivraisonScreen).
class SuiviDestinataireScreen extends StatefulWidget {
  final String expediteur;
  final String nomLivreur;
  final String code;
  final int etape; // 0 collecte, 1 en route, 2 arrivé

  const SuiviDestinataireScreen({
    super.key,
    this.expediteur = 'Esther K.',
    this.nomLivreur = 'Pascal Houngbo',
    this.code = '4827',
    this.etape = 1,
  });

  @override
  State<SuiviDestinataireScreen> createState() =>
      _SuiviDestinataireScreenState();
}

class _SuiviDestinataireScreenState extends State<SuiviDestinataireScreen> {
  static const _depart = LatLng(6.3608, 2.3571);
  static const _dureeTotaleSecondes = 90;

  LatLng _arrivee = const LatLng(6.3560, 2.4420);
  late double _progression;
  Timer? _timer;
  bool _positionEnCours = false;
  bool _positionConfirmee = false;

  @override
  void initState() {
    super.initState();
    _progression = switch (widget.etape) { 0 => 0.0, 2 => 0.97, _ => 0.3 };
    // Simulation du temps réel : le livreur avance toutes les secondes.
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      if (_progression >= 1) return t.cancel();
      setState(() => _progression =
          (_progression + 1 / _dureeTotaleSecondes).clamp(0.0, 1.0));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  LatLng get _positionLivreur => LatLng(
        _depart.latitude +
            (_arrivee.latitude - _depart.latitude) * _progression,
        _depart.longitude +
            (_arrivee.longitude - _depart.longitude) * _progression,
      );

  int get _etape => _progression < 0.2 ? 0 : (_progression < 0.95 ? 1 : 2);
  int get _minutes => ((1 - _progression) * 12).ceil();

  void _message(String texte, {bool erreur = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(texte),
          backgroundColor: erreur ? AppColors.danger : AppColors.success),
    );
  }

  Future<void> _confirmerMaPosition() async {
    setState(() => _positionEnCours = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _message('Active la localisation de ton téléphone', erreur: true);
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied)
        permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _message('Autorise la localisation pour partager ta position',
            erreur: true);
        return;
      }
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)),
      );
      if (!mounted) return;
      // TODO : envoyer à la Cloud Function (jeton + coordonnées).
      setState(() {
        _arrivee = LatLng(p.latitude, p.longitude);
        _positionConfirmee = true;
      });
      _message('Position envoyée au livreur');
    } catch (e) {
      debugPrint('Erreur position destinataire : $e');
      _message('Impossible de récupérer ta position', erreur: true);
    } finally {
      if (mounted) setState(() => _positionEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const etapes = [
      'Livreur en route vers l\'expéditeur',
      'Colis en route vers toi',
      'Livreur arrivé'
    ];
    final arrive = _etape == 2;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Suivi de ton colis'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            Text('${widget.expediteur} t\'envoie un colis',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text('Livré par ${widget.nomLivreur}',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 20),

            // --- Carte en direct ---
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: SizedBox(
                height: 240,
                child: Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        initialCameraFit: CameraFit.bounds(
                          bounds: LatLngBounds.fromPoints([_depart, _arrivee]),
                          padding: const EdgeInsets.all(48),
                        ),
                        interactionOptions: const InteractionOptions(
                          flags:
                              InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.livo.livo',
                        ),
                        PolylineLayer(polylines: [
                          Polyline(
                              points: [_depart, _arrivee],
                              strokeWidth: 4,
                              color: AppColors.primary.withValues(alpha: 0.5)),
                        ]),
                        MarkerLayer(markers: [
                          Marker(
                            point: _arrivee,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.location_on,
                                color: AppColors.danger, size: 38),
                          ),
                          Marker(
                            point: _positionLivreur,
                            width: 44,
                            height: 44,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.25),
                                      blurRadius: 6)
                                ],
                              ),
                              child: const Icon(Icons.two_wheeler_rounded,
                                  color: Colors.white, size: 22),
                            ),
                          ),
                        ]),
                      ],
                    ),
                    Positioned(
                      left: 6,
                      bottom: 4,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(color: Color(0xCCFFFFFF)),
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          child: Text('© OpenStreetMap',
                              style: TextStyle(fontSize: 10)),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8)
                          ],
                        ),
                        child: Text(
                          arrive
                              ? 'Le livreur est arrivé'
                              : 'Arrivée dans ~$_minutes min',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: (_positionEnCours || _positionConfirmee)
                  ? null
                  : _confirmerMaPosition,
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)),
              icon: _positionEnCours
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(
                      _positionConfirmee
                          ? Icons.check_circle_rounded
                          : Icons.my_location_rounded,
                      size: 18),
              label: Text(_positionConfirmee
                  ? 'Position confirmée'
                  : 'Confirmer ma position exacte'),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < etapes.length; i++)
                    _EtapeLigne(
                      texte: etapes[i],
                      faite: i < _etape,
                      active: i == _etape,
                      derniere: i == etapes.length - 1,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text('Ton code de remise',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18)),
                    child: QrImageView(
                      data: 'livo:remise:${widget.code}',
                      size: 170,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.code.split('').join('  '),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Montre le QR ou donne ce code au livreur seulement quand tu as ton colis en main.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.code));
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Code copié')));
              },
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)),
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Copier le code'),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined, color: AppColors.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ne partage ce code avec personne d\'autre que le livreur qui te remet le colis. Livo ne te le demandera jamais par téléphone.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EtapeLigne extends StatelessWidget {
  final String texte;
  final bool faite;
  final bool active;
  final bool derniere;
  const _EtapeLigne(
      {required this.texte,
      required this.faite,
      required this.active,
      required this.derniere});

  @override
  Widget build(BuildContext context) {
    final couleur = (faite || active) ? AppColors.primary : AppColors.border;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: faite ? AppColors.primary : AppColors.surface,
                  border: Border.all(color: couleur, width: 2),
                ),
                child: faite
                    ? const Icon(Icons.check_rounded,
                        size: 14, color: Colors.white)
                    : null,
              ),
              if (!derniere)
                Expanded(
                    child: Container(
                        width: 2,
                        color: faite ? AppColors.primary : AppColors.border)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: derniere ? 0 : 20),
              child: Text(
                texte,
                style: TextStyle(
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: (faite || active)
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
