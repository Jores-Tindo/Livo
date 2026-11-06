import 'dart:async';
import 'dart:io';
import 'package:latlong2/latlong.dart';

/// Résultat de l'analyse d'un lien ou d'un texte de localisation.
class ResultatLocalisation {
  /// Coordonnées trouvées (null si le lien n'en contient pas).
  final LatLng? position;

  /// Nom du lieu lu dans le lien (ex. ".../place/Marche+Dantokpa/..."),
  /// à géocoder en dernier recours quand il n'y a pas de coordonnées.
  final String? nomLieu;

  const ResultatLocalisation({this.position, this.nomLieu});
}

/// Comprend ce qu'un utilisateur colle dans un champ d'adresse :
///  - un lien Google Maps (long, ou court maps.app.goo.gl) ;
///  - un lien geo: (partage Android) ;
///  - des coordonnées brutes : "6.3703, 2.3912".
class LienLocalisation {
  LienLocalisation._();

  static const _nb = r'(-?\d{1,3}(?:\.\d+)?)';

  static final _motifsCoordonnees = <RegExp>[
    // Épingle exacte du lieu (la plus fiable dans les liens Google Maps)
    RegExp('!3d$_nb!4d$_nb'),
    // Centre de la vue : .../@6.3703,2.3912,17z
    RegExp('@$_nb,$_nb'),
    // Paramètres : ?q=lat,lng  ll=  query=  destination=  daddr=  center=
    RegExp('[?&](?:q|ll|query|destination|daddr|center)=$_nb,\\s*$_nb'),
    // geo:lat,lng
    RegExp('geo:$_nb,$_nb'),
    // Coordonnées brutes
    RegExp('^\\s*$_nb\\s*[,; ]\\s*$_nb\\s*\$'),
  ];

  /// Seuls ces domaines sont suivis pour résoudre un lien court : on
  /// n'ouvre jamais une adresse quelconque collée par l'utilisateur.
  static const _hotesLiensCourts = {'maps.app.goo.gl', 'goo.gl', 'g.co'};

  /// Vrai si le texte ressemble à un lien ou à des coordonnées (et non à
  /// une adresse écrite normalement).
  static bool ressembleAUnLien(String texte) {
    final t = texte.trim().toLowerCase();
    if (t.startsWith('http://') ||
        t.startsWith('https://') ||
        t.startsWith('geo:')) return true;
    if (t.contains('maps.app.goo.gl') ||
        t.contains('google.com/maps') ||
        t.contains('goo.gl/maps')) return true;
    return _coordonneesBrutes(t) != null;
  }

  static LatLng? _coordonneesBrutes(String t) {
    final m = RegExp('^\\s*$_nb\\s*[,; ]\\s*$_nb\\s*\$').firstMatch(t);
    return m == null ? null : _valider(m.group(1), m.group(2));
  }

  static LatLng? _valider(String? a, String? b) {
    final lat = double.tryParse(a ?? '');
    final lng = double.tryParse(b ?? '');
    if (lat == null || lng == null) return null;
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;
    if (lat == 0 && lng == 0) return null;
    return LatLng(lat, lng);
  }

  static LatLng? _extraire(String texte) {
    String decode;
    try {
      decode = Uri.decodeFull(texte);
    } catch (_) {
      decode = texte;
    }
    for (final motif in _motifsCoordonnees) {
      final m = motif.firstMatch(decode);
      if (m != null) {
        final pos = _valider(m.group(1), m.group(2));
        if (pos != null) return pos;
      }
    }
    return null;
  }

  static String? _nomDuLieu(String texte) {
    final m = RegExp(r'/maps/place/([^/@?]+)').firstMatch(texte);
    if (m == null) return null;
    try {
      final nom = Uri.decodeComponent(m.group(1)!.replaceAll('+', ' ')).trim();
      return nom.isEmpty ? null : nom;
    } catch (_) {
      return null;
    }
  }

  /// Analyse [texte]. Résout au besoin les liens courts Google (réseau).
  static Future<ResultatLocalisation> resoudre(String texte) async {
    var t = texte.trim();

    final direct = _extraire(t);
    if (direct != null) return ResultatLocalisation(position: direct);

    final uri = Uri.tryParse(t);
    if (uri != null &&
        uri.scheme == 'https' &&
        _hotesLiensCourts.contains(uri.host)) {
      final finale = await _suivreRedirections(uri);
      if (finale != null) t = finale.toString();
    }

    final position = _extraire(t);
    if (position != null) return ResultatLocalisation(position: position);
    return ResultatLocalisation(nomLieu: _nomDuLieu(t));
  }

  /// Suit les redirections d'un lien court sans télécharger la page
  /// (5 sauts maximum, délais courts).
  static Future<Uri?> _suivreRedirections(Uri depart) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 6)
      ..userAgent = 'Livo';
    try {
      var courant = depart;
      for (var i = 0; i < 5; i++) {
        final requete =
            await client.getUrl(courant).timeout(const Duration(seconds: 8));
        requete.followRedirects = false;
        final reponse =
            await requete.close().timeout(const Duration(seconds: 8));
        await reponse.drain<void>();
        final lieu = reponse.headers.value(HttpHeaders.locationHeader);
        if (!reponse.isRedirect || lieu == null) break;
        courant = courant.resolve(lieu);
        if (courant.scheme != 'https') break;
      }
      return courant;
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }
}
