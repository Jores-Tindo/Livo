import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Ouvre les applications du téléphone (appel, WhatsApp, e-mail).
///
/// Android 11+ exige de déclarer ces usages dans AndroidManifest.xml
/// (bloc <queries>), sinon canLaunch/launch échouent silencieusement.
class Lanceur {
  Lanceur._();

  static Future<bool> appeler(String numero) =>
      _ouvrir(Uri(scheme: 'tel', path: numero));

  static Future<bool> whatsapp(String numero, {String? message}) {
    final chiffres = numero.replaceAll(RegExp(r'\D'), '');
    final texte =
        message == null ? '' : '?text=${Uri.encodeComponent(message)}';
    return _ouvrir(Uri.parse('https://wa.me/$chiffres$texte'));
  }

  static Future<bool> email(String adresse, {String? sujet}) {
    final requete =
        sujet == null ? '' : '?subject=${Uri.encodeComponent(sujet)}';
    return _ouvrir(Uri.parse('mailto:$adresse$requete'));
  }

  static Future<bool> _ouvrir(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  /// Lance [action] et affiche un message si l'application cible est absente.
  static Future<void> avecMessage(
      BuildContext context, Future<bool> action, String echec) async {
    final ok = await action;
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(echec)));
    }
  }
}
